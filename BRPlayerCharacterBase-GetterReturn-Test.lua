-- BRPlayerCharacterBase-GetterReturn-Test.lua
-- One-time diagnostic only. It invokes only selected zero-argument getter candidates
-- inside pcall. It never invokes Connect, Disconnect, OpenURLInSDK, download,
-- packet, callback, license, or main-feature methods.

local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local REPORT_FILE = KEY_DIR .. "/.getter_return_probe"
local MAX = 1200
local lines = {}

local function add(line)
  if #lines < MAX then lines[#lines + 1] = line end
end

local function safe_text(value)
  local kind = type(value)
  if kind == "string" then
    local text = value:gsub("[%z\1-\8\11\12\14-\31]", "?")
    text = text:gsub("\r", "\\r"):gsub("\n", "\\n")
    if #text > 240 then text = text:sub(1, 240) .. "..." end
    return "string:" .. text
  end
  if kind == "number" or kind == "boolean" then return kind .. ":" .. tostring(value) end
  if value == nil then return "nil" end
  return kind
end

local function probe_zero_arg(label, fn)
  if type(fn) ~= "function" then
    add(label .. " [" .. type(fn) .. "]")
    return
  end
  local ok, a, b, c = pcall(fn)
  if not ok then
    add(label .. " call_error [" .. safe_text(a) .. "]")
    return
  end
  add(label .. " call_ok [" .. safe_text(a) .. "] [" .. safe_text(b) .. "] [" .. safe_text(c) .. "]")
end

add("GETTER_RETURN_PROBE_V1")
add("Only selected zero-argument getter candidates were invoked inside pcall.")
add("No license key, device ID, URL request, Connect, OpenURLInSDK, download, callback, or main Lua was invoked.")

local client = rawget(_G, "ScriptHelperClient")
if type(client) ~= "table" then
  add("ScriptHelperClient [" .. type(client) .. "]")
else
  probe_zero_arg("ScriptHelperClient.GameMasterGetWebUIUrl", rawget(client, "GameMasterGetWebUIUrl"))
  probe_zero_arg("ScriptHelperClient.GetFileDirPath", rawget(client, "GetFileDirPath"))
end

local function write_report()
  local file = io.open(REPORT_FILE, "wb")
  if not file then return end
  file:write(table.concat(lines, "\n"))
  file:write("\n")
  file:close()
end

write_report()
return
