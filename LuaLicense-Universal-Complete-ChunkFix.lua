-- BRLoginWrapper.lua — reusable Lua license gate
-- Paste this entire block at the very top of any BR character/main Lua file.
-- After validate() succeeds, paste your changing main Lua code below the marker.

local API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"
local MAINTENANCE_URL = "https://luapanel-8355ybgt.manus.space/api/maintenance/active"
local ANNOUNCEMENT_URL = "https://luapanel-8355ybgt.manus.space/api/announcement/active"
local TELEGRAM_TICKET_URL = "https://luapanel-8355ybgt.manus.space/api/telegram/ticket"
local TELEGRAM_REDEEM_URL = "https://luapanel-8355ybgt.manus.space/api/telegram/redeem"
local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
-- key.json is preferred; key.txt, key.in, and key.ini are supported fallbacks
-- for hosts whose file browser or Lua integration handles those extensions more reliably.
local KEY_FILE_CANDIDATES = {
  KEY_DIR .. "/key.json",
  KEY_DIR .. "/key.txt",
  KEY_DIR .. "/key.in",
  KEY_DIR .. "/key.ini",
}
-- Prefer a runtime-provided persistent identity (native/app-private when available).
-- Fallback is a dot-prefixed local file, hidden by most file managers but not cryptographic protection.
local DEVICE_FILE = KEY_DIR .. "/.device_id"
local STATUS_FILE = KEY_DIR .. "/.license_status"
-- Approved diagnostic-only files. They never contain values from the key,
-- device, ticket, channel URL, response body, token, or user account.
local TELEGRAM_DIAGNOSTIC_FILE = KEY_DIR .. "/.telegram_redirect_diagnostic"
local SAVED_KEY_DIAGNOSTIC_FILE = KEY_DIR .. "/.saved_key_diagnostic"
local ANNOUNCEMENT_SEEN_FILE = KEY_DIR .. "/.announcement_seen"
local RUNTIME_REPORT_FILE = KEY_DIR .. "/.runtime_globals"
-- Disabled by default. Set to true only for a one-time host capability test.
local ENABLE_DOWNLOADER_PROBE = false
local DOWNLOADER_PROBE_URL = "https://luapanel-8355ybgt.manus.space/downloader-probe.txt"
local DOWNLOADER_PROBE_FILE = KEY_DIR .. "/.downloader_probe"
-- This non-secret marker is only for the approved startup storage preflight.
-- The Android runtime proved that Client.WriteFileAtPath can create this exact
-- missing parent path and the existing io.open reader can read it back.
local FOLDER_ENSURE_FILE = KEY_DIR .. "/.lua_license_folder_ready"
local FOLDER_ENSURE_MARKER = "LUA_LICENSE_FOLDER_READY_V1"
-- This is the same documented text-button widget blueprint used by the
-- user-supplied main Lua counter. The loader never places license/device data
-- in it; it receives only the approved generic outcome label.
local LICENSE_POPUP_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
local LICENSE_POPUP_DURATION_SECONDS = 3.0
-- Approved production key-entry UI. The path is verified by the isolated
-- Android-proven folder preflight before this UI or any license storage runs.
local KEY_ENTRY_BLUEPRINT = "/Game/UMG/UI_BP/Home/Common/Popup/Small/Home_Input_Popups_UIBP.Home_Input_Popups_UIBP"
local KEY_ENTRY_MODULE = "lua_license.production_key_entry_popup_v1"
local KEY_ENTRY_CONFIG = {
  keyName = "LuaLicenseKeyEntryProductionV1",
  moduleName = KEY_ENTRY_MODULE,
  path = KEY_ENTRY_BLUEPRINT,
}
local key_entry_handoff = { initial_key = "", on_submit = nil }
local write_status
local read_key

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

local function stop_folder_initialization()
  -- Do not use write_status here: a failed folder preflight must not create,
  -- reset, or overwrite .license_status or any existing license state.
  local text = "[LICENSE] storage folder unavailable"
  pcall(function() print(text) end)
  local notifier = rawget(_G, "TOAST") or rawget(_G, "showToast") or rawget(_G, "toast")
  if type(notifier) == "function" then
    pcall(notifier, text)
  end
  error(text, 0)
end

local function ensure_lua_license_folder()
  -- Android device evidence established this exact V3-observed dot-call form:
  -- Client.WriteFileAtPath(fullPath, contents). Return values are not assumed;
  -- success is defined only by read-back through the existing raw file reader.
  local client = rawget(_G, "Client")
  if type(client) ~= "table" and type(client) ~= "userdata" then
    return false
  end

  local accessor_ok, writer = pcall(function()
    return client.WriteFileAtPath
  end)
  if accessor_ok ~= true or type(writer) ~= "function" then
    return false
  end

  local write_ok = pcall(writer, FOLDER_ENSURE_FILE, FOLDER_ENSURE_MARKER)
  if write_ok ~= true then
    return false
  end

  local marker = read_file(FOLDER_ENSURE_FILE)
  return marker == FOLDER_ENSURE_MARKER
end

write_status = function(message)
  -- Best-effort diagnostic only: never store the license key or device identity here.
  local file = io.open(STATUS_FILE, "wb")
  if file then
    file:write(os.date("!%Y-%m-%dT%H:%M:%SZ") .. " " .. tostring(message))
    file:close()
  end
end

-- This must complete before the first normal status/key/device write. If it
-- cannot prove the fixed non-secret marker is readable, stop before the
-- existing license flow and leave key/device/status formats untouched.
if ensure_lua_license_folder() ~= true then
  stop_folder_initialization()
end

local telegram_diagnostic_steps = {}
local function write_telegram_diagnostic(marker)
  local allowed = {
    OK_CALLBACK = true,
    TICKET_PRESENT = true,
    TICKET_MISSING = true,
    TICKET_CREATOR_CHANNEL_MISSING = true,
    TICKET_CREATOR_CHANNEL_DISABLED = true,
    REDEEM_CHANNEL_PRESENT = true,
    REDEEM_CHANNEL_MISSING = true,
    REDEEM_CREATOR_CHANNEL_MISSING = true,
    REDEEM_CREATOR_CHANNEL_DISABLED = true,
    OPEN_URL_AVAILABLE = true,
    OPEN_URL_MISSING = true,
  }
  if allowed[marker] ~= true then return end
  telegram_diagnostic_steps[#telegram_diagnostic_steps + 1] = marker
  pcall(write_file, TELEGRAM_DIAGNOSTIC_FILE, table.concat(telegram_diagnostic_steps, "\n"))
end

local function reset_telegram_diagnostic()
  telegram_diagnostic_steps = {}
  pcall(write_file, TELEGRAM_DIAGNOSTIC_FILE, "")
end

local function write_saved_key_diagnostic(source, length, status)
  local safe_source = source == "live" and "live" or "event"
  local safe_length = math.max(0, math.floor(tonumber(length) or 0))
  local allowed_statuses = {
    valid = true,
    expired = true,
    not_registered = true,
    invalid = true,
    device_mismatch = true,
    device_max_reached = true,
  }
  local safe_status = allowed_statuses[status] and status or "unrecognized"
  pcall(write_file, SAVED_KEY_DIAGNOSTIC_FILE,
    "input_source=" .. safe_source .. "\ninput_length=" .. tostring(safe_length) .. "\nvalidation_status=" .. safe_status)
end

-- Write before loading JSON, reading the key, or creating a device identity.
-- If this is the final visible status, the host did start this loader but could
-- not reach a later stage. It never contains a license key or device identity.
pcall(write_status, "LOADER_STARTED")

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

local function show_license_popup_widget(message, title, text_size)
  -- Use only the widget/load/container/timer APIs already exercised by the
  -- user-supplied main Lua. Any unavailable UI component fails silently; the
  -- status file and fail-closed validation decision remain authoritative.
  pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"]
      or require("client.slua.logic.common.logic_common_msg_box")
    if Msg and type(Msg.Show) == "function" then
      Msg.Show(4, tostring(title or "LICENSE VALIDATION"), tostring(message), function() end)
      return
    end

    if type(slua) ~= "table" or type(slua.loadUI) ~= "function" then return end

    local popup = slua.loadUI(LICENSE_POPUP_BP)
    if not popup or not slua.isValid(popup) then return end

    local frontend_hud = require("game_frontend_hud")
    if not frontend_hud or type(frontend_hud.AddToContainer) ~= "function" then return end
    if type(UIContainers) ~= "table" or UIContainers.Top == nil then return end

    frontend_hud.AddToContainer(UIContainers.Top, popup, 11000)
    if popup.RichText_Content then
      popup.RichText_Content:SetText(tostring(message))
      local font_info = popup.RichText_Content.Font
      if font_info then
        local sizes = { small = 16, normal = 20, large = 24, festival_large = 28 }
        font_info.Size = sizes[text_size or "normal"] or 20
        popup.RichText_Content:SetFont(font_info)
      end
    end

    local layout = import("WidgetLayoutLibrary")
    local slot = layout and layout.SlotAsCanvasSlot and layout.SlotAsCanvasSlot(popup)
    if slot then
      slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
      slot:SetAlignment(FVector2D(0.5, 0))
      slot:SetPosition(FVector2D(0, 72))
      local heights = { small = 44, normal = 52, large = 68, festival_large = 92 }
      slot:SetSize(FVector2D(560, heights[text_size or "normal"] or 52))
    end
    popup:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

    local hud = rawget(_G, "slua_GameFrontendHUD")
    local player_controller = hud and hud.GetPlayerController and hud:GetPlayerController()
    if slua.isValid(player_controller) and player_controller.AddGameTimer then
      player_controller:AddGameTimer(LICENSE_POPUP_DURATION_SECONDS, false, function()
        pcall(function()
          if slua.isValid(popup) then popup:RemoveFromParent() end
        end)
      end)
    end
  end)
end

local function announce(message, title, text_size)
  local text = "[LICENSE] " .. tostring(message)
  show_license_popup_widget(message, title, text_size)
  pcall(function() print(text) end)
  local notifier = rawget(_G, "TOAST") or rawget(_G, "showToast") or rawget(_G, "toast")
  if type(notifier) == "function" then pcall(notifier, text) end
end

-- The API expiry is canonical UTC ISO-8601. Convert it only for presentation
-- using the device's standard Lua clock; validation remains server-authoritative.
local function format_expiry_for_popup(iso_value)
  if type(iso_value) ~= "string" then return "Unavailable" end
  local year, month, day, hour, minute, second = iso_value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)")
  if not year then return iso_value end

  local local_epoch = os.time({
    year = tonumber(year), month = tonumber(month), day = tonumber(day),
    hour = tonumber(hour), min = tonumber(minute), sec = tonumber(second),
  })
  if type(local_epoch) ~= "number" then return iso_value end

  local utc_parts = os.date("!*t", local_epoch)
  if type(utc_parts) ~= "table" then return iso_value end
  local round_trip_epoch = os.time(utc_parts)
  if type(round_trip_epoch) ~= "number" then return iso_value end

  local utc_epoch = local_epoch + (local_epoch - round_trip_epoch)
  local formatted = os.date("%d %b %Y, %I:%M:%S %p", utc_epoch)
  if type(formatted) ~= "string" then return iso_value end
  return formatted .. " (local time)"
end

local function fail_with_popup(popup_message, status_message, stop_message)
  -- Popup text is an approved generic result only. Never include the key,
  -- device identity, server body, token, or any other sensitive value.
  pcall(write_status, status_message)
  announce(popup_message, popup_message == "CONNECTION ERROR" and "CONNECTION ERROR" or "AUTHENTICATION FAILED")
  stop(stop_message)
end

local function get_json()
  local decoder = rawget(_G, "json") or rawget(_G, "cjson")
  if decoder and decoder.decode and decoder.encode then return decoder end

  local ok, module = pcall(require, "cjson.safe")
  if ok and module then return module end
  ok, module = pcall(require, "cjson")
  if ok and module then return module end

  fail_with_popup("CONNECTION ERROR", "VALIDATION_JSON_UNAVAILABLE", "JSON adapter unavailable: expose json.decode/json.encode or provide cjson")
end

local function normalize_device_identity(value)
  if type(value) ~= "string" then return nil end
  local normalized = value:gsub("^%s+", ""):gsub("%s+$", "")
  if normalized == "" then return nil end
  return normalized
end

local function get_host_phone_device_id()
  -- V3 and the isolated Android probe established the documented dot-call form:
  -- Client.GetPhoneDeviceID(). The raw value remains in memory only.
  local client = rawget(_G, "Client")
  if type(client) ~= "table" and type(client) ~= "userdata" then return nil end

  local accessor_ok, candidate = pcall(function()
    return client.GetPhoneDeviceID
  end)
  if accessor_ok ~= true or type(candidate) ~= "function" then return nil end

  local call_ok, value = pcall(candidate)
  if call_ok ~= true then return nil end
  return normalize_device_identity(value)
end

local function get_device_id()
  -- Option A safe rollout: an existing local value preserves every active legacy
  -- binding unchanged. It is a temporary legacy compatibility path, not proof of
  -- a physical device, and is not selected for a fresh host-capable enrollment.
  local existing = normalize_device_identity(read_file(DEVICE_FILE))
  if existing then return existing end

  -- Fresh enrollment: the target Android host's runtime identity takes priority
  -- over every copyable local source. Never persist, print, or diagnose this value.
  local host_identity = get_host_phone_device_id()
  if host_identity then return host_identity end

  -- Preserve the pre-existing generic provider fallback after the proven host path.
  local provider = rawget(_G, "getPersistentDeviceId") or rawget(_G, "getDeviceId")
  if type(provider) == "function" then
    local provider_ok, value = pcall(provider)
    local provider_identity = provider_ok and normalize_device_identity(value) or nil
    if provider_identity then return provider_identity end
  end

  -- Last-resort compatibility fallback for runtimes without a usable host identity.
  -- This creates the established random local format but is not clone-resistant.

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

local function read_saved_key_for_popup(json)
  -- This reads the established key.json format only for prefill. A missing or
  -- malformed value leaves the entry box empty and is never overwritten until
  -- a newly entered key receives an existing server-valid response.
  local raw = read_file(KEY_FILE_CANDIDATES[1])
  if type(raw) ~= "string" then return "" end
  raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
  if raw == "" then return "" end
  if raw:sub(1, 1) == "{" then
    local decoded_ok, parsed = pcall(json.decode, raw)
    if decoded_ok and type(parsed) == "table" and type(parsed.key) == "string" then
      return parsed.key
    end
    return ""
  end
  return raw
end

local function save_validated_key(json, key)
  -- Save only after the unchanged authoritative server-valid branch. The
  -- established key.json file is replaced atomically at the file level.
  local encoded = json.encode({ key = key })
  if type(encoded) ~= "string" then return false, "could not encode key file" end
  return write_file(KEY_FILE_CANDIDATES[1], encoded)
end

local function read_announcement_seen()
  local raw = read_file(ANNOUNCEMENT_SEEN_FILE)
  return type(raw) == "string" and raw:gsub("%s+$", "") or ""
end

