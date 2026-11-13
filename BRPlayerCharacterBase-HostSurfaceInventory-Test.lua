-- BRPlayerCharacterBase-HostSurfaceInventory-Test.lua
-- One-time diagnostic only. It never calls network, packet, downloader, game,
-- callback, delegate, or native host methods. It records names and Lua types only.

local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local REPORT_FILE = KEY_DIR .. "/.host_surface_inventory"

local function write_report(lines)
  local file = io.open(REPORT_FILE, "wb")
  if not file then return end
  file:write("HOST_SURFACE_INVENTORY_V1\n")
  file:write(table.concat(lines, "\n"))
  file:write("\n")
  file:close()
end

local lines = {}
local function add(line)
  if #lines < 2500 then lines[#lines + 1] = line end
end

add("No host-native method, network call, packet call, callback, or delegate was invoked.")
add("Selected global surface names:")

local selected = {
  "ScriptHelperNetInterface",
  "ScriptHelperClient",
  "ScriptHelper",
  "Net",
  "NetUtil",
  "UnrealNet",
  "Downloader",
  "FileSystem",
  "FileUtil",
  "Cache",
  "Http",
  "HTTP",
  "Network",
  "Request",
  "Response",
  "Callback",
  "Callbacks",
  "Delegate",
  "Delegates",
  "Event",
  "Events",
  "Async",
  "Promise",
  "Timer",
  "TimerManager",
  "UIManager",
  "log",
  "io",
  "json",
  "cjson",
}

local function describe_table(name, value, depth)
  if depth > 1 or type(value) ~= "table" then return end
  local members = {}
  local ok_pairs, iterator, state, initial = pcall(pairs, value)
  if not ok_pairs then
    add(name .. " [table; members_unavailable]")
    return
  end
  for member_name, member_value in iterator, state, initial do
    if type(member_name) == "string" then
      members[#members + 1] = member_name .. " [" .. type(member_value) .. "]"
    end
    if #members >= 120 then break end
  end
  table.sort(members)
  for _, member in ipairs(members) do
    add("  " .. name .. "." .. member)
  end
end

for _, name in ipairs(selected) do
  local value = rawget(_G, name)
  if value == nil then
    add(name .. " [missing]")
  else
    local value_type = type(value)
    add(name .. " [" .. value_type .. "]")
    describe_table(name, value, 1)
  end
end

add("Selected import names (availability only; no members are invoked):")
local importer = rawget(_G, "import")
if type(importer) ~= "function" then
  add("import [missing]")
else
  add("import [function]")
  local modules = {
    "ScriptHelperNetInterface",
    "ScriptHelperClient",
    "ScriptHelper",
    "FileSystem",
    "FileUtil",
    "Cache",
    "Callback",
    "Delegate",
    "Async",
    "Downloader",
    "NetUtil",
    "Net",
    "UnrealNet",
    "Http",
    "HTTP",
    "Network",
    "Request",
    "Response",
    "UE",
    "Android",
  }
  for _, module_name in ipairs(modules) do
    local ok_import, module_value = pcall(importer, module_name)
    if not ok_import then
      add("import(" .. module_name .. ") [failed]")
    elseif module_value == nil then
      add("import(" .. module_name .. ") [nil]")
    else
      add("import(" .. module_name .. ") [ok " .. type(module_value) .. "]")
    end
  end
end

add("Interpretation:")
add("A candidate is not an adapter until its host-side arguments, callback/return shape, and response semantics are documented and verified.")
add("This report intentionally does not call discovered functions or claim that any candidate can validate a license.")
write_report(lines)
return
