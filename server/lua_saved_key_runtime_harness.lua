-- Controlled Lua execution harness for the production saved-key branch.
-- It loads an explicit production wrapper path in memory with host stubs only;
-- the production file is never edited and no HTTP request is sent.

local source_path = assert(arg[1], "production Lua source path is required")
local source_file = assert(io.open(source_path, "rb"))
local production_source = source_file:read("*a")
source_file:close()

local function quote_json(value)
  return string.format("%q", tostring(value))
end

local function make_json_adapter()
  return {
    encode = function(value)
      if type(value) == "table" and type(value.key) == "string" then
        return '{"key":' .. quote_json(value.key) .. "}"
      end
      if type(value) == "table" and type(value.device_id) == "string" then
        return '{"key":' .. quote_json(value.key or "") .. ',"device_id":' .. quote_json(value.device_id) .. "}"
      end
      error("unexpected JSON encode shape")
    end,
    decode = function(value)
      if value == "__VALID__" then
        return { status = "valid", success = true, expiresAt = "2030-01-01T00:00:00.000Z" }
      end
      if value == "__INVALID__" then
        return { status = "invalid", success = false }
      end
      if value == "__EXPIRED__" then
        return { status = "expired", success = false }
      end
      if value == "__MAINTENANCE_OFF__" then
        return { active = false }
      end
      if value == "__MAINTENANCE_ACTIVE__" then
        return { active = true, title = "🔧 Server Under Maintenance", message = "Please wait... ⏳" }
      end
      local key = type(value) == "string" and value:match('^%s*%{%s*"key"%s*:%s*"(.-)"%s*%}%s*$') or nil
      if key then return { key = key } end
      error("unexpected JSON decode payload")
    end,
  }
end

