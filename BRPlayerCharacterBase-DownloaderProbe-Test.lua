-- BRLoginWrapper.lua — reusable Lua license gate
-- Paste this entire block at the very top of any BR character/main Lua file.
-- After validate() succeeds, paste your changing main Lua code below the marker.

local API_URL = "https://luapanel-8355ybgt.manus.space/v1/validate"
local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
-- key.json is preferred; key.txt and key.in are supported fallbacks for hosts
-- whose file browser or Lua integration handles those extensions more reliably.
local KEY_FILE_CANDIDATES = {
  KEY_DIR .. "/key.json",
  KEY_DIR .. "/key.txt",
  KEY_DIR .. "/key.in",
}
-- Prefer a runtime-provided persistent identity (native/app-private when available).
-- Fallback is a dot-prefixed local file, hidden by most file managers but not cryptographic protection.
local DEVICE_FILE = KEY_DIR .. "/.device_id"
local STATUS_FILE = KEY_DIR .. "/.license_status"
local RUNTIME_REPORT_FILE = KEY_DIR .. "/.runtime_globals"
-- Disabled by default. Set to true only for a one-time host capability test.
local ENABLE_DOWNLOADER_PROBE = true
local DOWNLOADER_PROBE_URL = "https://luapanel-8355ybgt.manus.space/downloader-probe.txt"
local DOWNLOADER_PROBE_FILE = KEY_DIR .. "/.downloader_probe"
local write_status

local function stop(message)
  local text = "[LICENSE] " .. tostring(message)
  if write_status then pcall(write_status, "ERROR: " .. tostring(message)) end

  -- Different Android Lua hosts expose different user-visible notification APIs.
  -- Try them defensively, then raise an error so the feature code never runs.
  pcall(function() print(text) end)
  local notifier = rawget(_G, "TOAST") or rawget(_G, "showToast") or rawget(_G, "toast")
  if type(notifier) == "function" then
    pcall(notifier, text)
  end

  error(text, 0)
end

local function read_file(path)
  local file, err = io.open(path, "rb")
  if not file then return nil, err end
  local data = file:read("*a")
  file:close()
  return data
end

local function write_file(path, data)
  local file, err = io.open(path, "wb")
  if not file then return false, err end
  file:write(data)
  file:close()
  return true
end

write_status = function(message)
  -- Best-effort diagnostic only: never store the license key or device identity here.
  local file = io.open(STATUS_FILE, "wb")
  if file then
    file:write(os.date("!%Y-%m-%dT%H:%M:%SZ") .. " " .. tostring(message))
    file:close()
  end
end