local function presentation_request(url, payload, on_response)
  -- Isolated post-validation presentation transport. It never changes canonical
  -- license validation, device binding, authentication, or key persistence.
  pcall(function()
    local json = get_json()
    local hud = rawget(_G, "slua_GameFrontendHUD")
    if not json or (type(hud) ~= "table" and type(hud) ~= "userdata") or type(hud.GetHttpWrapper) ~= "function" then return end
    local ok_wrapper, http_wrapper = pcall(hud.GetHttpWrapper, hud)
    if not ok_wrapper or (type(http_wrapper) ~= "table" and type(http_wrapper) ~= "userdata") or type(http_wrapper.RequestForLua) ~= "function" then return end
    local response_event = http_wrapper.OnResponseEvent
    if (type(response_event) ~= "table" and type(response_event) ~= "userdata") or type(response_event.Add) ~= "function" then return end
    local body = payload and json.encode(payload) or ""
    if type(body) ~= "string" then return end
    local request_index = nil
    local registered = pcall(function()
      response_event:Add(function(reqIndex, _, data, _, success, result)
        if request_index == nil or reqIndex ~= request_index or success ~= true or tonumber(result) ~= 200 or type(data) ~= "string" then return end
        local decoded_ok, response = pcall(json.decode, data)
        if decoded_ok and type(response) == "table" then pcall(on_response, response) end
      end)
    end)
    if not registered then return end
    local headers = { ["Content-Type"] = "application/json", ["Content-Length"] = tostring(#body), ["Accept"] = "application/json", ["Accept-Encoding"] = "identity" }
    local method = payload and "POST" or "GET"
    local ok_request, returned_index = pcall(function() return http_wrapper:RequestForLua(url, method, headers, body, 0, 0) end)
    if ok_request then request_index = returned_index end
  end)
end

local function telegram_request(url, payload, on_success)
  presentation_request(url, payload, on_success)
end

local function redeem_telegram_ticket(ticket, device_id)
  telegram_request(TELEGRAM_REDEEM_URL, { ticket = ticket, device_id = device_id }, function(response)
    local channel_url = response.channelUrl
    if response.enabled ~= true or type(channel_url) ~= "string" or channel_url == "" then
      if response.resolution == "creator_channel_missing" then
        write_telegram_diagnostic("REDEEM_CREATOR_CHANNEL_MISSING")
      elseif response.resolution == "creator_channel_disabled" then
        write_telegram_diagnostic("REDEEM_CREATOR_CHANNEL_DISABLED")
      end
      write_telegram_diagnostic("REDEEM_CHANNEL_MISSING")
      return
    end
    write_telegram_diagnostic("REDEEM_CHANNEL_PRESENT")
    local loaded, WebSDK = pcall(require, "client.slua.logic.url.logic_webview_sdk")
    if not loaded or not WebSDK or type(WebSDK.OpenURL) ~= "function" then
      write_telegram_diagnostic("OPEN_URL_MISSING")
      return
    end
    write_telegram_diagnostic("OPEN_URL_AVAILABLE")
    pcall(function() WebSDK:OpenURL(channel_url) end)
  end)
end

local function show_telegram_announcement(title, message, text_size, ticket, device_id)
  -- Main Lua has already continued normally. The documented callback is the
  -- explicit OK action; cancel/close leaves Main Lua running without redirect.
  pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
    if Msg and type(Msg.Show) == "function" then
      Msg.Show(4, tostring(title or "SYSTEM ANNOUNCEMENT"), tostring(message), function()
        write_telegram_diagnostic("OK_CALLBACK")
        if type(ticket) == "string" and ticket ~= "" then
          redeem_telegram_ticket(ticket, device_id)
        else
          write_telegram_diagnostic("TICKET_MISSING")
        end
      end)
      return
    end
  end)
end

local function request_telegram_ticket(key, device_id, on_ticket)
  telegram_request(TELEGRAM_TICKET_URL, { key = key, device_id = device_id }, function(response)
    local ticket = response.enabled == true and type(response.ticket) == "string" and response.ticket ~= "" and response.ticket or nil
    if ticket then
      write_telegram_diagnostic("TICKET_PRESENT")
    elseif response.resolution == "creator_channel_missing" then
      write_telegram_diagnostic("TICKET_CREATOR_CHANNEL_MISSING")
    elseif response.resolution == "creator_channel_disabled" then
      write_telegram_diagnostic("TICKET_CREATOR_CHANNEL_DISABLED")
    else
      write_telegram_diagnostic("TICKET_MISSING")
    end
    on_ticket(ticket)
  end)
end

local function fetch_active_announcement(validated_key)
  -- Announcement is presentation-only after Main Lua begins. A failure here
  -- cannot revoke or block a valid license.
  -- Android's verified bridge request path is POST. This fixed key-free body
  -- is used only for the isolated Announcement state read.
  presentation_request(ANNOUNCEMENT_URL, {}, function(response)
    if response.active ~= true then return end
    if response.displayMode == "once_per_day" and read_announcement_seen() == tostring(response.version) .. "|" .. os.date("!%Y-%m-%d") then return end
    local title, message = tostring(response.title or "SYSTEM ANNOUNCEMENT"), tostring(response.message or "")
    if message == "" or #message > 300 or #title > 80 then return end
    local device_id = get_device_id()
    reset_telegram_diagnostic()
    request_telegram_ticket(validated_key, device_id, function(ticket)
      show_telegram_announcement(title, message, tostring(response.textSize or "normal"), ticket, device_id)
      if response.displayMode == "once_per_day" then write_file(ANNOUNCEMENT_SEEN_FILE, tostring(response.version) .. "|" .. os.date("!%Y-%m-%d")) end
    end)
  end)
end

local function gate_server_maintenance(json, validated_response, validated_key, on_authorized)
  -- Independent from /api/license/validate: maintenance can preserve a valid
  -- result while halting Main Lua before any later presentation logic begins.
  pcall(function()
    local hud = rawget(_G, "slua_GameFrontendHUD")
    if (type(hud) ~= "table" and type(hud) ~= "userdata") or type(hud.GetHttpWrapper) ~= "function" then
      pcall(write_status, "MAINTENANCE_CHECK_UNAVAILABLE host_missing")
      announce("Maintenance status could not be checked. Please try again later.", "SERVER MAINTENANCE")
      return
    end
    local ok_wrapper, http_wrapper = pcall(hud.GetHttpWrapper, hud)
    if not ok_wrapper or (type(http_wrapper) ~= "table" and type(http_wrapper) ~= "userdata") or type(http_wrapper.RequestForLua) ~= "function" then
      pcall(write_status, "MAINTENANCE_CHECK_UNAVAILABLE wrapper_missing")
      announce("Maintenance status could not be checked. Please try again later.", "SERVER MAINTENANCE")
      return
    end
    local response_event = http_wrapper.OnResponseEvent
    if (type(response_event) ~= "table" and type(response_event) ~= "userdata") or type(response_event.Add) ~= "function" then
      pcall(write_status, "MAINTENANCE_CHECK_UNAVAILABLE response_event_missing")
      announce("Maintenance status could not be checked. Please try again later.", "SERVER MAINTENANCE")
      return
    end

    local request_index = nil
    local callback_registered = pcall(function()
      response_event:Add(function(reqIndex, _, data, _, success, result)
        if request_index == nil or reqIndex ~= request_index then return end
        if success ~= true or tonumber(result) ~= 200 or type(data) ~= "string" then
          pcall(write_status, "MAINTENANCE_CHECK_UNAVAILABLE response_failed")
          announce("Maintenance status could not be checked. Please try again later.", "SERVER MAINTENANCE")
          return
        end
        local decoded_ok, response = pcall(json.decode, data)
        if not decoded_ok or type(response) ~= "table" or type(response.active) ~= "boolean" then
          pcall(write_status, "MAINTENANCE_CHECK_UNAVAILABLE response_invalid")
          announce("Maintenance status could not be checked. Please try again later.", "SERVER MAINTENANCE")
          return
        end
        if response.active == true then
          local title, message = tostring(response.title or "SERVER MAINTENANCE"), tostring(response.message or "")
          if message == "" or #message > 300 or #title > 80 then
            pcall(write_status, "MAINTENANCE_CHECK_UNAVAILABLE payload_invalid")
            announce("Maintenance status could not be checked. Please try again later.", "SERVER MAINTENANCE")
            return
          end
          pcall(write_status, "MAINTENANCE_ACTIVE")
          announce(message, title)
          return
        end
        on_authorized(validated_response, validated_key)
      end)
    end)
    if not callback_registered then
      pcall(write_status, "MAINTENANCE_CHECK_UNAVAILABLE callback_register_failed")
      announce("Maintenance status could not be checked. Please try again later.", "SERVER MAINTENANCE")
      return
    end
    -- Use the host's verified POST contract for this isolated status query.
    -- The body is a fixed, key-free JSON object; the endpoint ignores it.
    local request_body = "{}"
    local headers = { ["Content-Type"] = "application/json", ["Content-Length"] = tostring(#request_body), ["Accept"] = "application/json", ["Accept-Encoding"] = "identity" }
    local ok_request, returned_index = pcall(function() return http_wrapper:RequestForLua(MAINTENANCE_URL, "POST", headers, request_body, 0, 0) end)
    if not ok_request or returned_index == nil or returned_index == 0 then
      pcall(write_status, "MAINTENANCE_CHECK_UNAVAILABLE request_failed")
      announce("Maintenance status could not be checked. Please try again later.", "SERVER MAINTENANCE")
      return
    end
    request_index = returned_index
  end)
end

local function start_license_validation(on_authorized, submitted_key, submission_trace)
  -- This is the verified, documented Dynamic Execution transport contract.
  -- The callback is asynchronous, so this function only dispatches the request.
  -- Protected code is invoked exclusively from the successful callback below.
  local json = get_json()
  local key = read_key(json, submitted_key)
  local trace_source = type(submission_trace) == "table" and submission_trace.source == "live" and "live" or "event"
  local trace_length = type(submission_trace) == "table" and tonumber(submission_trace.length) or #key
  if not trace_length or trace_length < 0 then trace_length = #key end
  -- The separate trace is cleared for this attempt and is written only after
  -- the canonical API sends an allowed validation status.
  pcall(write_file, SAVED_KEY_DIAGNOSTIC_FILE, "")
  local payload = json.encode({
    key = key,
    device_id = get_device_id(),
  })
  if type(payload) ~= "string" then
    fail_with_popup("CONNECTION ERROR", "VALIDATION_REQUEST_INVALID", "could not encode license validation request")
  end

  local hud = rawget(_G, "slua_GameFrontendHUD")
  if type(hud) ~= "table" and type(hud) ~= "userdata" then
    fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE host_missing", "license server unreachable")
  end
  if type(hud.GetHttpWrapper) ~= "function" then
    fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE wrapper_missing", "license server unreachable")
  end

  local ok_wrapper, http_wrapper = pcall(hud.GetHttpWrapper, hud)
  if not ok_wrapper or (type(http_wrapper) ~= "table" and type(http_wrapper) ~= "userdata") then
    fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE wrapper_acquire_failed", "license server unreachable")
  end
  if type(http_wrapper.RequestForLua) ~= "function" then
    fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE request_missing", "license server unreachable")
  end

  local response_event = http_wrapper.OnResponseEvent
  if (type(response_event) ~= "table" and type(response_event) ~= "userdata") or type(response_event.Add) ~= "function" then
    fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE response_event_missing", "license server unreachable")
  end

  local request_index = nil
  local headers = {
    ["Content-Type"] = "application/json",
    ["Content-Length"] = tostring(#payload),
    ["Accept"] = "application/json",
    ["Accept-Encoding"] = "identity",
  }

  -- Register before dispatching, exactly as in the verified correlated ping.
  local callback_registered = pcall(function()
    response_event:Add(function(reqIndex, elapsedTime, data, content, success, result)
      if request_index == nil or reqIndex ~= request_index then return end

      if success ~= true then
        fail_with_popup("CONNECTION ERROR", "TRANSPORT_FAILED result=" .. tostring(result), "license server unreachable")
      end
      if tonumber(result) ~= 200 then
        fail_with_popup("CONNECTION ERROR", "VALIDATION_HTTP_" .. tostring(result), "license server unreachable")
      end
      if type(data) ~= "string" or #data == 0 then
        fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_MISSING", "license validation response was invalid")
      end

      local decoded_ok, response = pcall(json.decode, data)
      if not decoded_ok or type(response) ~= "table" or type(response.status) ~= "string" then
        fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_INVALID", "license validation response was invalid")
      end
      write_saved_key_diagnostic(trace_source, trace_length, response.status)

      -- The canonical API uses `invalid` for a revoked/banned key. An unknown
      -- key is `not_registered`; it receives the generic invalid-key popup.
      local outcomes = {
        expired = { popup = "KEY EXPIRED", stop_message = "key has expired" },
        not_registered = { popup = "INVALID KEY", stop_message = "key is not registered" },
        invalid = { popup = "KEY REVOKED", stop_message = "key has been revoked or banned" },
        device_mismatch = { popup = "INVALID KEY", stop_message = "key is bound to a different device" },
        device_max_reached = { popup = "DEVICE LIMIT REACHED", stop_message = "device limit reached for this key" },
      }

      if response.status == "valid" and response.success == true then
        if type(response.expiresAt) ~= "string" or #response.expiresAt == 0 then
          fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_EXPIRY_MISSING", "license validation response was invalid")
        end
        local saved, save_error = save_validated_key(json, key)
        if not saved then
          stop("cannot save validated key: " .. tostring(save_error))
        end
        pcall(write_status, "ACCESS_GRANTED input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " validation_status=valid")
        announce("KEY VALID\nACCESS GRANTED\nExpires: " .. format_expiry_for_popup(response.expiresAt), "AUTHENTICATION SUCCESS")
        gate_server_maintenance(json, response, key, on_authorized)
        return
      end

      local outcome = outcomes[response.status]
      if outcome then
        fail_with_popup(outcome.popup, "VALIDATION_FAILED " .. response.status .. " input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " validation_status=" .. response.status, outcome.stop_message)
      end

      fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_REJECTED " .. tostring(response.status) .. " input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " validation_status=" .. tostring(response.status), "license validation response was rejected")
    end)
  end)
  if not callback_registered then
    stop("license server unreachable")
  end

  local ok_request, returned_index = pcall(function()
    return http_wrapper:RequestForLua(API_URL, "POST", headers, payload, 0, 0)
  end)
  if not ok_request or returned_index == nil or returned_index == 0 then
    fail_with_popup("CONNECTION ERROR", "TRANSPORT_REQUEST_FAILED", "license server unreachable")
  end

  request_index = returned_index
  pcall(write_status, "VALIDATING input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " awaiting_callback")
end

read_key = function(json, submitted_key)
  local raw, selected_file
  if type(submitted_key) == "string" then
    raw = submitted_key
    selected_file = "key entry"
  else
    for _, candidate in ipairs(KEY_FILE_CANDIDATES) do
      local data = read_file(candidate)
      if data ~= nil then
        raw = data
        selected_file = candidate
        pcall(write_status, "KEY_FILE: " .. candidate)
        break
      end
    end
  end
  if raw == nil then
    stop("key file not found; tried key.json, key.txt, key.in, and key.ini in " .. KEY_DIR)
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

-- Nothing below the marker runs until the asynchronous callback verifies the
-- authoritative server response. Do not add a busy-wait loop: it could prevent
-- the runtime event loop from delivering OnResponseEvent.
-- Universal lifecycle state is local to this separate file. It does not replace
-- the canonical validator, host identity, transport, or server response flow.
local UNIVERSAL_LIFECYCLE = {
  authorization_active = false,
  main_initialized = false,
  validation_successes = 0,
  started_matches = {},
  ended_matches = {},
  cleanup_handlers = {},
  session = nil,
  key = nil,
}
local function register_universal_cleanup(handler)
  if type(handler) == "function" then
    UNIVERSAL_LIFECYCLE.cleanup_handlers[#UNIVERSAL_LIFECYCLE.cleanup_handlers + 1] = handler
  end
end
local function cleanup_universal_match()
  for index = #UNIVERSAL_LIFECYCLE.cleanup_handlers, 1, -1 do
    pcall(UNIVERSAL_LIFECYCLE.cleanup_handlers[index])
    UNIVERSAL_LIFECYCLE.cleanup_handlers[index] = nil
  end
  _G.ActiveBombTimers = nil
end
local function run_authorized_main_once(LICENSE_SESSION, validated_key)
  -- The complete Main Lua is kept as one source chunk. Its original
  -- top-level return/module contract is therefore preserved.
  local MAIN_LUA_SOURCE = [====[
 -- New Fresh 4.lua | compact selective build from V1-V6 references
-- Only the requested ESP, wallhack, throwable warning, welcome/expiry, and credit systems are included.
local MENU_NAME = "KALUA Menu" -- editable menu title
local FEATURE_CATEGORY_NAME = "KALUA Features" -- editable feature-category title
local ESP_NAME = "KALUA ESP"
local CREDIT_TEXT = "TG ~ @KALUAMOD"
local EXPIRY_DATE = "2026-10-07" -- editable: YYYY-MM-DD (V1 reference date)
local WELCOME_TITLE = "NOTIFICATION FROM @KALUAMOD" -- editable
local WELCOME_TEXT = [[
WELCOME TO LUA VIP

PLAY CAREFULLY AND ENJOY
ADMIN: @KALUAMOD
]] -- editable

_G.LexusConfig = _G.LexusConfig or {}
_G.LexusConfig.ThrowableWarning = _G.LexusConfig.ThrowableWarning or false
_G.LexusState = _G.LexusState or {}
_G.AK_Features = {
    { id = "WALLHACK", name = "Wallhack", val = 0, type = "toggle" },
    { id = "ESP_LINE", name = "ESP Line", val = 0, type = "toggle" },
    { id = "ESP_BOX", name = "ESP Box", val = 0, type = "toggle" },
    { id = "ESP_NAME", name = "ESP Name", val = 0, type = "toggle" },
    { id = "ESP_HEALTH", name = "ESP Health", val = 0, type = "toggle" },
    { id = "ESP_COUNTER", name = "ESP Counter", val = 0, type = "toggle" },
    { id = "THROWABLE_WARNING", name = "Throwable / Grenade Warning", val = 0, type = "toggle" },
}
function _G.AK_GetVal(id)
    if id == "ESP_V2" then
        return (_G.AK_GetVal("ESP_BOX") == 1 or _G.AK_GetVal("ESP_NAME") == 1 or _G.AK_GetVal("ESP_HEALTH") == 1 or _G.AK_GetVal("ESP_LINE") == 1 or _G.AK_GetVal("ESP_COUNTER") == 1) and 1 or 0
    end
    if id == "ESP9_Line" then return _G.AK_GetVal("ESP_LINE") end
    if id == "ESP9_Count" then return _G.AK_GetVal("ESP_COUNTER") end
    if id == "ESP9_Name" then return _G.AK_GetVal("ESP_NAME") end
    if id == "ESP9_HP" then return _G.AK_GetVal("ESP_HEALTH") end
    if id == "ESP9_Distance" then return _G.AK_GetVal("ESP_NAME") end
    if id == "ESP9_Team" then return 1 end
    for _, f in ipairs(_G.AK_Features) do if f.id == id then return f.val end end
    return 0
end
local ENetRole = import("ENetRole")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local C_WHITE = {R=255,G=255,B=255,A=255}
local C_RED = {R=255,G=0,B=0,A=255}
local C_CYAN = {R=0,G=255,B=255,A=255}
-- ========================================================================
-- V1 EXPIRY SYSTEM + WELCOME POPUP (selectively restored)
-- Editable expiry date is kept at the top of this file as EXPIRY_DATE.
-- ========================================================================
local function _NF4_ParseExpiryTimestamp()
    local y, m, d = EXPIRY_DATE:match("^(%d%d%d%d)%-(%d%d?)%-(%d%d?)$")
    return os.time({year=tonumber(y), month=tonumber(m), day=tonumber(d), hour=0, min=0, sec=0})
end
local EXPIRY_TIMESTAMP = _NF4_ParseExpiryTimestamp()

local function FormatTimeRemaining(sec)
    if sec <= 0 then return "0d 0h 0m 0s" end
    local days = math.floor(sec / 86400); sec = sec % 86400
    local hours = math.floor(sec / 3600); sec = sec % 3600
    local minutes = math.floor(sec / 60)
    local seconds = sec % 60
    return string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
end

function CheckExpiration()
    local remaining = EXPIRY_TIMESTAMP - os.time()
    if remaining <= 0 then
        _G._MOD_EXPIRED = true
        _G.MOD_EXPIRED = true
        return false
    end
    _G._MOD_EXPIRED = false
    _G.MOD_EXPIRED = false
    _G._MOD_REMAINING_SECONDS = remaining
    return true
end

local function ShowExpiryPopup(expired)
    pcall(function()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end
        local function onClick() end
        if expired then
            local expiresAt = os.date("!%Y-%m-%d %H:%M:%S UTC", EXPIRY_TIMESTAMP)
            Msg.Show(4, "MOD EXPIRED", "THIS MOD HAS EXPIRED.\n\nEXPIRED ON: " .. expiresAt .. "\n\nTEXT Me  OWNER KALUAMOD", onClick)
        else
            local remaining = _G._MOD_REMAINING_SECONDS or (EXPIRY_TIMESTAMP - os.time())
            local formatted = FormatTimeRemaining(remaining)
            local expiresAt = os.date("!%Y-%m-%d %H:%M:%S UTC", EXPIRY_TIMESTAMP)
            Msg.Show(4, "NOTIFICATION", "MOD VALIDITY: " .. formatted .. "\nEXPIRES AT: " .. expiresAt .. "\n\nOWNER DM @KALUAMOD", onClick)
        end
    end)
end

function _G.TryShowWelcome()
    if _G.WelcomeShown then return end
    if not CheckExpiration() then
        ShowExpiryPopup(true)
        return
    end
    ShowExpiryPopup(false)
    _G.WelcomeShown = true
end

-- V1 timing: perform an early check, then show the popup after player/UI startup.
local function _NF4_StartWelcomeBootstrap()
    pcall(function()
        local ticker = require("common.time_ticker")
        if ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(3, function() CheckExpiration() end)
            ticker.AddTimerOnce(4, function()
                if not CheckExpiration() then ShowExpiryPopup(true) else _G.TryShowWelcome() end
            end)
            return
        end
        if _G.Game and _G.Game.AddGameTimer then
            _G.Game:AddGameTimer(3.0, false, function() CheckExpiration() end)
            _G.Game:AddGameTimer(4.0, false, function()
                if not CheckExpiration() then ShowExpiryPopup(true) else _G.TryShowWelcome() end
            end)
            return
        end
        _G.TryShowWelcome()
    end)
end
_NF4_StartWelcomeBootstrap()

local function UpdateThrowableWarnings(localPlayer)
        if _G.AK_GetVal("THROWABLE_WARNING") == 1 then
            pcall(function()
                local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
                local MyHUD = pc and pc.MyHUD or nil
                if MyHUD and slua.isValid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForBomb then _G.CachedActorClass_ForBomb = import("Actor") end 
                    if not _G.CachedProjArray then _G.CachedProjArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForBomb) end
                    
                    -- Initialize the Cache using a Weak Table so the game garbage-collects it automatically, preventing RAM overflow
                    if not _G.ActorBombCacheInit then
                        _G.NonBombCache = setmetatable({}, { __mode = "k" })
                        _G.BombCache = setmetatable({}, { __mode = "k" })
                        _G.ActorBombCacheInit = true
                    end
                    
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()
                        
                        -- HEAVY DATA SCAN THREAD: Runs every 0.5s instead of every frame
                        if not _G.LastBombScanTime or (curTime - _G.LastBombScanTime) > 0.5 then
                            _G.LastBombScanTime = curTime
                            local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForBomb, _G.CachedProjArray)
                            
                            local activeBombs = {}
                            local itemBombs = {}
                            
                            if allActors then
                                for _, actor in pairs(allActors) do
                                    if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                        
                                        -- 1. ULTRA-FAST CACHE CHECK
                                        -- If this actor has been scanned before and is NOT A BOMB -> Skip immediately (Reduces lag by 99%)
                                        if not _G.NonBombCache[actor] then
                                            local bType = 0
                                            local isItem = false
                                            local isKnownBomb = _G.BombCache[actor]
                                            
                                            if isKnownBomb then
                                                bType = isKnownBomb.type
                                                isItem = isKnownBomb.isItem
                                            else
                                                -- First time seeing this Actor, perform a name check (Very rare)
                                                local nameLower = nil
                                                pcall(function() nameLower = string.lower(type(actor.GetName) == "function" and actor:GetName() or tostring(actor)) end)
                                                
                                                if nameLower then
                                                    if string.find(nameLower, "m79") or string.find(nameLower, "launcher") then bType = 5
                                                    elseif string.find(nameLower, "smoke") then bType = 2
                                                    elseif string.find(nameLower, "burn") or string.find(nameLower, "molotov") then bType = 3
                                                    elseif string.find(nameLower, "flash") or string.find(nameLower, "stun") then bType = 4
                                                    elseif string.find(nameLower, "grenade") then bType = 1 end
                                                    
                                                    if bType > 0 then
                                                        if string.find(nameLower, "projectile") or string.find(nameLower, "thrown") then
                                                            isItem = false
                                                        else
                                                            isItem = true
                                                            local shouldAdd = true
                                                            if bType == 3 and not (string.find(nameLower, "pickup") or string.find(nameLower, "wrapper") or string.find(nameLower, "weapon")) then
                                                                shouldAdd = false
                                                            elseif bType == 5 then
                                                                local attachParent = nil
                                                                pcall(function() if type(actor.GetAttachParentActor) == "function" then attachParent = actor:GetAttachParentActor() end end)
                                                                if slua.isValid(attachParent) then
                                                                    local isHolding = false
                                                                    pcall(function()
                                                                        local curWeapon = type(attachParent.GetCurrentWeapon) == "function" and attachParent:GetCurrentWeapon() or attachParent.CurrentWeapon
                                                                        if curWeapon == actor then isHolding = true end
                                                                    end)
                                                                    if not isHolding then shouldAdd = false end
                                                                end
                                                            end
                                                            if not shouldAdd then bType = 0 end
                                                        end
                                                    end
                                                end
                                                
                                                -- Save the result into the Cache
                                                if bType > 0 then
                                                    _G.BombCache[actor] = { type = bType, isItem = isItem }
                                                else
                                                    _G.NonBombCache[actor] = true
                                                end
                                            end
                                            
                                            -- If it is a valid Bomb (from Cache or newly found)
                                            if bType > 0 then
                                                local isPendingKill = false
                                                pcall(function() if type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                                
                                                if not isPendingKill then
                                                    if isItem then
                                                        table.insert(itemBombs, {act = actor, type = bType})
                                                    else
                                                        table.insert(activeBombs, {act = actor, type = bType})
                                                    end
                                                else
                                                    -- Remove from cache if the bomb has exploded/disappeared
                                                    _G.BombCache[actor] = nil
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            _G.CachedActiveBombs = activeBombs
                            _G.CachedItemBombs = itemBombs
                        end

                        local curGameTime = 0
                        pcall(function() curGameTime = _G.CachedGameplayStatics.GetTimeSeconds(gameInstance) end)

                        local function DrawBombs(bombList, isItem, maxDist)
                            if not bombList then return end
                            for _, item in ipairs(bombList) do
                                local bomb = item.act
                                local bType = item.type
                                
                                if slua.isValid(bomb) and not bomb.bHidden then
                                    local distM = 0
                                    pcall(function() distM = localPlayer:GetDistanceTo(bomb) / 100 end)
                                    
                                    if distM > 0 and distM <= maxDist then
                                        local displayName = ""
                                        local bombColor = C_WHITE
                                        local zOffset = isItem and 15 or 25
                                        
                                        if bType == 1 then displayName = "Boom"; bombColor = isItem and {R=255, G=100, B=100, A=255} or C_RED
                                        elseif bType == 2 then displayName = "KHÓI"; bombColor = isItem and {R=200, G=200, B=200, A=255} or C_WHITE
                                        elseif bType == 3 then displayName = "LỬA"; bombColor = isItem and {R=255, G=160, B=50, A=255} or {R=255, G=100, B=0, A=255}
                                        elseif bType == 4 then displayName = "MÙ"; bombColor = isItem and {R=150, G=255, B=255, A=255} or C_CYAN
                                        elseif bType == 5 then displayName = "SMOKE GRENADE"; bombColor = isItem and {R=150, G=255, B=150, A=255} or {R=100, G=255, B=100, A=255} end
                                        
                                        local text = string.format("%s [%dm]", displayName, math.floor(distM))
                                        local shouldTimerRun = not isItem 
                                        
                                        if isItem then pcall(function() if bomb.bIsPinPulled or bomb.bPinPulled or (type(bomb.IsPinPulled) == "function" and bomb:IsPinPulled()) then shouldTimerRun = true end end) end

                                        if shouldTimerRun and curGameTime > 0 then
                                            local timeLeft = -1
                                            pcall(function() if bomb.ExplosionTime then timeLeft = bomb.ExplosionTime - curGameTime elseif bomb.ExplodeTime then timeLeft = bomb.ExplodeTime - curGameTime end end)
                                            
                                            if timeLeft == -1 or timeLeft > 100 then
                                                _G.ActiveBombTimers = _G.ActiveBombTimers or {}
                                                local bombId = tostring(bomb)
                                                if not _G.ActiveBombTimers[bombId] then _G.ActiveBombTimers[bombId] = curGameTime end
                                                local elapsed = curGameTime - _G.ActiveBombTimers[bombId]
                                                local maxTime = (bType == 1 and 7.0) or (bType == 2 and 45.0) or (bType == 3 and 12.0) or (bType == 4 and 5.0) or 45.0
                                                timeLeft = maxTime - elapsed
                                            end
                                            
                                            if timeLeft < 0 then timeLeft = 0 end
                                            if timeLeft > 0.1 then text = string.format("%s (%.1fs)", text, timeLeft) end
                                        end
                                        
                                        local dynamicScale = math.max(0.6, 1.1 - (distM / maxDist))
                                        MyHUD:AddDebugText(text, bomb, 0.06, {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset}, bombColor, true, false, true, nil, dynamicScale, true)
                                    end
                                end
                            end
                        end
                        
                        if not _G.LastClearTimer or (curTime - _G.LastClearTimer) > 1.0 then
                            _G.LastClearTimer = curTime
                            pcall(function() if _G.ActiveBombTimers then for k, v in pairs(_G.ActiveBombTimers) do if (curGameTime - v) > 60.0 then _G.ActiveBombTimers[k] = nil end end end end)
                        end

                        if true then DrawBombs(_G.CachedItemBombs, true, 50) end
                        if true then DrawBombs(_G.CachedActiveBombs, false, 150) end
                    end
                end
            end)
        end
end
-- ========================================================================
-- ⚡ ESP V2 SYSTEM (RedBoxOverlay + PlayerMapMarker) - FIXED
-- ========================================================================
local PlayerMapMarker = {}
local RedBoxOverlay = {
    bActive = false,
    MainContainer = nil,
    WidgetSlot = nil,
    TextBlock = nil,
    Width = 300,
    Height = 42,
    OffsetY = 46,
    PlayerCount = 0,
    BotCount = 0,
    NearestDistance = 0,
    Layers = {},
    FontSize = 15,
    TextScaleValue = 1.0,
    _CachedText = "",
    _CachedPosVec = nil
}

function RedBoxOverlay.Create()
    if RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then return true end

    local ParentCanvas = PlayerMapMarker.ESPCanvas
    if not ParentCanvas or not slua.isValid(ParentCanvas) then 
        if not PlayerMapMarker.InitESPCanvas() then return false end
        ParentCanvas = PlayerMapMarker.ESPCanvas
    end

    if not ParentCanvas or not slua.isValid(ParentCanvas) then return false end

    local Container = nil
    pcall(function() Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", ParentCanvas) end)
    if not Container or not slua.isValid(Container) then return false end

    local FLinearColor = import("LinearColor") or FLinearColor
    local FVector2D = import("Vector2D") or FVector2D
    
    -- Layered red banner from the V2 visual reference.
    local CounterLayers = {
        {width = 300, height = 42, r = 0.003, g = 0.003, b = 0.006, a = 0.62, z = 0},
        {width = 288, height = 40, r = 0.95, g = 0.75, b = 0.02, a = 0.12, z = 1},
        {width = 276, height = 38, r = 0.95, g = 0.68, b = 0.01, a = 0.24, z = 2},
        {width = 264, height = 36, r = 1.00, g = 0.78, b = 0.02, a = 0.42, z = 3},
        {width = 252, height = 34, r = 1.00, g = 0.85, b = 0.03, a = 0.64, z = 4},
        {width = 240, height = 32, r = 1.00, g = 0.92, b = 0.06, a = 0.86, z = 5},
        {width = 228, height = 30, r = 1.00, g = 0.98, b = 0.12, a = 1.00, z = 6}
    }
    RedBoxOverlay.Layers = {}
    for _, layerConfig in ipairs(CounterLayers) do
        local border = nil
        pcall(function() border = CGame:NewObjectFromPath("/Script/UMG.Border", Container) end)
        if border and slua.isValid(border) then
            pcall(function()
                border:SetBrushColor(FLinearColor(layerConfig.r, layerConfig.g, layerConfig.b, layerConfig.a))
                border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            local slot = Container:AddChildToCanvas(border)
            if slot then
                pcall(function()
                    slot:SetPosition(FVector2D((RedBoxOverlay.Width - layerConfig.width) * 0.5, (RedBoxOverlay.Height - layerConfig.height) * 0.5))
                    slot:SetSize(FVector2D(layerConfig.width, layerConfig.height))
                    slot:SetZOrder(layerConfig.z)
                end)
                table.insert(RedBoxOverlay.Layers, {Widget = border, Slot = slot})
            end
        end
    end

    local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
    
    -- Text: Enemy: X | Bot: Y
    local txtBlock = nil
    pcall(function() txtBlock = CGame:NewObjectFromPath("/Script/UMG.TextBlock", Container) end)
    if txtBlock and slua.isValid(txtBlock) then
        pcall(function()
            local strText = string.format("Player: %d   Bot: %d", RedBoxOverlay.PlayerCount, RedBoxOverlay.BotCount)
            txtBlock:SetText(strText)
            RedBoxOverlay._CachedText = strText

            -- V2 reference uses white text on the red banner.
            local whiteTextColor = FLinearColor(0.01, 0.01, 0.01, 1.0)
            if FSlateColor then txtBlock:SetColorAndOpacity(FSlateColor(whiteTextColor)) else txtBlock:SetColorAndOpacity(whiteTextColor) end

            if txtBlock.Font then
                local font = txtBlock.Font
                font.Size = RedBoxOverlay.FontSize
                txtBlock.Font = font
            end
            txtBlock:SetRenderScale(FVector2D(RedBoxOverlay.TextScaleValue, RedBoxOverlay.TextScaleValue))
            txtBlock:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            txtBlock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        local txtSlot = Container:AddChildToCanvas(txtBlock)
        if txtSlot then
            pcall(function()
                txtSlot:SetAutoSize(true)
                txtSlot:SetAlignment(FVector2D(0.5, 0.5))
                txtSlot:SetPosition(FVector2D(RedBoxOverlay.Width * 0.5, RedBoxOverlay.Height * 0.5))
                txtSlot:SetZOrder(1000)
            end)
        end
        RedBoxOverlay.TextBlock = txtBlock
    end

    local MainSlot = nil
    pcall(function() MainSlot = ParentCanvas:AddChildToCanvas(Container) end)
    if not MainSlot then return false end

    RedBoxOverlay.MainContainer = Container
    RedBoxOverlay.WidgetSlot = MainSlot
    
    pcall(function()
        MainSlot:SetAutoSize(false)
        MainSlot:SetZOrder(999)
        MainSlot:SetAlignment(FVector2D(0.5, 0.0))
        MainSlot:SetSize(FVector2D(RedBoxOverlay.Width, RedBoxOverlay.Height))
    end)

    RedBoxOverlay.UpdatePosition()
    return true
end

function RedBoxOverlay.SetCounts(players, bots)
    local nearestMeters = 0
    pcall(function()
        local nearest = nil
        for _, data in pairs(PlayerMapMarker.ESPWidgets or {}) do
            local dist = tonumber(data and data.LastDistance)
            if dist and dist >= 0 then
                local meters = math.floor(dist / 100)
                if nearest == nil or meters < nearest then nearest = meters end
            end
        end
        nearestMeters = nearest or 0
    end)
    if RedBoxOverlay.PlayerCount == players and RedBoxOverlay.BotCount == bots and RedBoxOverlay.NearestDistance == nearestMeters then return end
    RedBoxOverlay.PlayerCount = players or 0
    RedBoxOverlay.BotCount = bots or 0
    RedBoxOverlay.NearestDistance = nearestMeters
    
    if RedBoxOverlay.TextBlock and slua.isValid(RedBoxOverlay.TextBlock) then
        pcall(function()
            local str = string.format("Player: %d   Bot: %d   Dist: %dm", RedBoxOverlay.PlayerCount, RedBoxOverlay.BotCount, RedBoxOverlay.NearestDistance)
            if RedBoxOverlay._CachedText ~= str then
                RedBoxOverlay.TextBlock:SetText(str)
                RedBoxOverlay._CachedText = str
            end
        end)
    end
end

function RedBoxOverlay.UpdatePosition()
    local Slot = RedBoxOverlay.WidgetSlot
    if not Slot or not slua.isValid(Slot) then return end
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not slua.isValid(PC) then return end

    local fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC)
    local FVector2D = import("Vector2D") or FVector2D
    pcall(function()
        if not RedBoxOverlay._CachedPosVec then
            RedBoxOverlay._CachedPosVec = FVector2D(fromX, fromY)
        else
            RedBoxOverlay._CachedPosVec.X = fromX
            RedBoxOverlay._CachedPosVec.Y = fromY
        end
        local counterPos = FVector2D(fromX, fromY - 30)
        if RedBoxOverlay._CachedPosVec then
            RedBoxOverlay._CachedPosVec.X = counterPos.X
            RedBoxOverlay._CachedPosVec.Y = counterPos.Y
        else
            RedBoxOverlay._CachedPosVec = counterPos
        end
        Slot:SetPosition(RedBoxOverlay._CachedPosVec)
        pcall(function()
            Slot:SetAlignment(FVector2D(0.5, 0.0))
            Slot:SetSize(FVector2D(RedBoxOverlay.Width, RedBoxOverlay.Height))
        end)
    end)
end

function RedBoxOverlay.Start()
    if RedBoxOverlay.bActive and RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then return end
    if RedBoxOverlay.Create() then
        RedBoxOverlay.bActive = true
        pcall(function() RedBoxOverlay.MainContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    end
end

function RedBoxOverlay.Stop()
    RedBoxOverlay.bActive = false
    if RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then
        pcall(function()
            RedBoxOverlay.MainContainer:RemoveFromParent()
            RedBoxOverlay.MainContainer:ConditionalBeginDestroy()
        end)
    end
    RedBoxOverlay.MainContainer = nil
    RedBoxOverlay.WidgetSlot = nil
    RedBoxOverlay.TextBlock = nil
    RedBoxOverlay.Layers = {}
    RedBoxOverlay.NearestDistance = 0
    RedBoxOverlay._CachedPosVec = nil
end

_G.RedBoxOverlay = RedBoxOverlay

-- ========================================================================
-- ⚡ ESP V2 SYSTEM (Continued) - FIXED
-- ========================================================================
local SlateBlueprintLibrary = nil
local WidgetLayoutLibrary = nil
local KismetMathLibrary_ESP9 = nil
local KismetSystemLibrary_ESP9 = nil

pcall(function() SlateBlueprintLibrary = import("SlateBlueprintLibrary") or import("/Script/UMG.SlateBlueprintLibrary") end)
pcall(function() WidgetLayoutLibrary = import("WidgetLayoutLibrary") or import("/Script/UMG.WidgetLayoutLibrary") end)
pcall(function() KismetMathLibrary_ESP9 = import("KismetMathLibrary") end)
pcall(function() KismetSystemLibrary_ESP9 = import("KismetSystemLibrary") end)

local FVector2D_ESP9 = _G.FVector2D or import("Vector2D")
local FLinearColor_ESP9 = _G.FLinearColor or import("LinearColor")
local FVector_ESP9 = _G.FVector or import("Vector")

PlayerMapMarker.MarkTypeID = 1007
PlayerMapMarker.bUseScreenESP = true
PlayerMapMarker.bUseScreenMark = false
PlayerMapMarker.bUseQuickSign = false
PlayerMapMarker.bUseNavigator = false
PlayerMapMarker.bUseWidgetComponent = false
PlayerMapMarker.ESPBoneName = "head"
PlayerMapMarker.ESPWorldOffsetZ = 0
PlayerMapMarker.ESPAnchorOffsetX = 35
PlayerMapMarker.ESPAnchorOffsetY = 0
PlayerMapMarker.ESPTextOffsetX = 0
PlayerMapMarker.ESPTextOffsetY = 0
PlayerMapMarker.ESPWidgetAlignment = FVector2D_ESP9 and FVector2D_ESP9(0.5, 1.0) or {X=0.5, Y=1.0}
PlayerMapMarker.ESPWidgetSize = FVector2D_ESP9 and FVector2D_ESP9(70, 21) or {X=70, Y=21}
PlayerMapMarker.ESPWidgetAutoSize = true
PlayerMapMarker.ESPWidgetZOrder = 2
PlayerMapMarker.bShowDistance = true
PlayerMapMarker.DistanceUnit = "m"
PlayerMapMarker.HPWidgetSwitcherTypeIndex = 0
PlayerMapMarker.HPWidgetSwitcherType2Index = 0
PlayerMapMarker.bForceSwitcherIndexEveryUpdate = true
PlayerMapMarker.bUseSnapLines = true
PlayerMapMarker.SnapLineThickness = 1.0
PlayerMapMarker.SnapLineOriginY = 50
PlayerMapMarker.SnapLineOriginOffsetX = 0
PlayerMapMarker.SnapLineHeadOffsetX = 0
PlayerMapMarker.SnapLineHeadOffsetY = -14
PlayerMapMarker.SnapLineColor = FLinearColor_ESP9 and FLinearColor_ESP9(0.6, 0.0, 0.0, 1.0) or {R=150, G=0, B=0, A=255}
PlayerMapMarker.SnapLineOpacity = 0.7

PlayerMapMarker.nUpdateInterval = 0.5
PlayerMapMarker.bUseFrameTick = false
PlayerMapMarker.nHeavyScanFrameInterval = 15
PlayerMapMarker.nDistanceUpdateFrameInterval = 5
PlayerMapMarker.bIncludeMe = false
PlayerMapMarker.bIncludeAI = true
PlayerMapMarker.bActive = false
PlayerMapMarker.PlayerInfo = {}
PlayerMapMarker.ESPCanvas = nil
PlayerMapMarker.ESPWidgets = {}
PlayerMapMarker.ESPWidgetPtrs = {}
PlayerMapMarker.SnapLineWidgets = {}
PlayerMapMarker._cachedViewportW = 1920
PlayerMapMarker._cachedViewportH = 1080
PlayerMapMarker._FrameCount = 0
PlayerMapMarker._bTickRegistered = false
PlayerMapMarker._CachedAllChars = nil
PlayerMapMarker._CachedMyLoc = nil
PlayerMapMarker._CachedMyKey = nil
PlayerMapMarker.WidgetComps = {}
PlayerMapMarker._bAllPathsFailed = false
PlayerMapMarker._bLightUpdateScheduled = false
PlayerMapMarker._LightUpdateInterval = 0.02
PlayerMapMarker._bDistanceUpdateScheduled = false
PlayerMapMarker._DistanceUpdateInterval = 0.1

local function IsValid_ESP9(obj)
    if obj == nil then return false end
    if slua and slua.isValid then return slua.isValid(obj) end
    return obj ~= nil
end

function PlayerMapMarker.GetGameplayData()
    if PlayerMapMarker._CachedGameplayData then return PlayerMapMarker._CachedGameplayData end
    local ok, GDP = pcall(function() return require("GameLua.GameCore.Data.GameplayData") end)
    if ok and GDP then PlayerMapMarker._CachedGameplayData = GDP return GDP end
    return nil
end

function PlayerMapMarker.GetMyPlayerController()
    local PC = PlayerMapMarker._CachedPC
    if PC and IsValid_ESP9(PC) then return PC end
    local GDP = PlayerMapMarker.GetGameplayData()
    if not GDP then return nil end
    pcall(function() PC = GDP.GetPlayerController and GDP.GetPlayerController() end)
    if PC and IsValid_ESP9(PC) then PlayerMapMarker._CachedPC = PC return PC end
    return nil
end

function PlayerMapMarker.GetCGameState()
    if CGameState and IsValid_ESP9(CGameState) then return CGameState end
    if PlayerMapMarker._CachedCGameState and IsValid_ESP9(PlayerMapMarker._CachedCGameState) then return PlayerMapMarker._CachedCGameState end
    local ok, GS = pcall(function() return require("GameLua.GameCore.Data.CGameState") end)
    if ok and GS then PlayerMapMarker._CachedCGameState = GS return GS end
    return nil
end

function PlayerMapMarker.GetAllCharacters()
    local AllChars = {}
    pcall(function()
        local Pawns = Game:GetAllPlayerPawns()
        if Pawns then
            for _, Pawn in pairs(Pawns) do
                if Pawn and slua.isValid(Pawn) then
                    local pKey = nil
                    if Pawn.GetPlayerKey then pKey = Pawn:GetPlayerKey() end
                    if not pKey and Pawn.PlayerKey then pKey = Pawn.PlayerKey end
                    if not pKey and Pawn.PlayerState and Pawn.PlayerState.PlayerKey then pKey = Pawn.PlayerState.PlayerKey end
                    if pKey then AllChars[pKey] = Pawn end
                end
            end
        end
    end)
    if not next(AllChars) then
        local GS = PlayerMapMarker.GetCGameState()
        if GS and GS.GetAllCharacters then pcall(function() AllChars = GS:GetAllCharacters() end) end
    end
    return AllChars
end

function PlayerMapMarker.GetMyPlayerKey()
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return nil end
    local MyKey = nil
    pcall(function()
        if PC.GetPlayerKey then MyKey = PC:GetPlayerKey()
        elseif PC.PlayerState and PC.PlayerState.PlayerKey then MyKey = PC.PlayerState.PlayerKey end
    end)
    return MyKey
end

function PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
    local bIsMe = false
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then
            local MyChar = GDP.GetLocalCharacter()
            if MyChar and Character == MyChar then bIsMe = true return end
        end
        local PC = PlayerMapMarker.GetMyPlayerController()
        if PC and PC.GetPawn then
            local Pawn = PC:GetPawn()
            if Pawn and Character == Pawn then bIsMe = true return end
        end
    end)
    if not bIsMe and MyKey ~= nil and PlayerKey ~= nil then bIsMe = (tostring(PlayerKey) == tostring(MyKey)) end
    return bIsMe
end

function PlayerMapMarker.GetCharacterLocation(Character)
    if not IsValid_ESP9(Character) then return nil end
    local Loc = nil
    pcall(function() if Character.K2_GetActorLocation then Loc = Character:K2_GetActorLocation() end end)
    if not Loc then pcall(function() if Game and Game.GetActorLocation then Loc = Game:GetActorLocation(Character) end end) end
    return Loc
end

function PlayerMapMarker.CalcDistance(Loc1, Loc2)
    if not Loc1 or not Loc2 then return nil end
    local Dist = nil
    pcall(function() if FVector_ESP9 and FVector_ESP9.Dist2D then Dist = FVector_ESP9.Dist2D(Loc1, Loc2) end end)
    if not Dist then
        pcall(function()
            local DX = (Loc1.X or 0) - (Loc2.X or 0)
            local DY = (Loc1.Y or 0) - (Loc2.Y or 0)
            Dist = math.sqrt(DX * DX + DY * DY)
        end)
    end
    return Dist
end

function PlayerMapMarker.GetDistanceString(MyLoc, TargetLoc)
    if not PlayerMapMarker.bShowDistance then return "" end
    if not MyLoc or not TargetLoc then return "" end
    local Dist = PlayerMapMarker.CalcDistance(MyLoc, TargetLoc)
    if not Dist then return "" end
    local Meters = Dist / 100
    if Meters < 1000 then return string.format("%dm", math.floor(Meters))
    else return string.format("%.1fkm", Meters / 1000) end
end

function PlayerMapMarker.GetMyLocation()
    local GDP = PlayerMapMarker.GetGameplayData()
    if not GDP then return nil end
    local MyChar = nil
    pcall(function() MyChar = GDP.GetLocalCharacter and GDP.GetLocalCharacter() end)
    if not IsValid_ESP9(MyChar) then return nil end
    return PlayerMapMarker.GetCharacterLocation(MyChar)
end

function PlayerMapMarker.GetPlayerName(Character)
    if not IsValid_ESP9(Character) then return "Unknown" end
    local Name = nil
    pcall(function() if Character.GetPlayerNameSafety then Name = Character:GetPlayerNameSafety() end end)
    if not Name then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety()
            elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if IsValid_ESP9(PS) and PS.GetPlayerName then Name = PS:GetPlayerName() end
        end)
    end
    return Name or "Unknown"
end

function PlayerMapMarker.IsAI(Character)
    local bAI = false
    pcall(function() if Game and Game.IsAI then bAI = Game:IsAI(Character) end end)
    return bAI
end

function PlayerMapMarker.IsAlive(Character)
    local bAlive = true
    pcall(function() if Character.IsAlive then bAlive = Character:IsAlive() end end)
    return bAlive
end

function PlayerMapMarker.GetTeamID(Character)
    if not IsValid_ESP9(Character) then return nil end
    local TeamID = nil
    pcall(function() if Character.GetTeamID then TeamID = Character:GetTeamID() end end)
    if not TeamID then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety()
            elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if IsValid_ESP9(PS) and PS.GetTeamID then TeamID = PS:GetTeamID()
            elseif IsValid_ESP9(PS) and PS.TeamID then TeamID = PS.TeamID end
        end)
    end
    if not TeamID then pcall(function() if Character.TeamID then TeamID = Character.TeamID end end) end
    return TeamID
end

function PlayerMapMarker.GetTeamColor(TeamID)
    if TeamID == nil or TeamID == 0 then
        return FLinearColor_ESP9 and FLinearColor_ESP9(0.2, 0.4, 1.0, 1.0) or {R=50,G=100,B=255,A=255}
    end
    local TeamColors = {
        [1]={R=255,G=50,B=50,A=255,fR=1.0,fG=0.2,fB=0.2},
        [2]={R=50,G=255,B=50,A=255,fR=0.2,fG=1.0,fB=0.2},
        [3]={R=50,G=100,B=255,A=255,fR=0.2,fG=0.4,fB=1.0},
        [4]={R=255,G=255,B=50,A=255,fR=1.0,fG=1.0,fB=0.2},
        [5]={R=255,G=50,B=255,A=255,fR=1.0,fG=0.2,fB=1.0},
        [6]={R=50,G=255,B=255,A=255,fR=0.2,fG=1.0,fB=1.0},
        [7]={R=255,G=150,B=50,A=255,fR=1.0,fG=0.6,fB=0.2},
        [8]={R=150,G=50,B=255,A=255,fR=0.6,fG=0.2,fB=1.0},
        [9]={R=200,G=255,B=50,A=255,fR=0.8,fG=1.0,fB=0.2},
        [10]={R=50,G=150,B=255,A=255,fR=0.2,fG=0.6,fB=1.0},
        [11]={R=255,G=100,B=150,A=255,fR=1.0,fG=0.4,fB=0.6},
        [12]={R=100,G=255,B=150,A=255,fR=0.4,fG=1.0,fB=0.6},
        [13]={R=150,G=150,B=50,A=255,fR=0.6,fG=0.6,fB=0.2},
        [14]={R=50,G=200,B=150,A=255,fR=0.2,fG=0.8,fB=0.6},
        [15]={R=255,G=200,B=50,A=255,fR=1.0,fG=0.8,fB=0.2}
    }
    local colorIndex = (TeamID % 15)
    if colorIndex == 0 then colorIndex = 15 end
    local c = TeamColors[colorIndex]
    return FLinearColor_ESP9 and FLinearColor_ESP9(c.fR, c.fG, c.fB, 1.0) or {R=c.R, G=c.G, B=c.B, A=c.A}
end

function PlayerMapMarker.InitESPCanvas()
    if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then return true end
    local InGameUITools = nil
    pcall(function() InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools") end)
    if not InGameUITools then return false end
    local MainControlBaseUI = nil
    pcall(function() MainControlBaseUI = InGameUITools.GetMainControlBaseUI() end)
    if not MainControlBaseUI or not Game:IsValid(MainControlBaseUI) then return false end
    local ParentCanvas = nil
    pcall(function()
        if MainControlBaseUI.CanvasPanel_0 and Game:IsValid(MainControlBaseUI.CanvasPanel_0) then ParentCanvas = MainControlBaseUI.CanvasPanel_0
        elseif MainControlBaseUI.CanvasPanel_42 and Game:IsValid(MainControlBaseUI.CanvasPanel_42) then ParentCanvas = MainControlBaseUI.CanvasPanel_42 end
    end)
    if not ParentCanvas then return false end
    PlayerMapMarker.ESPCanvas = ParentCanvas
    return true
end

function PlayerMapMarker.GetESPLocation(Character)
    if not IsValid_ESP9(Character) then return nil end
    local BoneLoc = PlayerMapMarker.GetCharacterLocation(Character)
    if BoneLoc then
        local heightOffset = 85
        pcall(function()
            if Character.bIsCrouched then heightOffset = 60 end
            if Character.IsProne and Character:IsProne() then heightOffset = 30 end
        end)
        pcall(function() BoneLoc.Z = BoneLoc.Z + heightOffset + (PlayerMapMarker.ESPWorldOffsetZ or 0) end)
    end
    return BoneLoc
end

function PlayerMapMarker.GetCharacterWeaponInfo(Character)
    if not IsValid_ESP9(Character) then return nil end
    local WeaponID, WeaponName, WeaponIconPath, WeaponIconTexture, CurrentWeapon = nil, nil, nil, nil, nil
    pcall(function() if Character.GetCurrentWeapon then CurrentWeapon = Character:GetCurrentWeapon() end end)
    if not CurrentWeapon then pcall(function() CurrentWeapon = Character.CurrentWeapon end) end
    if not CurrentWeapon then pcall(function() if Character.GetWeaponManager then local WM = Character:GetWeaponManager() if WM and WM.GetCurrentWeapon then CurrentWeapon = WM:GetCurrentWeapon() end end end) end
    if CurrentWeapon and IsValid_ESP9(CurrentWeapon) then
        pcall(function() if CurrentWeapon.GetWeaponID then WeaponID = CurrentWeapon:GetWeaponID() end end)
        if not WeaponID then pcall(function() WeaponID = CurrentWeapon.WeaponID end) end
        if not WeaponID then pcall(function() if CurrentWeapon.GetItemID then WeaponID = CurrentWeapon:GetItemID() end end) end
        pcall(function() if CurrentWeapon.GetWeaponName then WeaponName = CurrentWeapon:GetWeaponName() end end)
        pcall(function() if CurrentWeapon.GetWeaponIconPath then WeaponIconPath = CurrentWeapon:GetWeaponIconPath() end end)
        pcall(function() if CurrentWeapon.GetWeaponIcon then WeaponIconTexture = CurrentWeapon:GetWeaponIcon() end end)
    end
    if not WeaponID then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety() elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if PS and IsValid_ESP9(PS) then
                if PS.GetCurrentWeaponID then WeaponID = PS:GetCurrentWeaponID() end
                if not WeaponID and PS.CurWeaponID then WeaponID = PS.CurWeaponID end
            end
        end)
    end
    return { WeaponID = WeaponID, WeaponName = WeaponName, WeaponIconPath = WeaponIconPath, WeaponIconTexture = WeaponIconTexture, CurrentWeapon = CurrentWeapon }
end

PlayerMapMarker._OBHeadWidgetClass = nil
PlayerMapMarker._OBHeadWidgetLoadFailed = false

function PlayerMapMarker.CreateESPWidget()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end
    if PlayerMapMarker._OBHeadWidgetLoadFailed then return nil end

    if not PlayerMapMarker._OBHeadWidgetClass then
        pcall(function()
            local Path = "/Game/BluePrints/UI/OBUI/Item/OB_PlayerHeadHPItem_UIBP.OB_PlayerHeadHPItem_UIBP"
            local uClass = slua.loadClass(Path)
            if uClass then PlayerMapMarker._OBHeadWidgetClass = uClass end
        end)
        if not PlayerMapMarker._OBHeadWidgetClass then
            PlayerMapMarker._OBHeadWidgetLoadFailed = true
            return nil
        end
    end

    local Widget = nil
    pcall(function()
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local PC = PlayerMapMarker.GetMyPlayerController()
        local OuterObj = IsValid_ESP9(PC) and PC.Object or PlayerMapMarker.ESPCanvas
        Widget = STExtraBlueprintFunctionLibrary.CreateWidgetByClass(PlayerMapMarker._OBHeadWidgetClass, OuterObj)
    end)
    if not Widget then return nil end

    pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    pcall(function() Widget:SetRenderOpacity(1.0) end)

    local NameText = nil
    local HealthFill = nil
    pcall(function()
        NameText = Widget.TextBlock_TeamName
        if NameText and slua.isValid(NameText) then pcall(function() NameText:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) end
        if Widget.TextBlock_PlayerName and slua.isValid(Widget.TextBlock_PlayerName) then pcall(function() Widget.TextBlock_PlayerName:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) end
        local SizeBox_HP = Widget.SizeBox_HP
        if SizeBox_HP and slua.isValid(SizeBox_HP) then
            pcall(function() SizeBox_HP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            local ExistingChild = nil
            pcall(function() if SizeBox_HP.GetContent then ExistingChild = SizeBox_HP:GetContent() end end)
            if ExistingChild and slua.isValid(ExistingChild) then
                local FoundPB = PlayerMapMarker.FindProgressBarInWidget(ExistingChild, 0, 5)
                if FoundPB and slua.isValid(FoundPB) then HealthFill = FoundPB end
            end
        end
    end)

    local WidgetData = {
        Container = Widget,
        NameText = NameText,
        HealthFill = HealthFill,
        IsGameWidget = true,
        HasChildren = (NameText ~= nil)
    }
    return WidgetData
end

function PlayerMapMarker.FindProgressBarInWidget(WidgetObj, Depth, MaxDepth)
    if not WidgetObj or not slua.isValid(WidgetObj) then return nil end
    Depth = Depth or 0
    MaxDepth = MaxDepth or 5
    if Depth > MaxDepth then return nil end

    local bIsPB = false
    pcall(function() if WidgetObj.SetPercent and WidgetObj.SetFillColorAndOpacity then bIsPB = true end end)
    if bIsPB then return WidgetObj end

    local nChildren = 0
    pcall(function() if WidgetObj.GetChildrenCount then nChildren = WidgetObj:GetChildrenCount() end end)
    for i = 0, math.max(nChildren - 1, 0) do
        local child = nil
        pcall(function() child = WidgetObj:GetChildAt(i) end)
        if child and slua.isValid(child) then
            local result = PlayerMapMarker.FindProgressBarInWidget(child, Depth + 1, MaxDepth)
            if result then return result end
        end
    end
    return nil
end

function PlayerMapMarker.ApplyTeamColor(Widget, TeamID)
    if not Widget or not Widget.Container then return end
    if not _G.AK_GetVal("ESP9_Team") == 1 then return end
    local color = PlayerMapMarker.GetTeamColor(TeamID)
    if not color then return end
    pcall(function()
        local W = Widget.Container
        if not W or not slua.isValid(W) then return end
        if W.SetTeamColor then pcall(function() W:SetTeamColor(TeamID) end) end
    end)
end

function PlayerMapMarker.UpdateESPText(Widget, Text)
    if not Widget then return end
    if Widget._LastESPText == Text then return end
    Widget._LastESPText = Text

    local function applyText(w, txt)
        if not w or not slua.isValid(w) then return end
        if txt == "" then
            pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
            return
        else
            pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
        end
        pcall(function() w:SetText(txt) end)
    end

    if Widget.NameText and slua.isValid(Widget.NameText) then applyText(Widget.NameText, Text) end
    if Widget.IsGameWidget and Widget.Container then
        pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) then
                applyText(W.TextBlock_TeamName, Text)
                applyText(W.TextBlock_PlayerName, Text)
            end
        end)
    end
end

function PlayerMapMarker.UpdateESPHealth(Widget, pct)
    if not Widget then return end
    Widget.LastPct = pct
    local bShowHP = _G.AK_GetVal("ESP9_HP") == 1
    if not bShowHP then
        pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) and W.SizeBox_HP and slua.isValid(W.SizeBox_HP) then
                W.SizeBox_HP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
        end)
        return
    end
    pcall(function()
        local W = Widget.Container
        if W and slua.isValid(W) and W.SizeBox_HP and slua.isValid(W.SizeBox_HP) then
            W.SizeBox_HP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
    end)

    if PlayerMapMarker.bForceSwitcherIndexEveryUpdate and Widget.Container then
        pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) then
                if W.WidgetSwitcher_Type and slua.isValid(W.WidgetSwitcher_Type) then pcall(function() if W.WidgetSwitcher_Type.SetActiveWidgetIndex then W.WidgetSwitcher_Type:SetActiveWidgetIndex(PlayerMapMarker.HPWidgetSwitcherTypeIndex) end end) end
                if W.WidgetSwitcher_Type2 and slua.isValid(W.WidgetSwitcher_Type2) then pcall(function() if W.WidgetSwitcher_Type2.SetActiveWidgetIndex then W.WidgetSwitcher_Type2:SetActiveWidgetIndex(PlayerMapMarker.HPWidgetSwitcherType2Index) end end) end
            end
        end)
    end

    if Widget.HealthFill then
        local bValid = false
        pcall(function() bValid = slua.isValid(Widget.HealthFill) end)
        if bValid then
            pcall(function()
                if Widget.HealthFill.SetPercent then
                    Widget.HealthFill:SetPercent(pct)
                    local color
                    if pct > 0.5 then color = FLinearColor_ESP9 and FLinearColor_ESP9(0.0, 1.0, 0.0, 1.0) or {R=0,G=255,B=0,A=255}
                    elseif pct > 0.25 then color = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.5, 0.0, 1.0) or {R=255,G=128,B=0,A=255}
                    else color = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.0, 0.0, 1.0) or {R=255,G=0,B=0,A=255} end
                    if Widget.HealthFill.SetFillColorAndOpacity then Widget.HealthFill:SetFillColorAndOpacity(color) end
                end
            end)
        end
    end
end

function PlayerMapMarker.UpdateESPPositionWithPC(Widget, WorldLoc, PC, CanvasPos)
    if not Widget or not IsValid_ESP9(PC) then return false end

    local Container = Widget.Container or Widget
    local bOnScreen = true

    if not CanvasPos then
        if not WorldLoc then return false end
        bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, WorldLoc)
    end

    if not bOnScreen then pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) return false end

    pcall(function()
        local bShowAnyUI = _G.AK_GetVal("ESP9_Name") == 1 or _G.AK_GetVal("ESP9_Distance") == 1 or _G.AK_GetVal("ESP9_HP") == 1 or _G.AK_GetVal("ESP9_Team") == 1
        if bShowAnyUI then Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end

        if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then
            local ptr = tostring(Container)
            local Slot = PlayerMapMarker.ESPWidgetPtrs[ptr]
            if not Slot or not slua.isValid(Slot) then
                local addedSlot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Container)
                if addedSlot and slua.isValid(addedSlot) then
                    Slot = addedSlot
                    PlayerMapMarker.ESPWidgetPtrs[ptr] = addedSlot
                    pcall(function() Slot:SetAutoSize(true) end)
                    pcall(function() Slot:SetAlignment(FVector2D_ESP9 and FVector2D_ESP9(0.5, 1.0) or {X=0.5, Y=1.0}) end)
                    pcall(function() Slot:SetZOrder(PlayerMapMarker.ESPWidgetZOrder or 20) end)
                end
            end
            if Slot and slua.isValid(Slot) then
                local finalX = CanvasPos.X + (PlayerMapMarker.ESPAnchorOffsetX or 0)
                local finalY = CanvasPos.Y + (PlayerMapMarker.ESPAnchorOffsetY or 0)
                if not Widget._CachedPosVec then Widget._CachedPosVec = FVector2D_ESP9 and FVector2D_ESP9(finalX, finalY) or {X=finalX, Y=finalY}
                else Widget._CachedPosVec.X = finalX; Widget._CachedPosVec.Y = finalY end
                pcall(function() Slot:SetPosition(Widget._CachedPosVec) end)
            end
        end
    end)
    return true
