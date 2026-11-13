-- BRPlayerCharacterBase-BridgeInventory-Test.lua
-- One-time diagnostic only. It never calls network, packet, downloader, or game APIs.
-- It records only names, Lua types, and whether safe module import attempts succeed.

local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local REPORT_FILE = KEY_DIR .. "/.bridge_inventory"

local function write_report(lines)
  local file = io.open(REPORT_FILE, "wb")
  if not file then return end
  file:write("BRIDGE_INVENTORY_V1\n")
  file:write(table.concat(lines, "\n"))
  file:write("\n")
  file:close()
end

local lines = {}
local function add(line)
  if #lines < 2000 then lines[#lines + 1] = line end
end

add("No network or packet function was invoked by this diagnostic.")
add("Global callable/table names:")

local ok_globals, iterator, state, initial = pcall(pairs, _G)
if ok_globals then
  local names = {}
  for name, value in iterator, state, initial do
    local value_type = type(value)
    if type(name) == "string" and (value_type == "function" or value_type == "table") then
      names[#names + 1] = name .. " [" .. value_type .. "]"
    end
  end
  table.sort(names)
  for _, name in ipairs(names) do add(name) end
else
  add("GLOBAL_ENUMERATION_FAILED")
end

add("Safe import availability checks:")
local importer = rawget(_G, "import")
if type(importer) ~= "function" then
  add("import [missing]")
else
  add("import [function]")
  local modules = {
    "Downloader",
    "NetUtil",
    "Net",
    "UnrealNet",
    "Http",
    "HTTP",
    "Network",
    "Request",
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
      if type(module_value) == "table" then
        local members = {}
        local ok_members, member_iterator, member_state, member_initial = pcall(pairs, module_value)
        if ok_members then
          for member_name, member_value in member_iterator, member_state, member_initial do
            if type(member_name) == "string" then
              members[#members + 1] = member_name .. " [" .. type(member_value) .. "]"
            end
            if #members >= 100 then break end
          end
        end
        table.sort(members)
        for _, member in ipairs(members) do
          add("  " .. module_name .. "." .. member)
        end
      end
    end
  end
end

add("Interpretation:")
add("A callable HTTP bridge must have documented arguments and return values before integration.")
add("This report does not prove that any discovered function can validate a license.")
write_report(lines)
return