local function write_runtime_report()
  -- Non-secret capability report for hosts where print/error output is hidden.
  -- It records only names and Lua types; never values, keys, tokens, or IDs.
  -- Nested inspection is limited to known network namespaces and one level deep.
  local names = {}
  local seen = {}
  local max_entries = 3000

  local function add(path, value_type)
    if #names >= max_entries then return end
    names[#names + 1] = path .. " [" .. value_type .. "]"
  end

  local function inspect_table(path, value, depth)
    if depth > 1 or seen[value] then return end
    seen[value] = true
    local ok, iterator, state, initial = pcall(pairs, value)
    if not ok then return end
    for name, child in iterator, state, initial do
      if type(name) == "string" then
        local child_type = type(child)
        local child_path = path .. "." .. name
        if child_type == "function" or child_type == "table" then
          add(child_path, child_type)
          if child_type == "table" then inspect_table(child_path, child, depth + 1) end
        end
      end
      if #names >= max_entries then return end
    end
  end

  local ok_globals, iterator, state, initial = pcall(pairs, _G)
  if ok_globals then
    for name, value in iterator, state, initial do
      local value_type = type(value)
      if type(name) == "string" and (value_type == "function" or value_type == "table") then
        add(name, value_type)
        if (name == "Net" or name == "NetUtil" or name == "UnrealNet") and value_type == "table" then
          inspect_table(name, value, 0)
        end
      end
      if #names >= max_entries then break end
    end
  end

  table.sort(names)
  local file = io.open(RUNTIME_REPORT_FILE, "wb")
  if file then
    file:write("Global capabilities:\n")
    file:write(table.concat(names, "\n"))
    file:write("\n\nNested network namespaces inspected: Net, NetUtil, UnrealNet (one level; names/types only)\n")
    file:write("HTTP candidates to inspect: HTTP_POST, httpPost, request, fetch, http, gg, UE, Android\n")
    file:write("\nCandidate function metadata (descriptive only; no candidate is invoked):\n")
    local debug_api = rawget(_G, "debug")
    local getinfo = type(debug_api) == "table" and debug_api.getinfo or nil
    file:write("Metatable structure (keys/types only; no metamethods or candidates are invoked):\n")
    local function write_metatable_summary(label, value)
      local ok_meta, meta = pcall(getmetatable, value)
      if not ok_meta or type(meta) ~= "table" then
        file:write(label .. " metatable [none-or-unavailable]\n")
        return
      end
      local entries = {}
      local ok_pairs, iterator, state, initial = pcall(pairs, meta)
      if ok_pairs then
        for name, child in iterator, state, initial do
          if type(name) == "string" then entries[#entries + 1] = name .. " [" .. type(child) .. "]" end
          if #entries >= 100 then break end
        end
      end
      table.sort(entries)
      file:write(label .. " metatable [table entries=" .. tostring(#entries) .. "]\n")
      for _, entry in ipairs(entries) do file:write("  " .. label .. "." .. entry .. "\n") end
    end
    write_metatable_summary("NetUtil", rawget(_G, "NetUtil"))
    write_metatable_summary("Net", rawget(_G, "Net"))
    write_metatable_summary("UnrealNet", rawget(_G, "UnrealNet"))
    local candidates = {
      "Net.Connect",
      "Net.SendPacket",
      "NetUtil.ConnectToURL",
      "NetUtil.ConnectToURLDirectly",
      "NetUtil.ConnectToURLWithDNSProxy",
      "NetUtil.SendPkg",
    }
    for _, candidate_path in ipairs(candidates) do
      local root_name, child_name = candidate_path:match("^([^.]+)%.(.+)$")
      local root = root_name and rawget(_G, root_name) or nil
      local candidate = type(root) == "table" and root[child_name] or nil
      if type(candidate) == "function" then
        local details = "type=function"
        if type(getinfo) == "function" then
          local ok_info, info = pcall(getinfo, candidate, "Snu")
          if ok_info and type(info) == "table" then
            details = details .. " what=" .. tostring(info.what or "unknown")
            if info.short_src then details = details .. " source=" .. tostring(info.short_src) end
            if info.nparams then details = details .. " nparams=" .. tostring(info.nparams) end
            if info.isvararg ~= nil then details = details .. " vararg=" .. tostring(info.isvararg) end
          end
        end
        file:write(candidate_path .. " [" .. details .. "]\n")
      else
        file:write(candidate_path .. " [not-callable-or-missing]\n")
      end
    end
    file:close()
  end
end

local function run_downloader_probe()
  if ENABLE_DOWNLOADER_PROBE ~= true then return end
  pcall(write_status, "DOWNLOADER_PROBE_START")

  local importer = rawget(_G, "import")
  if type(importer) ~= "function" then
    pcall(write_status, "DOWNLOADER_PROBE_UNAVAILABLE import_missing")
    return
  end

  local ok_import, downloader = pcall(importer, "Downloader")
  if not ok_import or downloader == nil then
    pcall(write_status, "DOWNLOADER_PROBE_UNAVAILABLE import_failed")
    return
  end
  if type(downloader.DownloadFile) ~= "function" then
    pcall(write_status, "DOWNLOADER_PROBE_UNAVAILABLE DownloadFile_missing")
    return
  end

  -- This is the only invocation in probe mode: a fixed public file to an
  -- isolated dot-prefixed path. No key, device ID, game packet, or main code.
  local ok_call = pcall(function()
    downloader:DownloadFile(DOWNLOADER_PROBE_URL, DOWNLOADER_PROBE_FILE)
  end)
  if not ok_call then
    pcall(write_status, "DOWNLOADER_PROBE_CALL_FAILED")
    return
  end

  local probe_body = read_file(DOWNLOADER_PROBE_FILE)
  if type(probe_body) == "string" and probe_body:find("LUA_DOWNLOADER_PROBE_V1", 1, true) then
    pcall(write_status, "DOWNLOADER_PROBE_SUCCESS GET_FILE_WRITE")
  else
    pcall(write_status, "DOWNLOADER_PROBE_NO_VERIFIED_FILE")
  end
end

local function announce(message)
  local text = "[LICENSE] " .. tostring(message)
  pcall(function() print(text) end)
  local notifier = rawget(_G, "TOAST") or rawget(_G, "showToast") or rawget(_G, "toast")
  if type(notifier) == "function" then pcall(notifier, text) end
end

local function get_json()
  local decoder = rawget(_G, "json") or rawget(_G, "cjson")
  if decoder and decoder.decode and decoder.encode then return decoder end

  local ok, module = pcall(require, "cjson.safe")
  if ok and module then return module end
  ok, module = pcall(require, "cjson")
  if ok and module then return module end

  stop("JSON adapter unavailable: expose json.decode/json.encode or provide cjson")
end

local function get_device_id()
  local provider = rawget(_G, "getPersistentDeviceId") or rawget(_G, "getDeviceId")
  if type(provider) == "function" then
    local value = provider()
    if type(value) == "string" and #value > 0 then return value end
  end

  -- This fallback hides the value from casual browsing; it cannot stop a determined user
  -- from copying or replacing the file. Server-side attestation is required for that.
  local existing = read_file(DEVICE_FILE)
  if existing and #existing > 0 then
    return existing:gsub("%s+$", "")
  end

  math.randomseed(os.time() + math.floor(os.clock() * 100000))
  local alphabet = "0123456789abcdef"
  local chars = {}
  for i = 1, 32 do
    local n = math.random(#alphabet)
    chars[i] = alphabet:sub(n, n)
  end
  local generated = table.concat(chars)
  local ok, err = write_file(DEVICE_FILE, generated)
  if not ok then
    stop("cannot save device identity at " .. DEVICE_FILE .. ": " .. tostring(err))
  end
  return generated
end

local function post_json(url, body)
  local bridge = rawget(_G, "HTTP_POST")
  if type(bridge) == "function" then
    return bridge(url, body)
  end

  local ok_http, http = pcall(require, "socket.http")
  if ok_http and http and type(http.request) == "function" then
    local ok_ltn12, ltn12 = pcall(require, "ltn12")
    if ok_ltn12 and ltn12 then
      local response = {}
      local code = http.request({
        url = url,
        method = "POST",
        headers = {
          ["content-type"] = "application/json",
          ["content-length"] = tostring(#body),
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response),
      })
      return tonumber(code) or 0, table.concat(response)
    end

    -- LuaSocket can also stream a string body without ltn12. The one-shot
    -- source keeps the same JSON POST contract while avoiding that dependency.
    local sent = false
    local ok_request, response_body, code = pcall(function()
      return http.request({
        url = url,
        method = "POST",
        headers = {
          ["content-type"] = "application/json",
          ["content-length"] = tostring(#body),
        },
        source = function()
          if sent then return nil end
          sent = true
          return body
        end,
      })
    end)
    if ok_request then
      return tonumber(code) or 0, response_body
    end
  end

  stop("HTTP adapter unavailable: expose HTTP_POST or provide socket.http")
end

local function read_key(json)
  local raw, selected_file
  for _, candidate in ipairs(KEY_FILE_CANDIDATES) do
    local data = read_file(candidate)
    if data ~= nil then
      raw = data
      selected_file = candidate
      pcall(write_status, "KEY_FILE: " .. candidate)
      break
    end
  end
  if raw == nil then
    stop("key file not found; tried key.json, key.txt, and key.in in " .. KEY_DIR)
  end
  raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
  if #raw == 0 then stop("key file is empty: " .. selected_file) end

  if raw:sub(1, 1) == "{" then
    local parsed = json.decode(raw)
    if type(parsed) == "table" and type(parsed.key) == "string" then
      return parsed.key
    end
    stop(selected_file .. " must contain a string field named key")
  end
  return raw
end

local function validate_license()
  pcall(write_runtime_report)
  local json = get_json()
  local payload = json.encode({
    key = read_key(json),
    device_id = get_device_id(),
  })

  pcall(write_status, "VALIDATING")
  local status, body = post_json(API_URL, payload)
  local response = body and json.decode(body) or nil
  if tonumber(status) == 200 and response and response.ok == true then
    local expiry = tostring(response.expiresAt or "unknown")
    pcall(write_status, "ACCESS_GRANTED expires " .. expiry)
    announce("access granted; expires " .. expiry)
    return response
  end

  local code = response and response.error or "invalid_key"
  pcall(write_status, "VALIDATION_FAILED " .. tostring(code) .. " HTTP_" .. tostring(status or "unknown"))
  local messages = {
    invalid_key = "key is invalid",
    key_banned = "key has been banned",
    key_expired = "key has expired",
    device_limit_reached = "device limit reached",
    device_already_bound = "device is already bound to another key",
  }
  stop(messages[code] or ("license validation failed: " .. tostring(code)))
end

-- Probe-only mode: run the isolated Downloader test and stop this temporary copy.
-- This prevents normal POST validation from overwriting the probe result and
-- guarantees that no main Lua code runs during capability testing.
if ENABLE_DOWNLOADER_PROBE == true then
  run_downloader_probe()
  return
end

-- The script stops here on any failure. Nothing below this line executes unless
-- the panel authorizes the key and device.
local LICENSE_SESSION = validate_license()

-- ================================================================
-- PASTE YOUR CHANGING MAIN LUA CODE BELOW THIS LINE.
-- Do not add another loadfile() call for main_features.lua.
-- ================================================================

-- Example only; remove this line when adding your real main Lua code.
-- print("[LICENSE] main Lua started")

return LICENSE_SESSION