end

PlayerMapMarker._CanvasScaleX = 1.0
PlayerMapMarker._CanvasScaleY = 1.0
PlayerMapMarker._CanvasOffsetX = 0.0
PlayerMapMarker._CanvasOffsetY = 0.0

function PlayerMapMarker.UpdateCanvasTransform(PC)
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local success = false
    pcall(function()
        local SBL = SlateBlueprintLibrary
        if SBL and SBL.AbsoluteToLocal then
            local cg = PlayerMapMarker.ESPCanvas:GetCachedGeometry()
            if cg then
                local pt0 = SBL.AbsoluteToLocal(cg, FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0})
                local pt1 = SBL.AbsoluteToLocal(cg, FVector2D_ESP9 and FVector2D_ESP9(100, 100) or {X=100, Y=100})
                if pt0 and pt1 then
                    PlayerMapMarker._CanvasScaleX = (pt1.X - pt0.X) / 100
                    PlayerMapMarker._CanvasScaleY = (pt1.Y - pt0.Y) / 100
                    PlayerMapMarker._CanvasOffsetX = pt0.X
                    PlayerMapMarker._CanvasOffsetY = pt0.Y
                    success = true
                end
            end
        end
    end)

    if not success then
        local scale = 1.0
        if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then scale = WidgetLayoutLibrary.GetViewportScale(PC) or 1.0 end
        PlayerMapMarker._CanvasScaleX = 1.0 / scale
        PlayerMapMarker._CanvasScaleY = 1.0 / scale
        PlayerMapMarker._CanvasOffsetX = 0
        PlayerMapMarker._CanvasOffsetY = 0
    end
