-- STANDALONE COPIED-IDENTITY TEST ONLY — do not merge into production Lua.
-- It reads only separately named copied test artifacts. It never overwrites B's
-- normal key.json or .device_id, does not run Main Lua, and emits no secret values.

local API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"
local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local COPIED_TEST_KEY_FILE = KEY_DIR .. "/.a_to_b_test_key.json"
local COPIED_TEST_DEVICE_FILE = KEY_DIR .. "/.a_to_b_test_device_id"
local RESULT_FILE = KEY_DIR .. "/.a_to_b_copied_identity_diagnostic"

local function read_file(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local value = file:read("*a")
  file:close()
  return value
end

local function report(outcome)
  local line = "TEST_MODE=B_COPIED_IDENTITY\nB_COPIED_IDENTITY=" .. outcome
  local file = io.open(RESULT_FILE, "wb")
  if file then
    file:write(line)
    file:close()
  end
  pcall(function() print(line) end)
end

local function get_json()
  local decoder = rawget(_G, "json") or rawget(_G, "cjson")
  if decoder and decoder.decode and decoder.encode then return decoder end
  local ok, module = pcall(require, "cjson.safe")
  if ok and module and module.decode and module.encode then return module end
  ok, module = pcall(require, "cjson")
  if ok and module and module.decode and module.encode then return module end
  return nil
end

local function decode_copied_test_key(raw, json)
  if type(raw) ~= "string" then return nil end
  raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
  if raw == "" or raw:sub(1, 1) ~= "{" then return nil end
  local ok, parsed = pcall(json.decode, raw)
  if ok and type(parsed) == "table" and type(parsed.key) == "string" and parsed.key ~= "" then
    return parsed.key
  end
  return nil
end

local json = get_json()
if not json then
  report("UNDETERMINED")
  return
end

local key = decode_copied_test_key(read_file(COPIED_TEST_KEY_FILE), json)
local copied_device_id = read_file(COPIED_TEST_DEVICE_FILE)
if not key or type(copied_device_id) ~= "string" then
  report("UNDETERMINED")
  return
end

copied_device_id = copied_device_id:gsub("%s+$", "")
if copied_device_id == "" then
  report("UNDETERMINED")
  return
end

local payload = json.encode({ key = key, device_id = copied_device_id })
if type(payload) ~= "string" then
  report("UNDETERMINED")
  return
end

local hud = rawget(_G, "slua_GameFrontendHUD")
if (type(hud) ~= "table" and type(hud) ~= "userdata") or type(hud.GetHttpWrapper) ~= "function" then
  report("UNDETERMINED")
  return
end

local wrapper_ok, http_wrapper = pcall(hud.GetHttpWrapper, hud)
if not wrapper_ok or (type(http_wrapper) ~= "table" and type(http_wrapper) ~= "userdata") or type(http_wrapper.RequestForLua) ~= "function" then
  report("UNDETERMINED")
  return
end

local response_event = http_wrapper.OnResponseEvent
if (type(response_event) ~= "table" and type(response_event) ~= "userdata") or type(response_event.Add) ~= "function" then
  report("UNDETERMINED")
  return
end

local request_index = nil
local headers = {
  ["Content-Type"] = "application/json",
  ["Content-Length"] = tostring(#payload),
  ["Accept"] = "application/json",
  ["Accept-Encoding"] = "identity",
}

local registered = pcall(function()
  response_event:Add(function(req_index, _, data, _, success, result)
    if request_index == nil or req_index ~= request_index then return end
    if success ~= true or tonumber(result) ~= 200 or type(data) ~= "string" or #data == 0 then
      report("UNDETERMINED")
      return
    end
    local decoded_ok, response = pcall(json.decode, data)
    if not decoded_ok or type(response) ~= "table" or type(response.status) ~= "string" then
      report("UNDETERMINED")
      return
    end
    if response.success == true and response.status == "valid" then
      report("ACCEPTED")
    else
      report("REJECTED")
    end
  end)
end)
if not registered then
  report("UNDETERMINED")
  return
end

local request_ok, returned_index = pcall(function()
  return http_wrapper:RequestForLua(API_URL, "POST", headers, payload, 0, 0)
end)
if not request_ok or returned_index == nil or returned_index == 0 then
  report("UNDETERMINED")
  return
end

request_index = returned_index
