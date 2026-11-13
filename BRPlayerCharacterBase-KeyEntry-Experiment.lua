-- EXPERIMENT ONLY — DO NOT REPLACE THE VERIFIED PRODUCTION LOADER.
--
-- Purpose: test a pasted-key dialog separately. This file does not import,
-- edit, or execute BRPlayerCharacterBase-Reusable.lua or the merged loader.
-- It does not change the panel, API, HttpWrapper callback contract, device
-- binding logic, or manual key.json production flow.
--
-- Result: after a server-valid key is entered, only key.json is saved. Close
-- this experiment and run the existing verified production loader normally.

local API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"
local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local KEY_FILE = KEY_DIR .. "/key.json"
local DEVICE_FILE = KEY_DIR .. "/.device_id"

-- Existing authorized widget and manager contract used only in this experiment.
local INPUT_BLUEPRINT = "/Game/UMG/UI_BP/Home/Common/Popup/Small/Home_Input_Popups_UIBP.Home_Input_Popups_UIBP"
local INPUT_MODULE = "lua_license.experimental_key_entry_popup_v1"
local INPUT_CONFIG = {
  keyName = "LuaLicenseKeyEntryExperimentV1",
  moduleName = INPUT_MODULE,
  path = INPUT_BLUEPRINT,
}

-- The target runtime displays the popup but does not deliver the extra
-- ShowUIWithLuaAndBpPath arguments to Popup:ctor. Keep this experiment-only
-- handoff alongside the documented arguments so the existing validator is
-- still received as a callable function without changing it.
local popup_handoff = {
  initial_key = "",
  on_submit = nil,
  on_cancel = nil,
}

local function show_notice(message, title)
  pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"]
      or require("client.slua.logic.common.logic_common_msg_box")
    if Msg and type(Msg.Show) == "function" then
      Msg.Show(4, tostring(title or "LICENSE KEY"), tostring(message), function() end)
      return
    end
    print("[LICENSE KEY] " .. tostring(message))
  end)
end

-- TEMPORARY EXPERIMENT TRACE: markers contain only a safe stage name/outcome.
-- They never include a key, device identity, request body, or server response body.
local function show_diagnostic(step, state, reason)
  local message = "DIAGNOSTIC\n" .. tostring(step) .. "\n" .. tostring(state)
  if type(reason) == "string" and reason ~= "" then
    message = message .. "\n" .. reason
  end
  pcall(function()
    print("[KEY ENTRY TRACE] " .. tostring(step) .. " | " .. tostring(state)
      .. (type(reason) == "string" and reason ~= "" and (" | " .. reason) or ""))
  end)
  show_notice(message, "KEY ENTRY TRACE")
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

local function get_json()
  local decoder = rawget(_G, "json") or rawget(_G, "cjson")
  if decoder and decoder.decode and decoder.encode then return decoder end
  local ok, module = pcall(require, "cjson.safe")
  if ok and module then return module end
  ok, module = pcall(require, "cjson")
  if ok and module then return module end
  return nil
end

local function read_saved_key()
  -- This helper reads only the established key.json file. A missing or malformed
  -- file simply opens an empty entry box; it is never overwritten until a newly
  -- submitted key receives a valid server response.
  local raw = read_file(KEY_FILE)
  if type(raw) ~= "string" then return "" end
  raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
  if raw == "" then return "" end

  local json = get_json()
  if json and raw:sub(1, 1) == "{" then
    local decoded_ok, parsed = pcall(json.decode, raw)
    if decoded_ok and type(parsed) == "table" and type(parsed.key) == "string" then
      return parsed.key
    end
  end
  return raw
end