end

function PlayerMapMarker.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
    if not ScreenPixelPos then return FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0} end
    local scaleX = PlayerMapMarker._CanvasScaleX or 1.0
    local scaleY = PlayerMapMarker._CanvasScaleY or 1.0
    local offsetX = PlayerMapMarker._CanvasOffsetX or 0
    local offsetY = PlayerMapMarker._CanvasOffsetY or 0
    return (FVector2D_ESP9 and FVector2D_ESP9(ScreenPixelPos.X * scaleX + offsetX, ScreenPixelPos.Y * scaleY + offsetY)) or {X = ScreenPixelPos.X * scaleX + offsetX, Y = ScreenPixelPos.Y * scaleY + offsetY}
end

function PlayerMapMarker.ProjectWorldToCanvasLocal(PC, WorldLoc)
    if not IsValid_ESP9(PC) or not WorldLoc then return false, (FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}) end

    local ScreenPixelPos = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}
    local bOK = false
    pcall(function()
        local res = PC:ProjectWorldLocationToScreen(WorldLoc, ScreenPixelPos, true)
        if res == true or res == 1 or (ScreenPixelPos and (ScreenPixelPos.X ~= 0 or ScreenPixelPos.Y ~= 0)) then bOK = true end
    end)

    if not bOK or not ScreenPixelPos or (ScreenPixelPos.X == 0 and ScreenPixelPos.Y == 0) then return false, (FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}) end

    local CanvasLocalPos = PlayerMapMarker.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
    return true, CanvasLocalPos
