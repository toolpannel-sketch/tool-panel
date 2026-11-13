-- Key-free transport-only direct HttpWrapper POST probe.
-- Uses only the user-authorized contract:
--   slua_GameFrontendHUD:GetHttpWrapper()
--   HttpWrapper:RequestForLua(url, "POST", headers, content, priority, queueType)
--   HttpWrapper.OnResponseEvent:Add(function(reqIndex, elapsedTime, data, content, success, result) end)
-- It never reads a key, a device ID, or any license data.

local API_URL = "https://luapanel-8355ybgt.manus.space/v1/transport-ping"
local STATUS_FILE = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license/.http_wrapper_direct_post_ping_status"
local REQUEST_BODY = '{"test":"ping"}'
local EXPECTED_RESPONSE = '{"ok":true,"test":"ping"}'
local PRIORITY = 0
local QUEUE_TYPE = 0

local function write_status(message)
  local file = io.open(STATUS_FILE, "wb")
  if file then
    file:write(tostring(message))
    file:close()
  end
end

local function fail(code)
  write_status("HTTP_WRAPPER_DIRECT_POST_PING_FAILED stage=" .. tostring(code))
end

write_status("HTTP_WRAPPER_DIRECT_POST_PING_STARTED")

local hud = rawget(_G, "slua_GameFrontendHUD")
if type(hud) ~= "table" and type(hud) ~= "userdata" then
  fail("hud_missing")
  return
end

if type(hud.GetHttpWrapper) ~= "function" then
  fail("GetHttpWrapper_missing")
  return
end

local ok_wrapper, http_wrapper = pcall(hud.GetHttpWrapper, hud)
if not ok_wrapper or (type(http_wrapper) ~= "table" and type(http_wrapper) ~= "userdata") then
  fail("GetHttpWrapper_failed")
  return
end

if type(http_wrapper.RequestForLua) ~= "function" then
  fail("RequestForLua_missing")
  return
end

local response_event = http_wrapper.OnResponseEvent
if (type(response_event) ~= "table" and type(response_event) ~= "userdata") or type(response_event.Add) ~= "function" then
  fail("OnResponseEvent_Add_missing")
  return
end

local request_index = nil
local callback_registered = false
local headers = {
  ["Content-Type"] = "application/json",
  ["Content-Length"] = tostring(#REQUEST_BODY),
  ["Accept"] = "application/json",
  ["Accept-Encoding"] = "identity",
}

local ok_add = pcall(function()
  response_event:Add(function(reqIndex, elapsedTime, data, content, success, result)
    if request_index == nil or reqIndex ~= request_index then
      return
    end

    local data_bytes = type(data) == "string" and #data or 0
    local content_bytes = type(content) == "string" and #content or 0
    local data_matches_expected = type(data) == "string" and data == EXPECTED_RESPONSE
    local content_matches_expected = type(content) == "string" and content == EXPECTED_RESPONSE
    write_status(
      "HTTP_WRAPPER_DIRECT_POST_PING_CALLBACK"
        .. " request_index=" .. tostring(reqIndex)
        .. " elapsed_time=" .. tostring(elapsedTime)
        .. " success=" .. tostring(success)
        .. " result=" .. tostring(result)
        .. " data_bytes=" .. tostring(data_bytes)
        .. " content_bytes=" .. tostring(content_bytes)
        .. " data_matches_expected=" .. tostring(data_matches_expected)
        .. " content_matches_expected=" .. tostring(content_matches_expected)
    )
  end)
  callback_registered = true
end)

if not ok_add or not callback_registered then
  fail("OnResponseEvent_Add_failed")
  return
end

write_status("HTTP_WRAPPER_DIRECT_POST_PING_EVENT_REGISTERED")

local ok_request, returned_index = pcall(function()
  return http_wrapper:RequestForLua(API_URL, "POST", headers, REQUEST_BODY, PRIORITY, QUEUE_TYPE)
end)

if not ok_request then
  fail("RequestForLua_call_failed")
  return
end

if returned_index == nil or returned_index == 0 then
  fail("request_not_accepted index=" .. tostring(returned_index))
  return
end

request_index = returned_index
write_status("HTTP_WRAPPER_DIRECT_POST_PING_REQUEST_ACCEPTED request_index=" .. tostring(request_index) .. " awaiting_callback")
