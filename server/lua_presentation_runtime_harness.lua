-- Controlled runtime harness for the production wrapper’s presentation-only path.
-- It stubs only documented host-facing surfaces and never sends HTTP traffic.

local source_path = assert(arg[1], "production Lua source path is required")
local source_file = assert(io.open(source_path, "rb"))
local production_source = source_file:read("*a")
source_file:close()
local is_merged_source = source_path:find("BRPlayerCharacterBase%-Merged%.lua", 1, false) ~= nil
local expected_maintenance_method = source_path:find("BRPlayerCharacterBase%-Merged%.lua", 1, false) and "POST" or "GET"
local expected_announcement_method = source_path:find("BRPlayerCharacterBase%-Merged%.lua", 1, false) and "POST" or "GET"

local function quote_json(value)
  return string.format("%q", tostring(value))
end

local function assert_equal(actual, expected, label)
  if actual ~= expected then error(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual)) end
end

local function assert_contains(value, expected, label)
  if type(value) ~= "string" or not value:find(expected, 1, true) then error(label .. " expected to include=" .. expected .. " actual=" .. tostring(value)) end
end

local function read_text(path)
  local file = assert(io.open(path, "rb"), "missing diagnostic file: " .. path)
  local value = file:read("*a")
  file:close()
  return value
end

local function make_json_adapter()
  return {
    encode = function(value)
      if type(value) ~= "table" then error("unexpected JSON encode type") end
      if type(value.ticket) == "string" and type(value.device_id) == "string" then
        return '{"ticket":' .. quote_json(value.ticket) .. ',"device_id":' .. quote_json(value.device_id) .. "}"
      end
      if type(value.key) == "string" and type(value.device_id) == "string" then
        return '{"key":' .. quote_json(value.key) .. ',"device_id":' .. quote_json(value.device_id) .. "}"
      end
      if type(value.key) == "string" then return '{"key":' .. quote_json(value.key) .. "}" end
      if next(value) == nil then return "{}" end
      error("unexpected JSON encode shape")
    end,
    decode = function(value)
      if value == "__VALID__" then return { status = "valid", success = true, expiresAt = "2030-01-01T00:00:00.000Z" } end
      if value == "__MAINTENANCE_OFF__" then return { active = false } end
      if value == "__ANNOUNCEMENT_ACTIVE__" then return { active = true, version = 11, title = "SYSTEM ANNOUNCEMENT", message = "Join the official Telegram channel.", displayMode = "every_login", textSize = "normal" } end
      if value == "__TELEGRAM_TICKET__" then return { enabled = true, ticket = "test-ticket" } end
      if value == "__TELEGRAM_REDEEM__" then return { enabled = true, channelUrl = "https://t.me/example_channel" } end
      error("unexpected JSON decode payload=" .. tostring(value))
    end,
  }
end

local temp_dir = os.tmpname() .. "-lua-presentation-runtime"
assert(os.execute("mkdir -p " .. string.format("%q", temp_dir)) == true or os.execute("test -d " .. string.format("%q", temp_dir)) == 0)

local source = production_source:gsub('local KEY_DIR = "[^"]+"', 'local KEY_DIR = "' .. temp_dir .. '"', 1)
_G.json = make_json_adapter()
_G.getPersistentDeviceId = function() return "presentation-device-id" end
_G.__LuaLicenseKeyEntryProductionV1Opened = nil
_G.__presentation_submit = nil
_G.__presentation_requests = {}
_G.__presentation_popup_callback = nil
_G.__presentation_popup_title = nil
_G.__presentation_popup_message = nil
_G.__presentation_redirect_url = nil