local function get_device_id()
  local provider = rawget(_G, "getPersistentDeviceId") or rawget(_G, "getDeviceId")
  if type(provider) == "function" then
    local ok, value = pcall(provider)
    if ok and type(value) == "string" and #value > 0 then return value, nil, "PROVIDER" end
  end

  local existing = read_file(DEVICE_FILE)
  if existing and #existing > 0 then return existing:gsub("%s+$", ""), nil, "EXISTING" end

  math.randomseed(os.time() + math.floor(os.clock() * 100000))
  local alphabet = "0123456789abcdef"
  local chars = {}
  for i = 1, 32 do
    local n = math.random(#alphabet)
    chars[i] = alphabet:sub(n, n)
  end
  local generated = table.concat(chars)
  local ok, err = write_file(DEVICE_FILE, generated)
  if not ok then return nil, "cannot save device identity: " .. tostring(err) end
  return generated, nil, "GENERATED"
end

local function save_key_after_authorization(json, key)
  -- Save only after the existing server says valid. The folder must already
  -- exist because no documented directory-creation helper was found.
  local encoded = json.encode({key = key})
  if type(encoded) ~= "string" then return false, "could not encode key file" end
  return write_file(KEY_FILE, encoded)
end

local function validate_key(key)
  show_diagnostic("03 VALIDATE_KEY", "ENTERED")
  local json = get_json()
  if not json then
    show_diagnostic("04 JSON ADAPTER", "FAILED", "UNAVAILABLE")
    show_notice("CONNECTION ERROR\nJSON ADAPTER UNAVAILABLE", "AUTHENTICATION FAILED")
    return
  end
  show_diagnostic("04 JSON ADAPTER", "READY")

  local device_id, device_error, device_source = get_device_id()
  if not device_id then
    show_diagnostic("05 DEVICE ID", "FAILED", "UNAVAILABLE")
    show_notice("KEY FOLDER UNAVAILABLE\n" .. tostring(device_error), "KEY ENTRY")
    return
  end
  show_diagnostic("05 DEVICE ID", "READY", device_source or "AVAILABLE")

  local payload = json.encode({key = key, device_id = device_id})
  if type(payload) ~= "string" then
    show_diagnostic("06 JSON PAYLOAD", "FAILED", "ENCODE FAILED")
    show_notice("CONNECTION ERROR\nREQUEST ENCODE FAILED", "AUTHENTICATION FAILED")
    return
  end
  show_diagnostic("06 JSON PAYLOAD", "CREATED")

  local hud = rawget(_G, "slua_GameFrontendHUD")
  if (type(hud) ~= "table" and type(hud) ~= "userdata") or type(hud.GetHttpWrapper) ~= "function" then
    show_diagnostic("07 HUD", "FAILED", "NOT AVAILABLE")
    show_notice("CONNECTION ERROR", "AUTHENTICATION FAILED")
    return
  end
  show_diagnostic("07 HUD", "FOUND")

  local wrapper_ok, http_wrapper = pcall(hud.GetHttpWrapper, hud)
  if not wrapper_ok or not http_wrapper or type(http_wrapper.RequestForLua) ~= "function" then
    show_diagnostic("08 HTTPWRAPPER", "FAILED", "NOT AVAILABLE")
    show_notice("CONNECTION ERROR", "AUTHENTICATION FAILED")
    return
  end
  show_diagnostic("08 HTTPWRAPPER", "FOUND")

  local response_event = http_wrapper.OnResponseEvent
  if (type(response_event) ~= "table" and type(response_event) ~= "userdata") or type(response_event.Add) ~= "function" then
    show_diagnostic("09 ONRESPONSEEVENT", "FAILED", "NOT AVAILABLE")
    show_notice("CONNECTION ERROR", "AUTHENTICATION FAILED")
    return
  end
  show_diagnostic("09 ONRESPONSEEVENT", "AVAILABLE")

  local request_index
  local callback_ok = pcall(function()
    response_event:Add(function(req_index, _, data, _, success, result)
      if request_index == nil or req_index ~= request_index then return end
      show_diagnostic("13 RESPONSE CALLBACK", "RECEIVED")

      if success ~= true or tonumber(result) ~= 200 or type(data) ~= "string" or #data == 0 then
        show_notice("CONNECTION ERROR", "AUTHENTICATION FAILED")
        return
      end

      local decoded_ok, response = pcall(json.decode, data)
      if not decoded_ok or type(response) ~= "table" or type(response.status) ~= "string" then
        show_notice("CONNECTION ERROR", "AUTHENTICATION FAILED")
        return
      end

      if response.success == true and response.status == "valid"
        and type(response.expiresAt) == "string" and #response.expiresAt > 0 then
        local saved, save_error = save_key_after_authorization(json, key)
        if not saved then
          show_notice("KEY VALID\nBUT KEY COULD NOT BE SAVED\n" .. tostring(save_error), "KEY ENTRY")
          return
        end
        show_notice("KEY VALID\nKEY SAVED\nNOW RUN THE VERIFIED LOADER", "AUTHENTICATION SUCCESS")
        return
      end

      local messages = {
        expired = "KEY EXPIRED",
        not_registered = "INVALID KEY",
        invalid = "KEY REVOKED",
        device_mismatch = "INVALID KEY",
        device_max_reached = "DEVICE LIMIT REACHED",
      }
      show_notice(messages[response.status] or "CONNECTION ERROR", "AUTHENTICATION FAILED")
    end)
  end)
  if not callback_ok then
    show_diagnostic("10 RESPONSE CALLBACK", "FAILED", "REGISTRATION FAILED")
    show_notice("CONNECTION ERROR", "AUTHENTICATION FAILED")
    return
  end
  show_diagnostic("10 RESPONSE CALLBACK", "REGISTERED")

  local request_ok, returned_index = pcall(function()
    return http_wrapper:RequestForLua(API_URL, "POST", {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#payload),
      ["Accept"] = "application/json",
      ["Accept-Encoding"] = "identity",
    }, payload, 0, 0)
  end)
  if not request_ok then
    show_diagnostic("11 REQUESTFORLUA", "FAILED", "DISPATCH ERROR")
    show_notice("CONNECTION ERROR", "AUTHENTICATION FAILED")
    return
  end
  show_diagnostic("11 REQUESTFORLUA", "DISPATCHED")
  if returned_index == nil or returned_index == 0 then
    show_diagnostic("12 REQUEST INDEX", "FAILED", "MISSING OR INVALID")
    show_notice("CONNECTION ERROR", "AUTHENTICATION FAILED")
    return
  end
  request_index = returned_index
  show_diagnostic("12 REQUEST INDEX", "RECEIVED")
end

-- Reuse the archive's documented UIManager.ShowUIWithLuaAndBpPath path with a
-- unique preloaded module. This avoids changing any registered game UI class.
package.preload[INPUT_MODULE] = function()
  local class = require("class")
  local base = require("client.slua_ui_framework.base")
  local Popup = {MAX_KEY_LENGTH = 64}

  function Popup:ctor(initial_key, on_submit, on_cancel)
    self.initial_key = type(initial_key) == "string" and initial_key
      or (type(popup_handoff.initial_key) == "string" and popup_handoff.initial_key or "")
    self.on_submit = type(on_submit) == "function" and on_submit or popup_handoff.on_submit
    self.on_cancel = type(on_cancel) == "function" and on_cancel or popup_handoff.on_cancel
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

    -- The popup accepts the raw license key. For convenience it also accepts a
    -- complete key.json value pasted by mistake, then displays only its key.
    local json_key = input:match('^%{%s*"key"%s*:%s*"([A-Za-z0-9%-]+)"%s*%}$')
    return json_key or input
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
    show_diagnostic("01 ONCONFIRM", "ENTERED")
    if self.submitted then
      show_diagnostic("01 ONCONFIRM", "FAILED", "ALREADY SUBMITTED")
      return
    end
    local valid = #self.entered_key >= 8 and #self.entered_key <= self.MAX_KEY_LENGTH
      and self.entered_key:match("^[A-Za-z0-9%-]+$") ~= nil
    if not valid then
      show_diagnostic("01 ONCONFIRM", "FAILED", "INPUT FORMAT INVALID")
      return
    end
    self.submitted = true
    if type(self.on_submit) ~= "function" then
      show_diagnostic("02 ON_SUBMIT", "FAILED", "NOT CALLABLE")
      self:CloseSelf()
      return
    end
    show_diagnostic("02 ON_SUBMIT", "CALLABLE")
    local submit_ok = pcall(self.on_submit, self.entered_key)
    if not submit_ok then
      show_diagnostic("02 ON_SUBMIT", "FAILED", "CALL ERROR")
      self:CloseSelf()
      return
    end
    self:CloseSelf()
  end

  function Popup:OnCancel()
    if type(self.on_cancel) == "function" then self.on_cancel() end
    self:CloseSelf()
  end

  return class(base, nil, Popup)
end

local function open_key_entry()
  local manager = rawget(_G, "UIManager")
  if type(manager) ~= "table" or type(manager.ShowUIWithLuaAndBpPath) ~= "function" then
    show_notice("KEY ENTRY UI UNAVAILABLE\nPRODUCTION LOADER WAS NOT CHANGED", "KEY ENTRY EXPERIMENT")
    return
  end
  local initial_key = read_saved_key()
  local function cancel_key_entry()
    show_notice("KEY ENTRY CANCELLED\nPRODUCTION LOADER WAS NOT CHANGED", "KEY ENTRY EXPERIMENT")
  end
  popup_handoff.initial_key = initial_key
  popup_handoff.on_submit = validate_key
  popup_handoff.on_cancel = cancel_key_entry
  local ok, popup = pcall(function()
    return manager.ShowUIWithLuaAndBpPath(INPUT_CONFIG, INPUT_MODULE, INPUT_BLUEPRINT,
      initial_key, validate_key, cancel_key_entry)
  end)
  if not ok or not popup then
    show_notice("KEY ENTRY UI UNAVAILABLE\nPRODUCTION LOADER WAS NOT CHANGED", "KEY ENTRY EXPERIMENT")
  end
end

open_key_entry()
return nil
