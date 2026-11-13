-- STANDALONE B-ONLY IDENTITY INITIALIZER — do not merge into production Lua.
-- It creates only B's local random .device_id when no approved provider or
-- existing device file is available. It never reads a key, contacts a server,
-- validates a license, runs Main Lua, or accesses Device A data.

local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local DEVICE_FILE = KEY_DIR .. "/.device_id"
local RESULT_FILE = KEY_DIR .. "/.b_identity_initializer"
local FOLDER_ENSURE_FILE = KEY_DIR .. "/.lua_license_folder_ready"
local FOLDER_ENSURE_MARKER = "LUA_LICENSE_FOLDER_READY_V1"

local function read_file(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local value = file:read("*a")
  file:close()
  return value
end

local function write_file(path, value)
  local file = io.open(path, "wb")
  if not file then return false end
  file:write(value)
  file:close()
  return true
end

local function report(state)
  local line = "TEST_MODE=B_IDENTITY_INITIALIZER\nB_IDENTITY=" .. state
  pcall(function() write_file(RESULT_FILE, line) end)
  pcall(function() print(line) end)
end

local function ensure_folder()
  local client = rawget(_G, "Client")
  if type(client) ~= "table" and type(client) ~= "userdata" then return false end
  local ok, writer = pcall(function() return client.WriteFileAtPath end)
  if not ok or type(writer) ~= "function" then return false end
  if not pcall(writer, FOLDER_ENSURE_FILE, FOLDER_ENSURE_MARKER) then return false end
  return read_file(FOLDER_ENSURE_FILE) == FOLDER_ENSURE_MARKER
end

if ensure_folder() ~= true then
  report("STORAGE_UNAVAILABLE")
  return
end

local provider = rawget(_G, "getPersistentDeviceId") or rawget(_G, "getDeviceId")
if type(provider) == "function" then
  local provider_ok, provider_value = pcall(provider)
  if provider_ok and type(provider_value) == "string" and provider_value:gsub("%s+", "") ~= "" then
    report("PROVIDER_READY")
    return
  end
end

local existing = read_file(DEVICE_FILE)
if type(existing) == "string" and existing:gsub("%s+", "") ~= "" then
  report("EXISTING")
  return
end

-- This is the current Merged loader's existing 32-hex random fallback format.
math.randomseed(os.time() + math.floor(os.clock() * 100000))
local alphabet = "0123456789abcdef"
local chars = {}
for i = 1, 32 do
  local n = math.random(#alphabet)
  chars[i] = alphabet:sub(n, n)
end

if write_file(DEVICE_FILE, table.concat(chars)) then
  report("CREATED")
else
  report("WRITE_FAILED")
end