local response_event = { callbacks = {} }
function response_event:Add(callback)
  self.callbacks[#self.callbacks + 1] = callback
end

local wrapper = { OnResponseEvent = response_event }
function wrapper:RequestForLua(url, method, _headers, body, _a, _b)
  local request_index = 100 + #_G.__presentation_requests + 1
  _G.__presentation_requests[#_G.__presentation_requests + 1] = { index = request_index, url = url, method = method, body = body }
  return request_index
end

local function dispatch(request_index, payload)
  for _, callback in ipairs(response_event.callbacks) do callback(request_index, 0, payload, "", true, 200) end
end

_G.slua_GameFrontendHUD = {
  GetHttpWrapper = function() return wrapper end,
  GetPlayerController = function() return nil end,
}
_G.slua = { isValid = function() return false end }
_G.UIManager = {
  ShowUIWithLuaAndBpPath = function(_config, _module, _path, _initial_key, submit_key)
    _G.__presentation_submit = submit_key
    return { mocked = true }
  end,
}
if is_merged_source then
  -- Controlled equivalent of the Android-proven dot-call writer. This harness
  -- uses a temp directory and never invokes a device host or production path.
  _G.Client = {
    WriteFileAtPath = function(full_path, contents)
      local file = assert(io.open(full_path, "wb"))
      file:write(contents)
      file:close()
      return true
    end,
  }
else
  _G.Client = nil
end
_G.TOAST = function() end
package.loaded["client.slua.logic.common.logic_common_msg_box"] = {
  Show = function(_mode, title, message, callback)
    _G.__presentation_popup_title = title
    _G.__presentation_popup_message = message
    _G.__presentation_popup_callback = callback
  end,
}
package.loaded["client.slua.logic.url.logic_webview_sdk"] = {
  OpenURL = function(_self, url) _G.__presentation_redirect_url = url end,
}

local chunk, load_error = load(source, "@BRPlayerCharacterBase-Reusable.presentation.lua")
assert(chunk, load_error)
chunk()
if is_merged_source then
  assert_equal(read_text(temp_dir .. "/.lua_license_folder_ready"), "LUA_LICENSE_FOLDER_READY_V1", "Folder ensure marker")
end
assert(type(_G.__presentation_submit) == "function", "key-entry UI did not expose submit callback")

local submitted_key = "VALID-PRESENTATION-KEY"
_G.__presentation_submit(submitted_key)
assert_equal(#_G.__presentation_requests, 1, "validation request count")
assert_equal(_G.__presentation_requests[1].url, "https://luapanel-8355ybgt.manus.space/api/license/validate", "validation URL")
assert_contains(_G.__presentation_requests[1].body, submitted_key, "validation payload")

dispatch(101, "__VALID__")
assert_equal(#_G.__presentation_requests, 2, "Maintenance request count")
assert_equal(_G.__presentation_requests[2].url, "https://luapanel-8355ybgt.manus.space/api/maintenance/active", "Maintenance URL")
assert_equal(_G.__presentation_requests[2].method, expected_maintenance_method, "Maintenance method")
if expected_maintenance_method == "POST" then
  assert_equal(_G.__presentation_requests[2].body, "{}", "Maintenance key-free POST body")
end
if is_merged_source then
  local saved_key_diagnostic = read_text(temp_dir .. "/.saved_key_diagnostic")
  assert_contains(saved_key_diagnostic, "input_source=event", "Saved-key diagnostic source")
  assert_contains(saved_key_diagnostic, "input_length=" .. tostring(#submitted_key), "Saved-key diagnostic length")
  assert_contains(saved_key_diagnostic, "validation_status=valid", "Saved-key diagnostic status")
  assert(not saved_key_diagnostic:find(submitted_key, 1, true), "Saved-key diagnostic must not contain key")
  assert(not saved_key_diagnostic:find("presentation-device-id", 1, true), "Saved-key diagnostic must not contain device ID")
end

dispatch(102, "__MAINTENANCE_OFF__")
assert_equal(#_G.__presentation_requests, 3, "Announcement request count")
assert_equal(_G.__presentation_requests[3].url, "https://luapanel-8355ybgt.manus.space/api/announcement/active", "Announcement URL")
assert_equal(_G.__presentation_requests[3].method, expected_announcement_method, "Announcement method")
if expected_announcement_method == "POST" then
  assert_equal(_G.__presentation_requests[3].body, "{}", "Announcement key-free POST body")
end

dispatch(103, "__ANNOUNCEMENT_ACTIVE__")
assert_equal(#_G.__presentation_requests, 4, "Telegram ticket request count")
assert_equal(_G.__presentation_requests[4].url, "https://luapanel-8355ybgt.manus.space/api/telegram/ticket", "Telegram ticket URL")
assert_contains(_G.__presentation_requests[4].body, submitted_key, "Telegram ticket uses the validated submitted key")

dispatch(104, "__TELEGRAM_TICKET__")
assert_equal(_G.__presentation_popup_title, "SYSTEM ANNOUNCEMENT", "Announcement popup title")
assert_equal(_G.__presentation_popup_message, "Join the official Telegram channel.", "Announcement popup message")
assert(type(_G.__presentation_popup_callback) == "function", "Announcement popup must expose the explicit OK callback")
if is_merged_source then
  local telegram_diagnostic = read_text(temp_dir .. "/.telegram_redirect_diagnostic")
  assert_contains(telegram_diagnostic, "TICKET_PRESENT", "Telegram diagnostic ticket marker")
  assert(not telegram_diagnostic:find("test-ticket", 1, true), "Telegram diagnostic must not contain ticket")
end

_G.__presentation_popup_callback()
assert_equal(#_G.__presentation_requests, 5, "Telegram redeem request count")
assert_equal(_G.__presentation_requests[5].url, "https://luapanel-8355ybgt.manus.space/api/telegram/redeem", "Telegram redeem URL")

dispatch(105, "__TELEGRAM_REDEEM__")
assert_equal(_G.__presentation_redirect_url, "https://t.me/example_channel", "Telegram redirect URL")
if is_merged_source then
  local telegram_diagnostic = read_text(temp_dir .. "/.telegram_redirect_diagnostic")
  assert_contains(telegram_diagnostic, "OK_CALLBACK", "Telegram diagnostic OK marker")
  assert_contains(telegram_diagnostic, "TICKET_PRESENT", "Telegram diagnostic ticket marker")
  assert_contains(telegram_diagnostic, "REDEEM_CHANNEL_PRESENT", "Telegram diagnostic channel marker")
  assert_contains(telegram_diagnostic, "OPEN_URL_AVAILABLE", "Telegram diagnostic OpenURL marker")
  assert(not telegram_diagnostic:find(submitted_key, 1, true), "Telegram diagnostic must not contain key")
  assert(not telegram_diagnostic:find("presentation-device-id", 1, true), "Telegram diagnostic must not contain device ID")
  assert(not telegram_diagnostic:find("test-ticket", 1, true), "Telegram diagnostic must not contain ticket")
  assert(not telegram_diagnostic:find("https://t.me/example_channel", 1, true), "Telegram diagnostic must not contain channel URL")
end

os.execute("rm -rf " .. string.format("%q", temp_dir))
print("LUA_PRESENTATION_RUNTIME_HARNESS_PASS")
