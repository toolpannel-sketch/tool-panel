-- PhoneDeviceIdRestartProbe.lua
--
-- STANDALONE TEST ARTIFACT ONLY. Do not merge this file into the production
-- Merged loader or any main Lua. It never reads or writes key.json,
-- .device_id, .license_status, or any production diagnostic/state file.
--
-- This probe calls only the V3-observed host member:
--   Client.GetPhoneDeviceID()
-- It reports fixed non-secret labels only. The raw returned value is never
-- printed, persisted, transmitted, displayed, or included in the result file.

local LICENSE_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local RESULT_FILE = LICENSE_DIR .. "/.phone_device_id_probe_result"
local STATE_FILE = LICENSE_DIR .. "/.phone_device_id_probe_state"

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

local function comparison_token(value)
  -- Fixed-size, local comparison token only. It is never printed, returned,
  -- or transmitted. This is not a cryptographic proof and is used only to
  -- distinguish same/different return values across the approved two-run test.
  local h = 2166136261
  for i = 1, #value do
    h = (h * 16777619 + value:byte(i)) % 2147483647
  end
  return string.format("v1:%08x", h)
end

local api_available = "false"
local value_present = "false"
local restart_stable = "not_tested"

local client = rawget(_G, "Client")
if type(client) == "table" or type(client) == "userdata" then
  local accessor_ok, candidate = pcall(function()
    return client.GetPhoneDeviceID
  end)

  if accessor_ok == true and type(candidate) == "function" then
    api_available = "true"
    local call_ok, value = pcall(candidate)
    if call_ok == true and type(value) == "string" and #value > 0 then
      value_present = "true"
      local token = comparison_token(value)
      value = nil

      local previous_token = read_file(STATE_FILE)
      if type(previous_token) == "string" and previous_token:match("^v1:%x%x%x%x%x%x%x%x$") then
        restart_stable = previous_token == token and "true" or "false"
      elseif write_file(STATE_FILE, token) then
        restart_stable = "baseline_recorded"
      else
        restart_stable = "baseline_not_saved"
      end
    end
  end
end

local report = table.concat({
  "api_available=" .. api_available,
  "value_present=" .. value_present,
  "restart_stable=" .. restart_stable,
}, "\n")

-- The result includes only the three allowlisted labels. It is separate from
-- the opaque local comparison state and contains no raw or derived value.
write_file(RESULT_FILE, report)
pcall(function()
  print("[PHONE_DEVICE_ID_RESTART_PROBE]\n" .. report)
end)

return report