local function read_file(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local value = file:read("*a")
  file:close()
  return value
end

local function assert_equal(actual, expected, label)
  if actual ~= expected then
    error(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local function run_case(case_name, old_key, entered_key, response_kind, expected_saved_key, expected_callback_ok, expected_authorized, maintenance_active)
  local temp_dir = os.tmpname() .. "-lua-key-runtime"
  assert(os.execute("mkdir -p " .. string.format("%q", temp_dir)) == true or os.execute("test -d " .. string.format("%q", temp_dir)) == 0)
  local key_path = temp_dir .. "/key.json"
  local key_file = assert(io.open(key_path, "wb"))
  key_file:write('{"key":' .. quote_json(old_key) .. "}")
  key_file:close()

  local source = production_source
  source = source:gsub('local KEY_DIR = "[^"]+"', 'local KEY_DIR = "' .. temp_dir .. '"', 1)
  -- Do not execute game-specific Main Lua in the harness. These replacements
  -- only record the exact moment at which the wrapper would continue.
  source = source:gsub("on_authorized%(validated_response, validated_key%)", "_G.__saved_key_runtime_authorized = validated_response", 1)
  source = source:gsub("on_authorized%(validated_response%)", "_G.__saved_key_runtime_authorized = validated_response", 1)
  source = source:gsub("on_authorized%(response%)", "_G.__saved_key_runtime_authorized = response", 1)

  _G.json = make_json_adapter()
  _G.__saved_key_runtime_submit = nil
  _G.__saved_key_runtime_callback = nil
  _G.__saved_key_runtime_request_body = nil
  _G.__saved_key_runtime_request_count = 0
  _G.__saved_key_runtime_notice = nil
  _G.__saved_key_runtime_authorized = nil
  _G.__LuaLicenseKeyEntryProductionV1Opened = nil

  local response_event = {}
  function response_event:Add(callback)
    _G.__saved_key_runtime_callback = callback
  end

  local wrapper = { OnResponseEvent = response_event }
  function wrapper:RequestForLua(_url, _method, _headers, body, _a, _b)
    _G.__saved_key_runtime_request_count = _G.__saved_key_runtime_request_count + 1
    if _G.__saved_key_runtime_request_count == 1 then
      _G.__saved_key_runtime_request_body = body
    end
    return 72 + _G.__saved_key_runtime_request_count
  end

  _G.slua_GameFrontendHUD = {
    GetHttpWrapper = function()
      return wrapper
    end,
  }
  _G.UIManager = {
    ShowUIWithLuaAndBpPath = function(_config, _module, _path, _initial_key, submit_key)
      _G.__saved_key_runtime_submit = submit_key
      return { mocked = true }
    end,
  }
  _G.TOAST = function(text)
    _G.__saved_key_runtime_notice = text
  end

  local chunk, load_error = load(source, "@BRPlayerCharacterBase-Merged.runtime.lua")
  assert(chunk, load_error)
  chunk()
  assert(type(_G.__saved_key_runtime_submit) == "function", case_name .. " did not expose the existing key submit callback")

  _G.__saved_key_runtime_submit(entered_key)
  assert(type(_G.__saved_key_runtime_callback) == "function", case_name .. " did not register the existing validation callback")
  assert(type(_G.__saved_key_runtime_request_body) == "string" and _G.__saved_key_runtime_request_body:find(entered_key, 1, true), case_name .. " did not validate the entered key")

  local callback_ok
  if response_kind == "network_failure" then
    callback_ok = pcall(function()
      _G.__saved_key_runtime_callback(73, 0, "", "", false, 0)
    end)
  else
    local encoded_result = response_kind == "valid" and "__VALID__" or (response_kind == "expired" and "__EXPIRED__" or "__INVALID__")
    callback_ok = pcall(function()
      _G.__saved_key_runtime_callback(73, 0, encoded_result, "", true, 200)
      if response_kind == "valid" then
        assert_equal(_G.__saved_key_runtime_request_count, 2, case_name .. " did not make the separate maintenance request")
        _G.__saved_key_runtime_callback(74, 0, maintenance_active and "__MAINTENANCE_ACTIVE__" or "__MAINTENANCE_OFF__", "", true, 200)
      end
    end)
  end

  assert_equal(callback_ok, expected_callback_ok, case_name .. " callback result")
  assert_equal(read_file(key_path), '{"key":' .. quote_json(expected_saved_key) .. "}", case_name .. " saved key file")
  if expected_authorized then
    assert(type(_G.__saved_key_runtime_authorized) == "table", case_name .. " must reach the authorized continuation after writing the entered key")
  else
    assert_equal(_G.__saved_key_runtime_authorized, nil, case_name .. " must not reach authorized continuation")
  end
  if maintenance_active then
    assert_equal(_G.__saved_key_runtime_notice, "[LICENSE] Please wait... ⏳", case_name .. " exact maintenance message")
  end

  os.execute("rm -rf " .. string.format("%q", temp_dir))
end

run_case("expired old key plus valid entered key", "EXPIRED-OLD-KEY", "VALID-NEW-KEY", "valid", "VALID-NEW-KEY", true, true, false)
run_case("valid old key plus valid entered key", "VALID-OLD-KEY", "VALID-NEW-KEY", "valid", "VALID-NEW-KEY", true, true, false)
run_case("invalid entered key preserves old key", "VALID-OLD-KEY", "INVALID-NEW-KEY", "invalid", "VALID-OLD-KEY", false, false, false)
run_case("expired entered key preserves old key", "VALID-OLD-KEY", "EXPIRED-NEW-KEY", "expired", "VALID-OLD-KEY", false, false, false)
run_case("network failure preserves old key", "VALID-OLD-KEY", "VALID-NEW-KEY", "network_failure", "VALID-OLD-KEY", false, false, false)
run_case("active maintenance blocks main Lua after valid entered key", "EXPIRED-OLD-KEY", "VALID-NEW-KEY", "valid", "VALID-NEW-KEY", true, false, true)

print("LUA_SAVED_KEY_RUNTIME_HARNESS_PASS")
