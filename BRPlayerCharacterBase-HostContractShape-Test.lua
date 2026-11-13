-- BRPlayerCharacterBase-HostContractShape-Test.lua
-- One-time diagnostic only. It never invokes Connect, Disconnect, URL, download,
-- callback, delegate, packet, or any other host-native method.

local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local REPORT_FILE = KEY_DIR .. "/.host_contract_shape"

local function write_report(lines)
  local file = io.open(REPORT_FILE, "wb")
  if not file then return end
  file:write("HOST_CONTRACT_SHAPE_V1\n")
  file:write(table.concat(lines, "\n"))
  file:write("\n")
  file:close()
end

local lines = {}
local function add(line)
  if #lines < 1200 then lines[#lines + 1] = line end
end

add("No candidate method, callback, delegate, network, URL, download, packet, or game API was invoked.")

local function describe_function(label, value)
  if type(value) ~= "function" then
    add(label .. " [" .. type(value) .. "]")
    return
  end
  add(label .. " [function]")
  local debug_api = rawget(_G, "debug")
  local getinfo = type(debug_api) == "table" and rawget(debug_api, "getinfo") or nil
  if type(getinfo) ~= "function" then
    add("  " .. label .. " metadata [debug.getinfo missing]")
    return
  end
  local ok_info, info = pcall(getinfo, value, "Snu")
  if not ok_info or type(info) ~= "table" then
    add("  " .. label .. " metadata [unavailable]")
    return
  end
  local fields = { "what", "source", "short_src", "linedefined", "lastlinedefined", "nparams", "isvararg", "namewhat" }
  for _, field in ipairs(fields) do
    local field_value = info[field]
    if field_value ~= nil then
      add("  " .. label .. "." .. field .. " [" .. tostring(field_value) .. "]")
    end
  end
end

local function describe_table_member(table_name, table_value, member_name)
  if type(table_value) ~= "table" then
    add(table_name .. " [" .. type(table_value) .. "]")
    return
  end
  local member_value = rawget(table_value, member_name)
  if member_value == nil then
    add(table_name .. "." .. member_name .. " [missing]")
  else
    describe_function(table_name .. "." .. member_name, member_value)
  end
end

local net_interface = rawget(_G, "ScriptHelperNetInterface")
add("Selected global surfaces:")
describe_table_member("ScriptHelperNetInterface", net_interface, "Connect")
describe_table_member("ScriptHelperNetInterface", net_interface, "Disconnect")

local client = rawget(_G, "ScriptHelperClient")
local client_members = {
  "GameMasterGetWebUIUrl",
  "GetFileDirPath",
  "LoadFileToStringByFullPath",
  "LoadH5FromCache",
  "LoadSavedFileToStringArray",
  "OpenURLInSDK",
  "SaveStringToIntermediateFile",
  "StopH5Downloading",
  "DeleteFile",
  "IsFileExistsWithPakCheckMatchExt",
}
for _, member_name in ipairs(client_members) do
  describe_table_member("ScriptHelperClient", client, member_name)
end

local function describe_metatable(label, value)
  local getmetatable_api = rawget(_G, "getmetatable")
  if type(getmetatable_api) ~= "function" then
    add(label .. " metatable [getmetatable missing]")
    return
  end
  local ok_meta, meta = pcall(getmetatable_api, value)
  if not ok_meta or meta == nil then
    add(label .. " metatable [missing/unavailable]")
    return
  end
  add(label .. " metatable [" .. type(meta) .. "]")
  if type(meta) == "table" then
    local keys = {}
    local ok_pairs, iterator, state, initial = pcall(pairs, meta)
    if ok_pairs then
      for key, member in iterator, state, initial do
        if type(key) == "string" then
          keys[#keys + 1] = key .. " [" .. type(member) .. "]"
        end
        if #keys >= 80 then break end
      end
    end
    table.sort(keys)
    for _, key in ipairs(keys) do add("  " .. label .. ".metatable." .. key) end
  end
end

describe_metatable("ScriptHelperNetInterface", net_interface)
describe_metatable("ScriptHelperClient", client)

add("Interpretation:")
add("Metadata and metatable structure do not reveal native argument, callback, or response contracts.")
add("A license adapter requires a documented host-side request and response contract and must preserve server validation and fail-closed errors.")
write_report(lines)
return