end

function PlayerMapMarker.GetSnapLineStartPos(PC)
    local screenPixelW, screenPixelH = 0, 0
    local scale = 1.0

    pcall(function()
        if PC and PC.GetViewportSize then
            local vs = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0,Y=0}
            PC:GetViewportSize(vs)
            if vs and vs.X and vs.X > 200 then screenPixelW = vs.X screenPixelH = vs.Y end
        end
    end)

    if screenPixelW <= 200 then
        pcall(function()
            local WLL = WidgetLayoutLibrary
            if WLL and WLL.GetViewportSize then
                local vs = WLL.GetViewportSize(PC)
                if vs and vs.X and vs.X > 200 then screenPixelW = vs.X screenPixelH = vs.Y end
            end
        end)
    end

    pcall(function()
        local WLL = WidgetLayoutLibrary
        if WLL and WLL.GetViewportScale then
            local s = WLL.GetViewportScale(PC)
            if s and type(s) == "number" and s > 0 then scale = s end
        end
    end)

    if screenPixelW <= 200 then
        screenPixelW = (PlayerMapMarker._cachedViewportW or 1920) * scale
        screenPixelH = (PlayerMapMarker._cachedViewportH or 1080) * scale
    end

    if not PlayerMapMarker._CachedTopCenterPixel then PlayerMapMarker._CachedTopCenterPixel = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0,Y=0} end
    PlayerMapMarker._CachedTopCenterPixel.X = screenPixelW / 2.0
    PlayerMapMarker._CachedTopCenterPixel.Y = (PlayerMapMarker.SnapLineOriginY or 50) * scale

    local fromCanvasPos = PlayerMapMarker.ScreenPixelToCanvasLocal(PC, PlayerMapMarker._CachedTopCenterPixel)
    return fromCanvasPos.X + (PlayerMapMarker.SnapLineOriginOffsetX or 0), fromCanvasPos.Y
