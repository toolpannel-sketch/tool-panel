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
  -- ================================================================
  -- PASTE YOUR CHANGING MAIN LUA CODE BELOW THIS LINE.
  -- Do not add another loadfile() call for main_features.lua.
  -- ================================================================

  -- ================================================================
  -- ============ MAIN LUA — PASTE FULL CODE HERE ===================
  -- ================================================================
  -- Paste the complete Main Lua exactly once between the two markers:
  -- BEGIN MAIN LUA
  -- [PASTE YOUR COMPLETE MAIN LUA HERE]
  -- END MAIN LUA
  --
  -- Do not split the Main Lua into another section, file, callback, or
  -- module. This whole block runs only after canonical validation succeeds.
  -- ================================================================


  return LICENSE_SESSION
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
