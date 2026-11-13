-- BRPlayerCharacterBase-HttpModuleInventory-Test.lua
-- One-time diagnostic based on the supplied friend login code.
-- It does not call GET, Send, NewRequest, URL, callbacks, or license APIs.
-- It records only safe module import availability and visible member types.

local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local REPORT_FILE = KEY_DIR .. "/.http_module_inventory"

local function write_report(lines)
  local file = io.open(REPORT_FILE, "wb")
  if not file then return end
  file:write("HTTP_MODULE_INVENTORY_V1\n")
  file:write(table.concat(lines, "\n"))
  file:write("\n")
  file:close()
end

local lines = {}
local function add(line)
  if #lines < 2000 then lines[#lines + 1] = line end
end

add("No HTTP request, URL open, callback, downloader, packet, or license function was invoked.")
add("The following candidates come from the supplied friend login code:")

local function describe_value(prefix, value)
  local value_type = type(value)
  add(prefix .. " [" .. value_type .. "]")
  if value_type ~= "table" then return end

  local members = {}
  local ok_members, iterator, state, initial = pcall(pairs, value)
  if not ok_members then
    add(prefix .. " members [unavailable]")
    return
  end

  for member_name, member_value in iterator, state, initial do
    if type(member_name) == "string" then
      members[#members + 1] = member_name .. " [" .. type(member_value) .. "]"
    end
    if #members >= 200 then break end
  end
  table.sort(members)
  for _, member in ipairs(members) do
    add("  " .. prefix .. "." .. member)
  end
end

local function inspect_require(module_name)
  local require_fn = rawget(_G, "require")
  if type(require_fn) ~= "function" then
    add("require(" .. module_name .. ") [require_missing]")
    return
  end

  local ok_require, module_value = pcall(require_fn, module_name)
  if not ok_require then
    add("require(" .. module_name .. ") [failed]")
    return
  end
  if module_value == nil then
    add("require(" .. module_name .. ") [nil]")
    return
  end
  describe_value("require(" .. module_name .. ")", module_value)
end

inspect_require("Http")
inspect_require("WebRequest")
inspect_require("SimpleHttp")

add("Interpretation:")
add("Import success alone does not prove that a request works.")
add("NewRequest, SetUrl, Send, Get, and callback signatures require a verified host contract before use.")
add("The supplied login code exposes the key in a URL/log and evaluates the response with loadstring; neither pattern is approved for production license validation.")

write_report(lines)
return
