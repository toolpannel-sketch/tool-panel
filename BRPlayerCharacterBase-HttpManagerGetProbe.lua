-- BRPlayerCharacterBase-HttpManagerGetProbe.lua
-- Key-free reachability probe for the panel's public GET /v1/transport-ping endpoint.
-- It uses only the documented user-authorized http_manager:Get contract.

local API_URL = "https://luapanel-8355ybgt.manus.space/v1/transport-ping"
local STATUS_FILE = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.http_manager_get_probe_status"
local TIMEOUT_SECONDS = 45

local function write_status(message)
  local file = io.open(STATUS_FILE, "wb")
  if file then
    file:write(tostring(message))
    file:close()
  end
end

local function fail(code)
  write_status("HTTP_MANAGER_GET_PROBE_FAILED " .. tostring(code))
end

write_status("HTTP_MANAGER_GET_PROBE_STARTED timeout=" .. tostring(TIMEOUT_SECONDS))

local module_manager = rawget(_G, "ModuleManager")
if type(module_manager) ~= "table" or type(module_manager.GetModule) ~= "function" then
  fail("ModuleManager_missing")
  return
end

local common_config = module_manager.CommonModuleConfig
if type(common_config) ~= "table" or common_config.http_manager == nil then
  fail("CommonModuleConfig_http_manager_missing")
  return
end

local ok_manager, http_manager = pcall(module_manager.GetModule, common_config.http_manager)
if not ok_manager or type(http_manager) ~= "table" or type(http_manager.Get) ~= "function" then
  fail("http_manager_Get_unavailable")
  return
end

local headers = {
  ["Accept"] = "application/json",
  ["Accept-Encoding"] = "identity",
}

local callback_called = false
local ok_call, request_index = pcall(function()
  return http_manager:Get(API_URL, headers, "", nil, function(success, data, content, result)
    callback_called = true
    local data_bytes = type(data) == "string" and #data or 0
    local content_bytes = type(content) == "string" and #content or 0
    local panel_ok = (type(data) == "string" and data:find('"ok":true', 1, true) ~= nil)
      or (type(content) == "string" and content:find('"ok":true', 1, true) ~= nil)
    write_status(
      "HTTP_MANAGER_GET_CALLBACK success=" .. tostring(success)
        .. " result=" .. tostring(result)
        .. " data_bytes=" .. tostring(data_bytes)
        .. " content_bytes=" .. tostring(content_bytes)
        .. " panel_ok=" .. tostring(panel_ok)
    )
  end, TIMEOUT_SECONDS, 0, 0)
end)

if not ok_call then
  fail("Get_call_failed")
  return
end

if request_index == nil or request_index == 0 then
  fail("request_not_accepted index=" .. tostring(request_index))
  return
end

if not callback_called then
  write_status("HTTP_MANAGER_GET_REQUEST_ACCEPTED index=" .. tostring(request_index) .. " awaiting_callback")
end
