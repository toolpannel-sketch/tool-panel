-- BRPlayerCharacterBase-HttpManagerPostPingProbe.lua
-- Key-free transport-only POST probe for the panel's public /v1/transport-ping endpoint.
-- It uses only the authorized http_manager:Post callback contract and never validates a license.

local API_URL = "https://luapanel-8355ybgt.manus.space/v1/transport-ping"
local STATUS_FILE = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.http_manager_post_ping_status"
local TIMEOUT_SECONDS = 45

local function write_status(message)
  local file = io.open(STATUS_FILE, "wb")
  if file then
    file:write(tostring(message))
    file:close()
  end
end

local function fail(code)
  write_status("HTTP_MANAGER_POST_PING_FAILED " .. tostring(code))
end

write_status("HTTP_MANAGER_POST_PING_STARTED timeout=" .. tostring(TIMEOUT_SECONDS))

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

local body = '{"test":"ping"}'
local expected_response = '{"ok":true,"test":"ping"}'
local headers = {
  ["Content-Type"] = "application/json",
  ["Content-Length"] = tostring(#body),
  ["Accept"] = "application/json",
  ["Accept-Encoding"] = "identity",
}

local callback_called = false
local ok_call, request_index = pcall(function()
  return http_manager:Post(API_URL, headers, body, nil, function(success, data, content, result)
    callback_called = true
    local data_bytes = type(data) == "string" and #data or 0
    local content_bytes = type(content) == "string" and #content or 0
    local data_matches_expected = type(data) == "string" and data == expected_response
    local content_matches_expected = type(content) == "string" and content == expected_response
    write_status(
      "HTTP_MANAGER_POST_PING_CALLBACK success=" .. tostring(success)
        .. " result=" .. tostring(result)
        .. " data_bytes=" .. tostring(data_bytes)
        .. " content_bytes=" .. tostring(content_bytes)
        .. " data_matches_expected=" .. tostring(data_matches_expected)
        .. " content_matches_expected=" .. tostring(content_matches_expected)
    )
  end, TIMEOUT_SECONDS, 0, 0)
end)

if not ok_call then
  fail("Post_call_failed")
  return
end

if request_index == nil or request_index == 0 then
  fail("request_not_accepted index=" .. tostring(request_index))
  return
end

if not callback_called then
  write_status("HTTP_MANAGER_POST_PING_REQUEST_ACCEPTED index=" .. tostring(request_index) .. " awaiting_callback")
end