end

function PlayerMapMarker.CreateSnapLine()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end

    local Border = nil
    pcall(function() Border = CGame:NewObjectFromPath("/Script/UMG.Border", PlayerMapMarker.ESPCanvas) end)
    if not Border or not slua.isValid(Border) then return nil end

    local color = PlayerMapMarker.SnapLineColor or (FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 1.0, 1.0, PlayerMapMarker.SnapLineOpacity or 0.7) or {R=1,G=1,B=1,A=PlayerMapMarker.SnapLineOpacity or 0.7})
    pcall(function() Border:SetBrushColor(color) end)
    pcall(function() Border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    pcall(function() Border.RenderTransformPivot = FVector2D_ESP9 and FVector2D_ESP9(0.0, 0.5) or {X=0,Y=0.5} end)
    pcall(function() Border:SetRenderTransformPivot(FVector2D_ESP9 and FVector2D_ESP9(0.0, 0.5) or {X=0,Y=0.5}) end)

    local Slot = nil
    pcall(function()
        Slot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Border)
        if Slot then Slot:SetAutoSize(false) Slot:SetZOrder(1) end
    end)
    return { Widget = Border, Slot = Slot }
end

function PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
    if not PlayerMapMarker.bUseSnapLines then return end
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local LineData = PlayerMapMarker.SnapLineWidgets[KeyStr]
    if LineData and (not LineData.Widget or not slua.isValid(LineData.Widget) or not LineData.Slot) then
        PlayerMapMarker.RemoveSnapLine(KeyStr)
        LineData = nil
    end
    if not bOnScreen or not CanvasPos then
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            pcall(function() LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
        end
        return
    end

    if not LineData then
        LineData = PlayerMapMarker.CreateSnapLine()
        if not LineData or not LineData.Widget or not LineData.Slot then return end
        PlayerMapMarker.SnapLineWidgets[KeyStr] = LineData
    end

    local Widget = LineData.Widget
    local Slot = LineData.Slot

    pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)

    local toX = CanvasPos.X + (PlayerMapMarker.SnapLineHeadOffsetX or 0)
    local toY = CanvasPos.Y + (PlayerMapMarker.SnapLineHeadOffsetY or 0)

    local dx = toX - fromX
    local dy = toY - fromY
    local length = math.sqrt(dx * dx + dy * dy)
    local thickness = PlayerMapMarker.SnapLineThickness or 1.5
    local angle_rad = 0
    if math.atan2 then angle_rad = math.atan2(dy, dx) else angle_rad = math.atan(dy, dx) end
    local angle = angle_rad * (180.0 / math.pi)

    if not LineData._CachedPosVec then
        LineData._CachedPosVec = FVector2D_ESP9 and FVector2D_ESP9(fromX, fromY - thickness / 2.0) or {X=fromX, Y=fromY - thickness / 2.0}
        LineData._CachedSizeVec = FVector2D_ESP9 and FVector2D_ESP9(length, thickness) or {X=length, Y=thickness}
    else
        LineData._CachedPosVec.X = fromX; LineData._CachedPosVec.Y = fromY - thickness / 2.0
        LineData._CachedSizeVec.X = length; LineData._CachedSizeVec.Y = thickness
    end

    pcall(function()
        Slot:SetPosition(LineData._CachedPosVec)
        Slot:SetSize(LineData._CachedSizeVec)
    end)
    pcall(function() Widget:SetRenderAngle(angle) end)
end

function PlayerMapMarker.RemoveSnapLine(KeyStr)
    local LineData = PlayerMapMarker.SnapLineWidgets[KeyStr]
    if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
        pcall(function() LineData.Widget:RemoveFromParent() LineData.Widget:ConditionalBeginDestroy() end)
    end
    -- Always clear the record, including invalid/stale widget handles.
    PlayerMapMarker.SnapLineWidgets[KeyStr] = nil
end

function PlayerMapMarker.RemoveESPWidget(Widget, KeyStr)
    if not Widget then return end
    local Container = Widget.Container or Widget
    pcall(function()
        local ptr = tostring(Container)
        PlayerMapMarker.ESPWidgetPtrs[ptr] = nil
        Container:RemoveFromParent()
        Container:ConditionalBeginDestroy()
    end)
    if KeyStr then
        PlayerMapMarker.RemoveSnapLine(KeyStr)
    end
end

function PlayerMapMarker.ClearAllSnapLines()
    for KeyStr, LineData in pairs(PlayerMapMarker.SnapLineWidgets) do
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            pcall(function() LineData.Widget:RemoveFromParent() LineData.Widget:ConditionalBeginDestroy() end)
        end
    end
    PlayerMapMarker.SnapLineWidgets = {}
end

function PlayerMapMarker.ScreenPixelToCanvasLocalRaw(PC, screenX, screenY)
    local scaleX = PlayerMapMarker._CanvasScaleX or 1.0
    local scaleY = PlayerMapMarker._CanvasScaleY or 1.0
    local offsetX = PlayerMapMarker._CanvasOffsetX or 0
    local offsetY = PlayerMapMarker._CanvasOffsetY or 0
    return screenX * scaleX + offsetX, screenY * scaleY + offsetY
end

function PlayerMapMarker.ProjectWorldToCanvasLocalRaw(PC, WorldLoc)
    if not IsValid_ESP9(PC) or not WorldLoc then return false, 0, 0 end

    if not PlayerMapMarker._tempScreenPixelPos then
        PlayerMapMarker._tempScreenPixelPos = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}
    end
    local tempPos = PlayerMapMarker._tempScreenPixelPos

    local bOK = false
    pcall(function()
        local res = PC:ProjectWorldLocationToScreen(WorldLoc, tempPos, true)
        if res == true or res == 1 then bOK = true end
    end)

    if not bOK or (tempPos.X == 0 and tempPos.Y == 0) then return false, 0, 0 end

    local canvasX, canvasY = PlayerMapMarker.ScreenPixelToCanvasLocalRaw(PC, tempPos.X, tempPos.Y)
    return true, canvasX, canvasY
end

function PlayerMapMarker.ClearAllESP()
    RedBoxOverlay.Stop()
    for KeyStr, Data in pairs(PlayerMapMarker.ESPWidgets) do
        PlayerMapMarker.RemoveESPWidget(Data.Widget, KeyStr)
    end
    PlayerMapMarker.ESPWidgets = {}
    PlayerMapMarker.ESPWidgetPtrs = {}
    PlayerMapMarker.ClearAllSnapLines()
    PlayerMapMarker.ESPCanvas = nil
    PlayerMapMarker._OBHeadWidgetClass = nil
    PlayerMapMarker._OBHeadWidgetLoadFailed = false
    PlayerMapMarker._cachedViewportW = 1920
    PlayerMapMarker._cachedViewportH = 1080
end

function PlayerMapMarker.UpdateESP(AllPlayers, MyLoc)
    if not PlayerMapMarker.bUseScreenESP then return end

    PlayerMapMarker.bUseSnapLines = _G.AK_GetVal("ESP9_Line") == 1

    if not PlayerMapMarker.InitESPCanvas() then return end
    if PlayerMapMarker._OBHeadWidgetLoadFailed then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if IsValid_ESP9(PC) then PlayerMapMarker.UpdateCanvasTransform(PC) end

    local fromX, fromY = 0, 0
    if PlayerMapMarker.bUseSnapLines and IsValid_ESP9(PC) then
        fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC)
    end

    local MyKey = PlayerMapMarker.GetMyPlayerKey()
    local SeenKeys = {}
    local MyChar = nil
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
        else if PC and PC.GetPawn then MyChar = PC:GetPawn() end end
    end)

    local MyTeamID = PlayerMapMarker.GetTeamID(MyChar)

    for PlayerKey, Character in pairs(AllPlayers) do
        if IsValid_ESP9(Character) then
            local bIsMe = PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
            local bIsAI = PlayerMapMarker.IsAI(Character)
            local KeyStr = tostring(PlayerKey)
            local Name = PlayerMapMarker.GetPlayerName(Character)
            local Loc = PlayerMapMarker.GetESPLocation(Character)
            local DistStr = ""
            if MyLoc and Loc then DistStr = PlayerMapMarker.GetDistanceString(MyLoc, Loc) end

            local bSkip = false
            if bIsMe and not PlayerMapMarker.bIncludeMe then bSkip = true end
            if bIsAI and not PlayerMapMarker.bIncludeAI then bSkip = true end

            local TeamID = PlayerMapMarker.GetTeamID(Character)
            if MyTeamID ~= nil and TeamID == MyTeamID and not bIsMe then bSkip = true end

            local bIsAlive = PlayerMapMarker.IsAlive(Character)

            if not bSkip and Loc then
                SeenKeys[KeyStr] = true
                local ESPData = PlayerMapMarker.ESPWidgets[KeyStr]

                local Text = ""
                if _G.AK_GetVal("ESP9_Name") == 1 then Text = Name end
                if _G.AK_GetVal("ESP9_Distance") == 1 and DistStr ~= "" then
                    if Text ~= "" then Text = string.format("%s [%s]", Text, DistStr) else Text = string.format("[%s]", DistStr) end
                end

                local bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, Loc)

                if not ESPData then
                    local Widget = PlayerMapMarker.CreateESPWidget()
                    if Widget then
                        PlayerMapMarker.ESPWidgets[KeyStr] = { Widget = Widget, Character = Character, Name = Name, LastDistStr = DistStr, TeamID = TeamID }
                        PlayerMapMarker.UpdateESPText(Widget, Text)
                        if bIsAlive then
                            PlayerMapMarker.UpdateESPPositionWithPC(Widget, Loc, PC, CanvasPos)
                            PlayerMapMarker.ApplyTeamColor(Widget, TeamID)
                            local HP = Character.Health or 0
                            local MaxHP = Character.MaxHealth or 120
                            local pct = 0
                            if HP > 0 and MaxHP > 0 then pct = HP / MaxHP; if pct > 1 then pct = 1 end; if pct < 0 then pct = 0 end end
                            PlayerMapMarker.UpdateESPHealth(Widget, pct)
                                                    if PlayerMapMarker.bUseSnapLines then
                                PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                            else
                                PlayerMapMarker.RemoveSnapLine(KeyStr)
                            end
                        else
                            local Container = Widget.Container or Widget
                            pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                            PlayerMapMarker.UpdateESPHealth(Widget, 0)
                            PlayerMapMarker.RemoveSnapLine(KeyStr)
                        end
                    end
                else
                    ESPData.Character = Character
                    ESPData.Name = Name
                    ESPData.LastDistStr = DistStr
                    ESPData.TeamID = TeamID
                    PlayerMapMarker.ApplyTeamColor(ESPData.Widget, TeamID)
                    ESPData.Widget._LastESPText = nil
                    PlayerMapMarker.UpdateESPText(ESPData.Widget, Text)
                    PlayerMapMarker.UpdateESPPositionWithPC(ESPData.Widget, Loc, PC, CanvasPos)

                    local HP = Character.Health or 0
                    local MaxHP = Character.MaxHealth or 120
                    local pct = 0
                    if HP > 0 and MaxHP > 0 then pct = HP / MaxHP; if pct > 1 then pct = 1 end; if pct < 0 then pct = 0 end end
                    PlayerMapMarker.UpdateESPHealth(ESPData.Widget, pct)

                    if PlayerMapMarker.bUseSnapLines then
                        PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                    else
                        PlayerMapMarker.RemoveSnapLine(KeyStr)
                    end
                end
            end
        end
    end

    for KeyStr, Data in pairs(PlayerMapMarker.ESPWidgets) do
        if not SeenKeys[KeyStr] then
            PlayerMapMarker.RemoveESPWidget(Data.Widget, KeyStr)
            PlayerMapMarker.ESPWidgets[KeyStr] = nil
        end
    end
    -- Remove any line whose target record no longer exists; this prevents stale left-side flicker.
    for KeyStr in pairs(PlayerMapMarker.SnapLineWidgets) do
        if not PlayerMapMarker.ESPWidgets[KeyStr] then PlayerMapMarker.RemoveSnapLine(KeyStr) end
    end
end

function PlayerMapMarker.UpdateESPLight()
    if RedBoxOverlay and RedBoxOverlay.bActive then RedBoxOverlay.UpdatePosition() end
    if not PlayerMapMarker.bUseScreenESP then return end

    PlayerMapMarker.bUseSnapLines = _G.AK_GetVal("ESP9_Line") == 1

    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return end

    PlayerMapMarker.UpdateCanvasTransform(PC)

    local fromX, fromY = 0, 0
    if PlayerMapMarker.bUseSnapLines then fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC) end

    for KeyStr, ESPData in pairs(PlayerMapMarker.ESPWidgets) do
        local Widget = ESPData.Widget
        local Character = ESPData.Character
        local Container = Widget and (Widget.Container or Widget)
        local bWidgetValid = false
        pcall(function() bWidgetValid = Container and slua.isValid(Container) end)

        if Widget and bWidgetValid and Character and IsValid_ESP9(Character) then
            local bIsAlive = PlayerMapMarker.IsAlive(Character)
            if not bIsAlive then
                pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                PlayerMapMarker.RemoveSnapLine(KeyStr)
            else
                local bShowAnyUI = _G.AK_GetVal("ESP9_Name") == 1 or _G.AK_GetVal("ESP9_Distance") == 1 or _G.AK_GetVal("ESP9_HP") == 1 or _G.AK_GetVal("ESP9_Team") == 1
                if bShowAnyUI then
                    pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                else
                    pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                end

                local Loc = PlayerMapMarker.GetESPLocation(Character)
                if Loc then
                    local bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, Loc)
                    PlayerMapMarker.UpdateESPPositionWithPC(Widget, Loc, PC, CanvasPos)

                    if PlayerMapMarker.bUseSnapLines then PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                    else PlayerMapMarker.RemoveSnapLine(KeyStr) end

                else
                    PlayerMapMarker.RemoveSnapLine(KeyStr)
                end
            end
        end
    end
end

function PlayerMapMarker.UpdateESPDistances()
    if not PlayerMapMarker.bUseScreenESP then return end

    local MyLoc = PlayerMapMarker.GetMyLocation()
    if not MyLoc then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return end

    PlayerMapMarker.UpdateCanvasTransform(PC)

    for KeyStr, ESPData in pairs(PlayerMapMarker.ESPWidgets) do
        local Character = ESPData.Character
        local Widget = ESPData.Widget
        local Container = Widget and (Widget.Container or Widget)
        local bWidgetValid = false
        pcall(function() bWidgetValid = Container and slua.isValid(Container) end)

        if Character and IsValid_ESP9(Character) and Widget and bWidgetValid then
            local Loc = PlayerMapMarker.GetESPLocation(Character)
            if Loc then
                local Dist = PlayerMapMarker.CalcDistance(MyLoc, Loc)
                ESPData.LastDistance = Dist

                if PlayerMapMarker.bShowDistance then
                    local DistStr = ""
                    local Meters = 0
                    if Dist then
                        Meters = Dist / 100
                        if Meters < 1000 then DistStr = string.format("%dm", math.floor(Meters))
                        else DistStr = string.format("%.1fkm", Meters / 1000) end
                    end

                    local Name = ESPData.Name or "Unknown"
                    local Text = ""
                    if _G.AK_GetVal("ESP9_Name") == 1 then Text = Name end
                    if _G.AK_GetVal("ESP9_Distance") == 1 and DistStr ~= "" then
                        if Text ~= "" then Text = string.format("%s [%s]", Text, DistStr) else Text = string.format("[%s]", DistStr) end
                    end

                    ESPData.LastDistStr = DistStr
                    Widget._LastESPText = nil
                    PlayerMapMarker.UpdateESPText(Widget, Text)
                end
            end
        end
    end
