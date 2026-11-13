-- STANDALONE B-SIDE DIAGNOSTIC ONLY — do not merge into the production loader.
-- It identifies one non-secret stage only. It never writes key.json, .device_id,
-- .license_status, or Main Lua; it never prints key/device/payload/response data.

local API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"
local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local COPIED_TEST_KEY_FILE = KEY_DIR .. "/.a_to_b_test_key.json"
local DEVICE_FILE = KEY_DIR .. "/.device_id"
local RESULT_FILE = KEY_DIR .. "/.a_to_b_b_stage_diagnostic"

local function read_file(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local value = file:read("*a")
  file:close()
  return value
end

local function report(stage)
  local line = "TEST_MODE=B_STAGE\nB_STAGE=" .. stage
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

local function get_existing_b_identity()
  -- Read only B's already-existing identity. Never generate, copy, or write one.
  local provider = rawget(_G, "getPersistentDeviceId") or rawget(_G, "getDeviceId")
  if type(provider) == "function" then
    local ok, value = pcall(provider)
    if ok and type(value) == "string" and value:gsub("%s+", "") ~= "" then return value end
  end
  local existing = read_file(DEVICE_FILE)
  if type(existing) == "string" then
    existing = existing:gsub("%s+$", "")
    if existing ~= "" then return existing end
  end
  return nil
end

local json = get_json()
if not json then
  report("JSON_ADAPTER_UNAVAILABLE")
  return
end

local copied_raw = read_file(COPIED_TEST_KEY_FILE)
if copied_raw == nil then
  report("COPIED_TEST_KEY_UNAVAILABLE")
  return
end

local key = decode_copied_test_key(copied_raw, json)
if not key then
  report("COPIED_TEST_KEY_FORMAT_INVALID")
  return
end

local device_id = get_existing_b_identity()
if not device_id then
  report("B_OWN_IDENTITY_UNAVAILABLE")
  return
end

local payload = json.encode({ key = key, device_id = device_id })
if type(payload) ~= "string" then
  report("REQUEST_PAYLOAD_UNAVAILABLE")
  return
end

local hud = rawget(_G, "slua_GameFrontendHUD")
if (type(hud) ~= "table" and type(hud) ~= "userdata") or type(hud.GetHttpWrapper) ~= "function" then
  report("HTTP_HOST_UNAVAILABLE")
  return
end

local wrapper_ok, http_wrapper = pcall(hud.GetHttpWrapper, hud)
if not wrapper_ok or (type(http_wrapper) ~= "table" and type(http_wrapper) ~= "userdata") or type(http_wrapper.RequestForLua) ~= "function" then
  report("HTTP_WRAPPER_UNAVAILABLE")
  return
end

local response_event = http_wrapper.OnResponseEvent
if (type(response_event) ~= "table" and type(response_event) ~= "userdata") or type(response_event.Add) ~= "function" then
  report("RESPONSE_EVENT_UNAVAILABLE")
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
      report("TRANSPORT_RESPONSE_UNUSABLE")
      return
    end
    local decoded_ok, response = pcall(json.decode, data)
    if not decoded_ok or type(response) ~= "table" or type(response.status) ~= "string" then
      report("CANONICAL_RESPONSE_INVALID")
      return
    end
    if response.success == true and response.status == "valid" then
      report("CANONICAL_ACCEPTED")
    else
      report("CANONICAL_REJECTED")
    end
  end)
end)
if not registered then
  report("CALLBACK_REGISTER_FAILED")
  return
end

local request_ok, returned_index = pcall(function()
  return http_wrapper:RequestForLua(API_URL, "POST", headers, payload, 0, 0)
end)
if not request_ok or returned_index == nil or returned_index == 0 then
  report("REQUEST_DISPATCH_FAILED")
  return
end

request_index = returned_index
report("REQUEST_DISPATCHED")
