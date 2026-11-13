-- BRPlayerCharacterBase-HttpManagerProbe.lua
-- Key-free, bounded verification of the user-authorized public http_manager contract.
-- This probe does not enumerate globals, scan files, execute returned Lua, or use a valid key.

local API_URL = "https://luapanel-8355ybgt.manus.space/v1/validate"
local STATUS_FILE = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.http_manager_probe_status"

local function write_status(message)
  local file = io.open(STATUS_FILE, "wb")
  if file then
    file:write(tostring(message))
    file:close()
  end
end

local function fail(code)
  write_status("HTTP_MANAGER_PROBE_FAILED " .. tostring(code))
end

write_status("HTTP_MANAGER_PROBE_STARTED")

-- Verified in the user-authorized source archive:
-- ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
-- returns an object exposing Post(url, headers, body, ueObj, callback, timeout, priority, queueType).
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
if not ok_manager or type(http_manager) ~= "table" or type(http_manager.Post) ~= "function" then
  fail("http_manager_Post_unavailable")
  return
end

write_status("HTTP_MANAGER_AVAILABLE")

-- Deliberately invalid identity: the request checks only transport and callback behavior.
-- It must never bind a real key or disclose any device identity.
local headers = {
  ["Content-Type"] = "application/json",
  ["Accept-Encoding"] = "identity",
}
local probe_body = '{"key":"HTTP_MANAGER_TRANSPORT_PROBE","device_id":"http_manager_transport_probe"}'

local callback_called = false
local ok_call, request_index = pcall(function()
  return http_manager:Post(API_URL, headers, probe_body, nil, function(success, data, content, result)
    callback_called = true
    local data_bytes = type(data) == "string" and #data or 0
    local content_bytes = type(content) == "string" and #content or 0
    write_status(
      "HTTP_MANAGER_CALLBACK success=" .. tostring(success)
        .. " result=" .. tostring(result)
        .. " data_bytes=" .. tostring(data_bytes)
        .. " content_bytes=" .. tostring(content_bytes)
    )
  end, 8, 0, 0)
end)

if not ok_call then
  fail("Post_call_failed")
  return
end

if request_index == nil or request_index == 0 then
  fail("request_not_accepted index=" .. tostring(request_index))
  return
end

-- This line confirms the call was queued. The later callback overwrites this
-- file with the sanitized response metadata when the host event loop runs it.
if not callback_called then
  write_status("HTTP_MANAGER_REQUEST_ACCEPTED index=" .. tostring(request_index) .. " awaiting_callback")
end