end


function PlayerMapMarker.ScanAndUpdate()
    local AllChars = PlayerMapMarker.GetAllCharacters()
    if not AllChars then RedBoxOverlay.SetCounts(0, 0) return 0 end

    local MyKey = PlayerMapMarker.GetMyPlayerKey()
    local MyLoc = PlayerMapMarker.GetMyLocation()
    local MyChar = nil
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
        else local PC = PlayerMapMarker.GetMyPlayerController() if PC and PC.GetPawn then MyChar = PC:GetPawn() end end
    end)

    local MyTeamID = PlayerMapMarker.GetTeamID(MyChar)
    local realPlayers = 0
    local botPlayers = 0

    for PlayerKey, Character in pairs(AllChars) do
        if IsValid_ESP9(Character) then
            local bIsMe = PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
            local bIsAI = PlayerMapMarker.IsAI(Character)
            local bIsAlive = PlayerMapMarker.IsAlive(Character)

            if bIsAlive and not bIsMe then
                local bIsMyTeam = false
                if MyTeamID ~= nil then
                    local targetTeamID = PlayerMapMarker.GetTeamID(Character)
                    if targetTeamID == MyTeamID then bIsMyTeam = true end
                end
                if not bIsMyTeam then
                    if bIsAI then botPlayers = botPlayers + 1
                    else realPlayers = realPlayers + 1 end
                end
            end
        end
    end

    if _G.AK_GetVal("ESP9_Count") == 1 then
        if RedBoxOverlay.bActive then RedBoxOverlay.SetCounts(realPlayers, botPlayers)
        else RedBoxOverlay.Start() end
    else
        if RedBoxOverlay.bActive then RedBoxOverlay.Stop() end
    end

    if PlayerMapMarker.bUseScreenESP then
        PlayerMapMarker.UpdateESP(AllChars, MyLoc)
    end

    return 0
end

function PlayerMapMarker.AttachTimers()
    pcall(function()
        local pc = PlayerMapMarker.GetMyPlayerController()
        if not slua.isValid(pc) or not pc.AddGameTimer then return end

        pcall(function() pc:AddGameTimer(PlayerMapMarker.nUpdateInterval or 0.5, true, function() if PlayerMapMarker.bActive then pcall(function() PlayerMapMarker.ScanAndUpdate() end) end end) end)
        pcall(function() pc:AddGameTimer(PlayerMapMarker._LightUpdateInterval or 0.02, true, function() if PlayerMapMarker.bActive then pcall(function() PlayerMapMarker.UpdateESPLight() end) end end) end)
        pcall(function() pc:AddGameTimer(PlayerMapMarker._DistanceUpdateInterval or 0.1, true, function() if PlayerMapMarker.bActive and PlayerMapMarker.bUseScreenESP and PlayerMapMarker.bShowDistance then pcall(function() PlayerMapMarker.UpdateESPDistances() end) end end) end)
    end)
end

function PlayerMapMarker.Start()
    if PlayerMapMarker.bActive then return end
    PlayerMapMarker.bActive = true
    PlayerMapMarker._FrameCount = 0
    PlayerMapMarker.ScanAndUpdate()
    PlayerMapMarker.AttachTimers()
end

function PlayerMapMarker.Stop()
    PlayerMapMarker.bActive = false
    PlayerMapMarker._FrameCount = 0
    PlayerMapMarker.ClearAllESP()
end

_G.PlayerMapMarker = PlayerMapMarker
-- ========================================================================
-- V6 WALLHACK/CHAMS IMPLEMENTATION
-- ========================================================================
pcall(function()
    print("[10.lua] Chams loading...")
    
    local FLinearColor = import("LinearColor")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
    
    local chamsTimer = nil
    local processedPawns = {}
    local tickCount = 0
    local chamsReady = false
    
    -- ===== SETTINGS =====
    local UPDATE_INTERVAL = 0.3        -- Har 0.3s update (naye spawn jaldi detect)
    local MAX_PER_TICK = 20            -- Ek frame mein max 20 players
    local CACHE_CLEAR_TICKS = 6        -- Har 6 tick (~1.8s) mein cache clear
    local AVATAR_SLOTS = {0, 1, 2, 3, 4, 5, 6, 7}  -- Full body slots
    
    local colors = nil
    
    -- ===== ENABLE CONSOLE COMMANDS =====
    local function EnableChamsConsole()
        if chamsReady then return end
        pcall(function()
            local KSL = import("KismetSystemLibrary")
            local world = slua.getWorld()
            if not KSL or not world then return end
            
            KSL.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1")
            KSL.ExecuteConsoleCommand(world, "r.CustomDepth 3")
            KSL.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
            KSL.ExecuteConsoleCommand(world, "r.Highlight.Enable 1")
            
            chamsReady = true
            print("[10.lua] Console ready")
        end)
    end
    
    -- ===== SETUP COLORS =====
    if FLinearColor then
        colors = {
            vis = FLinearColor(1.5, 0.0, 0.0, 1.0),       -- Red (visible)
            occ = FLinearColor(0, 10, 0, 1),                -- Green (behind wall)
            bVis = FLinearColor(1.8, 0.3, 9.0, 1.0),        -- Blue (bot visible)
            bOcc = FLinearColor(1.5, 1.5, 1.5, 1.0)         -- White (bot hidden)
        }
    end
    
    -- ===== APPLY CHAMS TO MESH =====
    local function ApplyChamsToMesh(mesh, visColor, occColor)
        if not mesh or not slua.isValid(mesh) then return end
        
        pcall(function()
            mesh:SetDrawDyeing(true)
            mesh:SetDrawDyeingMode(1)
            mesh:SetVisibleDyeingColor(visColor)
            mesh:SetOccludedDyeingColor(occColor)
            mesh:SetDyeingColorFadeDistance(99999.0)
            mesh:SetDyeingColorMinMaxDistance(0.0, 99999.0)
        end)
        
        pcall(function()
            mesh:SetDrawHighlight(true)
            mesh:OverrideHighlightColor(visColor)
            mesh:SetHighlightCanBeOccluded(false)
        end)
        
        pcall(function()
            mesh:SetDrawIdeaOutline(true)
            mesh:SetIdeaOutlineNew(true)
            mesh:SetIdeaOutlineOcclusionHighlight(true)
            mesh:OverrideIdeaOutlineColor(visColor)
            mesh:SetIdeaOutlineOcclusionColor(occColor)
            mesh:OverrideIdeaOutlineThickness(3.0)
            mesh:SetIdeaOverrideOutlineAndOcclusion(true)
        end)
        
        pcall(function()
            mesh:SetRenderCustomDepth(true)
            mesh:SetCustomDepthStencilValue(255)
        end)
    end
    
    -- ===== CHECK IF ALIVE =====
    local function IsAlive(pawn)
        if not slua.isValid(pawn) then return false end
        
        -- Fast check
        local hp = pawn.Health
        if hp and hp > 0 then return true end
        
        -- Fallback
        local status = pawn.HealthStatus
        if status then
            return SecurityCommonUtils.IsHealthStatusAlive(status)
        end
        
        return false
    end
    
    -- ===== PROCESS SINGLE ENEMY =====
    local function ProcessEnemy(pawn, myTeamID)
        if not slua.isValid(pawn) then return false end
        if not IsAlive(pawn) then return false end
        
        local teamID = pawn.TeamID
        if not teamID or teamID <= 0 or teamID == myTeamID then return false end
        
        -- Bot check
        local isBot = false
        pcall(function() isBot = Game:IsAI(pawn) end)
        
        local visColor = isBot and colors.bVis or colors.vis
        local occColor = isBot and colors.bOcc or colors.occ
        
        -- Main body mesh
        pcall(function()
            if pawn.Mesh and slua.isValid(pawn.Mesh) then
                ApplyChamsToMesh(pawn.Mesh, visColor, occColor)
            end
        end)
        
        -- Avatar parts (full body)
        pcall(function()
            local avatarComp = pawn.CharacterAvatarComp2_BP or pawn:getAvatarComponent2()
            if avatarComp and slua.isValid(avatarComp) and avatarComp.GetMeshCompBySlot then
                for _, slot in ipairs(AVATAR_SLOTS) do
                    pcall(function()
                        local meshComp = avatarComp:GetMeshCompBySlot(slot)
                        if meshComp and slua.isValid(meshComp) then
                            ApplyChamsToMesh(meshComp, visColor, occColor)
                        end
                    end)
                end
            end
        end)
        
        -- Weapon mesh
        pcall(function()
            local weapon = pawn:GetCurrentWeapon()
            if weapon and slua.isValid(weapon) and weapon.Mesh then
                ApplyChamsToMesh(weapon.Mesh, visColor, occColor)
            end
        end)
        
        -- Cache mark
        local playerKey = pawn.PlayerKey
        if playerKey then
            processedPawns[playerKey] = true
        end
        
        return true
    end
    
    -- ===== MAIN UPDATE LOOP =====
    local function UpdateChams()
        pcall(function()
            local localPlayer = GameplayData.GetPlayerCharacter()
            if not slua.isValid(localPlayer) then return end
            
            EnableChamsConsole()
            if not colors then return end
            
            tickCount = tickCount + 1
            
            -- Clear cache periodically to catch NEW spawns
            if tickCount % CACHE_CLEAR_TICKS == 0 then
                processedPawns = {}
            end
            
            local myTeamID = localPlayer.TeamID
            local allChars = Game:GetAllPlayerPawns() or {}
            
            local count = 0
            for _, target in pairs(allChars) do
                if count >= MAX_PER_TICK then break end
                
                -- Skip if already processed in this cycle
                local playerKey = target.PlayerKey
                if playerKey and processedPawns[playerKey] then
                    goto continue
                end
                
                if ProcessEnemy(target, myTeamID) then
                    count = count + 1
                end
                
                ::continue::
            end
        end)
    end
    
    -- ===== START CHAMS =====
    local function StartChams()
        EnableChamsConsole()
        
        -- Game timer (survives player death/respawn)
        if _G.Game and _G.Game.AddGameTimer then
            if chamsTimer then
                pcall(function() _G.Game:RemoveGameTimer(chamsTimer) end)
            end
            chamsTimer = _G.Game:AddGameTimer(UPDATE_INTERVAL, true, UpdateChams)
            print("[10.lua] Chams Active - Green=Wall, Red=Visible, Blue=Bot Visible, White=Bot Hidden")
            return true
        end
        
        -- Fallback: PC timer
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and pc.AddGameTimer then
            if chamsTimer then
                pcall(function() pc:RemoveGameTimer(chamsTimer) end)
            end
            chamsTimer = pc:AddGameTimer(UPDATE_INTERVAL, true, UpdateChams)
            print("[10.lua] ✅ Chams Active on PC!")
            return true
        end
        
        return false
    end
    
    -- ===== RETRY START =====
    local retryCount = 0
    local function Retry()
        if retryCount >= 30 then
            print("[10.lua] ❌ Failed to start!")
            return
        end
        retryCount = retryCount + 1
        
        if StartChams() then
            print("[10.lua] ✅ Module ready!")
        else
            if _G.Game and _G.Game.AddGameTimer then
                _G.Game:AddGameTimer(1.0, false, Retry)
            end
        end
    end
    
    -- Expose the V6 lifecycle to the single WALLHACK toggle.
    _G.StartV6Wallhack = function()
        if chamsTimer then return true end
        if not colors and FLinearColor then
            colors = {
                vis = FLinearColor(1.5, 0.0, 0.0, 1.0),
                occ = FLinearColor(0, 10, 0, 1),
                bVis = FLinearColor(1.8, 0.3, 9.0, 1.0),
                bOcc = FLinearColor(1.5, 1.5, 1.5, 1.0)
            }
        end
        retryCount = 0
        return StartChams()
    end
    _G.StopV6Wallhack = function()
        _chams_Cleanup()
    end

    -- ===== CLEANUP =====
    function _chams_Cleanup()
        if chamsTimer then
            pcall(function()
                if _G.Game then _G.Game:RemoveGameTimer(chamsTimer) end
            end)
            chamsTimer = nil
        end
        processedPawns = {}
        chamsReady = false
        colors = nil
        print("[10.lua] 🧹 Cleanup done")
    end
    
    print("[10.lua] ✅ Loaded successfully!")
end)
local NewFreshCreditOverlay = {Widget = nil, Slot = nil}
local function NewFreshCredit()
    pcall(function()
        if NewFreshCreditOverlay.Widget and slua.isValid(NewFreshCreditOverlay.Widget) then
            NewFreshCreditOverlay.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            return
        end
        local uiTools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local mainUI = uiTools and uiTools.GetMainControlBaseUI and uiTools.GetMainControlBaseUI()
        local parent = mainUI and (mainUI.CanvasPanel_0 or mainUI.CanvasPanel_42)
        if not parent or not slua.isValid(parent) then return end
        local txt = nil
        pcall(function() txt = CGame:NewObjectFromPath("/Script/UMG.TextBlock", parent) end)
        if not txt or not slua.isValid(txt) then return end
        local linear = import("LinearColor")
        local slate = import("SlateColor") or import("/Script/SlateCore.SlateColor")
        local yellow = linear and linear(1.0, 1.0, 0.0, 1.0) or {R=255, G=255, B=0, A=255}
        txt:SetText(CREDIT_TEXT)
        if slate then txt:SetColorAndOpacity(slate(yellow)) else txt:SetColorAndOpacity(yellow) end
        if txt.Font then local font = txt.Font; font.Size = 18; txt.Font = font end
        txt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local slot = parent:AddChildToCanvas(txt)
        if not slot then return end
        local vec = import("Vector2D")
        if vec then
            slot:SetAnchors(FAnchors(1.0, 1.0, 1.0, 1.0))
            slot:SetAlignment(vec(1.0, 1.0))
            slot:SetPosition(vec(-18.0, -14.0))
        end
        slot:SetAutoSize(true)
        slot:SetZOrder(9999)
        NewFreshCreditOverlay.Widget = txt
        NewFreshCreditOverlay.Slot = slot
    end)
end

local function NewFreshCleanup()
    pcall(function()
        if NewFreshCreditOverlay.Widget and slua.isValid(NewFreshCreditOverlay.Widget) then
            NewFreshCreditOverlay.Widget:RemoveFromParent()
            NewFreshCreditOverlay.Widget:ConditionalBeginDestroy()
        end
        NewFreshCreditOverlay.Widget = nil
        NewFreshCreditOverlay.Slot = nil
    end)
    pcall(function()
        if _G.StopV6Wallhack then _G.StopV6Wallhack() end
        if _G.PlayerMapMarker then _G.PlayerMapMarker.Stop() end
        if _G.RedBoxOverlay then _G.RedBoxOverlay.Stop() end
    end)
end

function _G.NewFreshRuntimeTick()
    if not _G.MOD_EXPIRED then NewFreshCredit() end
    if _G.PlayerMapMarker then
        _G.PlayerMapMarker.bUseSnapLines = (_G.AK_GetVal("ESP9_Line") == 1)
        _G.PlayerMapMarker.SnapLineThickness = math.max(1, math.min(10, _G.NewFreshLineThickness or 1))
        if _G.AK_GetVal("ESP_V2") == 1 or _G.AK_GetVal("ESP9_Line") == 1 or _G.AK_GetVal("ESP9_Count") == 1 then
            if not _G.PlayerMapMarker.bActive then pcall(_G.PlayerMapMarker.Start) end
        elseif _G.PlayerMapMarker.bActive then
            pcall(_G.PlayerMapMarker.Stop)
        end
    end
end
-- ========================================================================
-- BRPlayerCharacterBase CLASS - FIXED
-- ========================================================================
local BRPlayerCharacterBase = {
    ServerRPC = {},
    ClientRPC = {},
    MulticastRPC = {}
}

BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = { Reliable = true, Params = { UEnums.EPropertyClass.Object } }
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = { Reliable = true, Params = { UEnums.EPropertyClass.Bool } }
BRPlayerCharacterBase.ClientRPC.ClientRPC_TriggerHighlightMoment = { Reliable = true, Params = { UEnums.EPropertyClass.UInt32, UEnums.EPropertyClass.UInt32 } }

function BRPlayerCharacterBase:ctor()
    self.bHasShownDevNotice = false
    self.AK_NativeESP_Ready = false
    self._newWallhackStarted = false
