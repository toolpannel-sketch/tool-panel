-- LuaLicenseFolderCapabilityProbe.lua
--
-- STANDALONE TEST ARTIFACT ONLY. Do not merge this file into
-- BRPlayerCharacterBase-Merged.lua or any production/main Lua.
--
-- It performs no network, validation, UI, device, key, status, Maintenance,
-- Announcement, Telegram, or Main Lua action. The only intended side effect is
-- a non-secret result file at the fixed probe path below if the observed host
-- writer can make that path writable.

local LICENSE_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local PROBE_RESULT_PATH = LICENSE_DIR .. "/.lua_license_folder_probe"
local MARKER = "LUA_LICENSE_FOLDER_PROBE_MARKER_V1"

local function read_file(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local data = file:read("*a")
  file:close()
  return data
end

local function write_file(path, data)
  local file = io.open(path, "wb")
  if not file then return false end
  file:write(data)
  file:close()
  return true
end

-- The directory itself cannot be queried safely because V3 provided no proven
-- DirectoryExists-style API. A pre-existing probe file does prove the folder
-- exists; otherwise this remains intentionally "not_proven".
local existing_probe = read_file(PROBE_RESULT_PATH)
local directory_exists = existing_probe ~= nil
  and "confirmed_by_existing_probe_file"
  or "not_proven_no_directory_query"

local create_supported = "unavailable"
local create_result = "not_attempted"
local verify_result = "not_attempted"

-- V3 statically observed this exact dot-call shape:
-- Client.WriteFileAtPath(fullPath, contents)
-- No return-value semantics or parent-creation behavior is assumed here.
local client = rawget(_G, "Client")
local writer = nil
if type(client) == "table" or type(client) == "userdata" then
  local accessor_ok, candidate = pcall(function()
    return client.WriteFileAtPath
  end)
  if accessor_ok and type(candidate) == "function" then
    writer = candidate
    create_supported = "available"
  end
end

if writer then
  -- This writes no key, device ID, token, URL, response, or user data.
  -- A clean test profile with no existing lua-license folder is required to
  -- establish whether the host creates the missing parent directory.
  local call_ok = pcall(writer, PROBE_RESULT_PATH, MARKER)
  create_result = call_ok and "call_completed" or "call_error"

  if call_ok then
    local verification = read_file(PROBE_RESULT_PATH)
    verify_result = verification == MARKER
      and "marker_readable"
      or "marker_not_readable"
  end
end

local report = table.concat({
  "path_available=true",
  "directory_exists=" .. directory_exists,
  "create_supported=" .. create_supported,
  "create_result=" .. create_result,
  "verify_result=" .. verify_result,
}, "\n")

-- Persist only the five fixed result labels when the candidate has made the
-- exact target path writable. If this fails, print still exposes the same
-- non-secret report; no raw error text is retained.
if verify_result == "marker_readable" then
  write_file(PROBE_RESULT_PATH, report)
end

pcall(function()
  print("[LUA_LICENSE_FOLDER_PROBE]\n" .. report)
end)

return report