end

function BRPlayerCharacterBase:_PostConstruct()
    BRPlayerCharacterBase.__super._PostConstruct(self)
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    self:StartAdvancedSystems()
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
    BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)

    if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
        local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
        if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
            Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
        end
    end

    if slua.isValid(self.STCharacterMovement) then
        self.STCharacterMovement.bPositiveBlowUp = true
    end

    if self.Role == ENetRole.ROLE_AutonomousProxy then
        self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
        self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
        self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", { AttrName = { "bCanSelfRescue" } }, self.CharacterAttrChangeEvent, self)
    end

    if Client then
        GameplayData.AddCharacter(self.Object)
    else
        self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, { [1] = "FinishedState" }, self.HandleFinishedState, self)
    end

    EventSystem:postEvent(EVENTTYPE_SINGLETRAINING, EVENTID_CHARACTER_BEGINPLAY, self.Object)
end

function BRPlayerCharacterBase:ReceiveEndPlay(endPlayReason)
    if _G.NewFreshCleanup then _G.NewFreshCleanup() end
    BRPlayerCharacterBase.__super.ReceiveEndPlay(self, endPlayReason)
    if Client and GameplayData.RemoveCharacter then GameplayData.RemoveCharacter(self.Object) end
end

-- ========================================================================
-- STARTADVANCEDSYSTEMS - FIXED (ALL LOGIC IN TIMER)
-- ========================================================================
function BRPlayerCharacterBase:StartAdvancedSystems()
    if not Client then return end

    -- Main timer
    self:AddGameTimer(0.4, true, function()
        if not slua.isValid(self.Object) then return end
    
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end

        if self.Object == localPlayer then
            -- ====== V6 WALLHACK CONTROL ======
            local wallhackEnabled = _G.AK_GetVal("WALLHACK") == 1
            if wallhackEnabled then
                if _G.StartV6Wallhack then _G.StartV6Wallhack() end
            else
                if _G.StopV6Wallhack then _G.StopV6Wallhack() end
            end

            -- ESP V2 and its independently controlled line/counter components
            if _G.AK_GetVal("ESP_V2") == 1 or _G.AK_GetVal("ESP9_Line") == 1 or _G.AK_GetVal("ESP9_Count") == 1 then
                if _G.PlayerMapMarker and not _G.PlayerMapMarker.bActive then
                    _G.PlayerMapMarker.Start()
                end
            else
                if _G.PlayerMapMarker and _G.PlayerMapMarker.bActive then
                    _G.PlayerMapMarker.Stop()
                end
            end

            -- Cleanup
            _G.AKModTickCount = (_G.AKModTickCount or 0) + 1

            -- Setup ESP config
            if not self.AK_NativeESP_Ready then
                pcall(function()
                    local gameplayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
                    local screenMarkConfig = gameplayTools.GetCurrentConfig("ScreenMarkConfig")
                    if screenMarkConfig then
                        if screenMarkConfig[1006] then
                            screenMarkConfig[1006].bBindBlocked = true
                            screenMarkConfig[1006].bBindOutScreen = true
                            screenMarkConfig[1006].MaxWidgetNum = 99
                            screenMarkConfig[1006].MaxShowDistance = 6000000
                        end
                    end
                end)
                self.AK_NativeESP_Ready = true
            end

            -- Process enemies
            local enemyCharacters = GameplayData.GetAllPlayerCharacters and GameplayData.GetAllPlayerCharacters() or {}
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()

            for _, enemy in pairs(enemyCharacters) do
                if slua.isValid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                    local isDead = false
                    pcall(function()
                        if type(enemy.IsDead)=="function" then isDead = enemy:IsDead()
                        elseif enemy.bIsDead then isDead = true end
                        if enemy.bHidden or (enemy.Mesh and enemy.Mesh.bHidden) then isDead = true end
                    end)

                    if isDead then goto skip_enemy end

                    -- ESP Box
                    if _G.AK_GetVal("ESP_BOX") == 1 then
                        pcall(function()
                            if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then
                                enemy:Replay_CreateEnemyFrameUI(true, true)
                            end
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                        end)
                    else
                        pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                        end)
                    end

                    ::skip_enemy::
                end
            end

            if not _G.MOD_EXPIRED then
                pcall(function() UpdateThrowableWarnings(localPlayer) end)
                pcall(_G.NewFreshRuntimeTick)
            end
        end
    end)
end
function _G.InitModMenuTab()
    if _G.ModMenuInitialized and _G._IsModMenuHooked then return true end
    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
    local function setFeature(id, value)
        for _, f in ipairs(_G.AK_Features) do if f.id == id then f.val = value and 1 or 0 end end
        if id == "THROWABLE_WARNING" then _G.LexusConfig.ThrowableWarning = value and true or false end
    end
    local function sw(key, text, id)
        return {Key=key, UI=AliasMap.Switcher, Text=text, GetFunc=function() return _G.AK_GetVal(id)==1 end, SetFunc=function(_,v) setFeature(id,v); return true end}
    end
    local featureStack = {
        sw("NF6_Line", "ESP LINE", "ESP_LINE"),
        {Key="NF6_LineThickness", UI=AliasMap.Slider, Text="ESP LINE THICKNESS", MinValue=1, MaxValue=10, min=1, max=10, GetFunc=function() return _G.NewFreshLineThickness or 1 end, SetFunc=function(_,v) _G.NewFreshLineThickness=math.max(1,math.min(10,tonumber(v) or 1)); return true end},
        sw("NF6_Box", "ESP BOX", "ESP_BOX"),
        sw("NF6_Name", "ESP NAME", "ESP_NAME"),
        sw("NF6_Health", "ESP HEALTH", "ESP_HEALTH"),
        sw("NF6_Counter", "ESP COUNTER", "ESP_COUNTER"),
        sw("NF6_Wallhack", "WALLHACK", "WALLHACK"),
        sw("NF6_Nade", "THROWABLE / GRENADE WARNING", "THROWABLE_WARNING"),
    }
    local page = SettingPageDefine.AlexaLordMenu
    if not page then page={Key="MOD Menu", Text=MENU_NAME, UIKey="Setting_Page_Privacy", Category={{Key="Cat_ALEXA_FEATURES", Text=FEATURE_CATEGORY_NAME, Stack=featureStack}}}; table.insert(SettingCatalog,1,page); SettingPageDefine.AlexaLordMenu=page end
    local UIManager = _G.UIManager
    if UIManager and UIManager.ShowUI and not UIManager._IsModMenuHooked then
        local old = UIManager.ShowUI
        UIManager.ShowUI=function(config,...)
            local args={...}; local n=select('#',...)
            if config and config.keyName and string.find(string.lower(tostring(config.keyName)),"setting_main") and not string.find(string.lower(tostring(config.keyName)),"custom") then
                local catalog=args[1]; if type(catalog)=="table" then local found=false; for _,v in ipairs(catalog) do if type(v)=="table" and v.Key=="MOD Menu" then found=true end end; if not found then table.insert(catalog,1,page) end end
            end
            return old(config, table.unpack(args,1,n))
        end
        UIManager._IsModMenuHooked=true; _G.ModMenuInitialized=true; return true
    end
    return false
end
local function TryInitNewFresh4()
    local ok, ready=pcall(_G.InitModMenuTab); if ok and ready then return end
    pcall(function() local ticker=require("common.time_ticker"); if ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(2.0,TryInitNewFresh4) elseif _G.Game then _G.Game:AddGameTimer(2.0,false,TryInitNewFresh4) end end)
end
pcall(function() local ticker=require("common.time_ticker"); if ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(2.0,TryInitNewFresh4) else TryInitNewFresh4() end end)
function _G.InitializeAllSystems()
    local gameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData")
    if gameplayData then pcall(function() local pc=gameplayData.GetPlayerCharacter and gameplayData.GetPlayerCharacter(); if slua.isValid(pc) then pc.StartAdvancedSystems=BRPlayerCharacterBase.StartAdvancedSystems end end) end
end
_G.InitializeAllSystems()
local class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local BRCharacterClass = class(CharacterBase, nil, BRPlayerCharacterBase)
return require("combine_class").DeclareFeature(BRCharacterClass, {})

]====]
  local compiler = loadstring or load
  if type(compiler) ~= "function" then
    stop("Lua chunk compiler unavailable")
  end
  local ok_compile, main_chunk, compile_error = pcall(function()
    if compiler == load then
      return compiler(MAIN_LUA_SOURCE, "<USER_MAIN_LUA>", "t", _ENV)
    end
    return compiler(MAIN_LUA_SOURCE, "<USER_MAIN_LUA>")
  end)
  if not ok_compile or type(main_chunk) ~= "function" then
    stop("Main Lua compilation failed: " .. tostring(compile_error or main_chunk))
  end
  local ok_run, module_result = pcall(main_chunk)
  if not ok_run then
    stop("Main Lua execution failed: " .. tostring(module_result))
  end
  -- This wrapper call is intentionally after the chunk returns, so it never
  -- appears after the user's top-level return inside the same Lua block.
  fetch_active_announcement(validated_key)
  return module_result or LICENSE_SESSION
end

-- The existing canonical validator reaches this dispatcher only after its
-- unchanged success path has passed response/status, key persistence,
-- Announcement, and Server Maintenance handling.
local function run_authorized_main(LICENSE_SESSION, validated_key, match_number)
  if UNIVERSAL_LIFECYCLE.authorization_active ~= true then
      UNIVERSAL_LIFECYCLE.authorization_active = true
      UNIVERSAL_LIFECYCLE.validation_successes = UNIVERSAL_LIFECYCLE.validation_successes + 1
      UNIVERSAL_LIFECYCLE.session = LICENSE_SESSION
      UNIVERSAL_LIFECYCLE.key = validated_key
      UNIVERSAL_LIFECYCLE.main_initialized = true
      return run_authorized_main_once(LICENSE_SESSION, validated_key)
  end

  match_number = tonumber(match_number)
  if not match_number or UNIVERSAL_LIFECYCLE.started_matches[match_number] then return true end
  cleanup_universal_match()
  UNIVERSAL_LIFECYCLE.started_matches[match_number] = true
  return run_authorized_main_once(UNIVERSAL_LIFECYCLE.session, UNIVERSAL_LIFECYCLE.key)
end

_G.PREMIUM_LUA_UNIVERSAL = _G.PREMIUM_LUA_UNIVERSAL or {}
_G.PREMIUM_LUA_UNIVERSAL.OnMatchStart = function(match_number)
  if UNIVERSAL_LIFECYCLE.authorization_active ~= true then return false end
  return run_authorized_main(UNIVERSAL_LIFECYCLE.session, UNIVERSAL_LIFECYCLE.key, match_number)
end
_G.PREMIUM_LUA_UNIVERSAL.OnMatchEnd = function(match_number)
  match_number = tonumber(match_number)
  if not match_number or UNIVERSAL_LIFECYCLE.ended_matches[match_number] then return true end
  UNIVERSAL_LIFECYCLE.ended_matches[match_number] = true
  cleanup_universal_match()
  return true
end
_G.PREMIUM_LUA_UNIVERSAL.IsAuthorized = function()
  return UNIVERSAL_LIFECYCLE.authorization_active == true
end
_G.PREMIUM_LUA_UNIVERSAL.ValidationSuccessCount = function()
  return UNIVERSAL_LIFECYCLE.validation_successes
end

-- Use the archive-authorized input widget. The host can drop optional manager
-- arguments at construction time, so the local handoff preserves the same
-- submitted raw key without changing the existing validator.
package.preload[KEY_ENTRY_MODULE] = function()
  local class = require("class")
  local base = require("client.slua_ui_framework.base")
  local Popup = { MAX_KEY_LENGTH = 64 }

  function Popup:ctor(initial_key, on_submit)
    self.initial_key = type(initial_key) == "string" and initial_key
      or (type(key_entry_handoff.initial_key) == "string" and key_entry_handoff.initial_key or "")
    self.on_submit = type(on_submit) == "function" and on_submit or key_entry_handoff.on_submit
    self.entered_key = ""
    self.submitted = false
  end

  function Popup:RegistEvents()
    Popup.__super.RegistEvents(self)
    self:AddOnClickedEventByControl(self.UIRoot.Button_OK, self.OnConfirm, self)
    self:AddOnClickedEventByControl(self.UIRoot.Button_Cancel, self.OnCancel, self)
  end

  function Popup:OnInitialize()
    Popup.__super.OnInitialize(self)
    self.Common_Popup = self:InitCommonPopup(self.UIRoot.Common_Popups_Small_UIBP)
    self.Common_Popup:SetData(self, "ENTER YOUR KEY")
    self:AddControlEventByControl(self.UIRoot.Text_Name, "OnTextChanged", self.OnKeyChanged, self)
    self:AddControlEventByControl(self.UIRoot.Text_Name, "OnTextCommitted", self.OnKeyChanged, self)
  end

  function Popup:OnShow()
    Popup.__super.OnShow(self)
    self.UIRoot.Text_Name:SetText(self.initial_key)
    self:OnKeyChanged(self.initial_key)
  end

  function Popup:NormalizeKeyEntry(value)
    local input = tostring(value or ""):gsub("[\r\n]", "")
    input = input:match("^%s*(.-)%s*$") or ""
    -- A saved key.json can be prefilled by the host as its JSON text rather
    -- than its decoded value. Convert only that established wrapper before
    -- applying the unchanged raw-key input rules.
    local wrapped_key = input:match('^%{%s*"key"%s*:%s*"([A-Za-z0-9%-]+)"%s*%}$')
    return wrapped_key or input
  end

  function Popup:OnKeyChanged(value, _)
    local key = self:NormalizeKeyEntry(value)
    self.entered_key = key
    if tostring(value or "") ~= key then self.UIRoot.Text_Name:SetText(key) end
    local valid = #key >= 8 and #key <= self.MAX_KEY_LENGTH and key:match("^[A-Za-z0-9%-]+$") ~= nil
    self.UIRoot.Button_OK:SetIsEnabled(valid)
    self.UIRoot.TextBlock_0:SetText(tostring(#key) .. "/" .. tostring(self.MAX_KEY_LENGTH))
  end

  function Popup:OnConfirm()
    if self.submitted then return end
    -- Some Android UI text controls can update their visible value before the
    -- OnTextChanged callback reaches Lua. Read the control once at confirmation
    -- so a newly entered key always takes precedence over the saved-key prefill.
    local submitted_key = self.entered_key
    local input_source = "event"
    if self.UIRoot and self.UIRoot.Text_Name and type(self.UIRoot.Text_Name.GetText) == "function" then
      local read_ok, live_value = pcall(self.UIRoot.Text_Name.GetText, self.UIRoot.Text_Name)
      if read_ok and live_value ~= nil then
        submitted_key = self:NormalizeKeyEntry(live_value)
        input_source = "live"
      end
    end
    self.entered_key = submitted_key
    local valid = #submitted_key >= 8 and #submitted_key <= self.MAX_KEY_LENGTH
      and submitted_key:match("^[A-Za-z0-9%-]+$") ~= nil
    if not valid or type(self.on_submit) ~= "function" then return end
    self.submitted = true
    self.on_submit(submitted_key, { source = input_source, length = #submitted_key })
    self:CloseSelf()
  end

  function Popup:OnCancel()
    -- Cancel deliberately performs no request and does not invoke main Lua.
    self:CloseSelf()
  end

  return class(base, nil, Popup)
end

local function open_key_entry()
  local manager = rawget(_G, "UIManager")
  if type(manager) ~= "table" or type(manager.ShowUIWithLuaAndBpPath) ~= "function" then
    stop("license key entry UI unavailable")
  end
  local json = get_json()
  local initial_key = read_saved_key_for_popup(json)
  local function submit_key(entered_raw_key, submission_trace)
    start_license_validation(run_authorized_main, entered_raw_key, submission_trace)
  end
  key_entry_handoff.initial_key = initial_key
  key_entry_handoff.on_submit = submit_key
  local ok, popup = pcall(function()
    return manager.ShowUIWithLuaAndBpPath(KEY_ENTRY_CONFIG, KEY_ENTRY_MODULE, KEY_ENTRY_BLUEPRINT,
      initial_key, submit_key)
  end)
  if not ok or not popup then
    stop("license key entry UI unavailable")
  end
end

-- The Dynamic Lua host can re-enter this top-level file during screen/UI
-- lifecycle transitions. Keep the approved key-entry popup to one launch for
-- the continuous host session, without changing any validation behavior.
local KEY_ENTRY_SESSION_GUARD = "__LuaLicenseKeyEntryProductionV1Opened"
if rawget(_G, KEY_ENTRY_SESSION_GUARD) ~= true then
  rawset(_G, KEY_ENTRY_SESSION_GUARD, true)
  open_key_entry()
end
return nil
