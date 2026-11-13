from pathlib import Path
src = Path('/home/ubuntu/lua-license-panel/BRPlayerCharacterBase-Merged.lua')
out = Path('/home/ubuntu/lua-license-panel/BRPlayerCharacterBase-Login-Validation-Only.lua')
s = src.read_text()

# Preserve all canonical validation/presentation code, but replace the embedded Main Lua body.
start = s.index('local function run_authorized_main(LICENSE_SESSION, validated_key)')
end = s.index('\n\n-- Use the archive-authorized input widget.', start)
s = s[:start] + '''local function run_authorized_main(LICENSE_SESSION, validated_key)
  -- Validation-only edition: no Main Lua is loaded, pasted, or executed.
  -- After maintenance clears, close the login popup and retain the normal
  -- announcement/Telegram presentation flow.
  pcall(write_status, "VALIDATION_ONLY_SUCCESS")
  local popup = key_entry_handoff.popup
  if popup then
    pcall(function()
      if type(popup.CloseSelf) == "function" then popup:CloseSelf() end
    end)
  end
  key_entry_handoff.popup = nil
  fetch_active_announcement(validated_key)
  return LICENSE_SESSION
end'''+s[end:]

# Failure should update the existing key popup and remain retryable.
old = '''local function fail_with_popup(popup_message, status_message, stop_message)
  -- Popup text is an approved generic result only. Never include the key,
  -- device identity, server body, token, or any other sensitive value.
  pcall(write_status, status_message)
  announce(popup_message, popup_message == "CONNECTION ERROR" and "CONNECTION ERROR" or "AUTHENTICATION FAILED")
  stop(stop_message)
end'''
new = '''local function fail_with_popup(popup_message, status_message, stop_message)
  -- Keep the key-entry popup open for every failed validation and allow retry.
  pcall(write_status, status_message)
  local popup = key_entry_handoff.popup
  if popup then
    pcall(function()
      if popup.Common_Popup and type(popup.Common_Popup.SetData) == "function" then
        popup.Common_Popup:SetData(popup, tostring(popup_message))
      end
      popup.submitted = false
    end)
  end
  announce(popup_message, popup_message == "CONNECTION ERROR" and "CONNECTION ERROR" or "AUTHENTICATION FAILED")
  return false
end'''
if old not in s: raise SystemExit('fail_with_popup block missing')
s=s.replace(old,new,1)

# The validation callback must return immediately after nonfatal failure.
repls = {
'''  local json = get_json()
  local key = read_key(json, submitted_key)''':'''  local json = get_json()
  if not json then return fail_with_popup("CONNECTION ERROR", "VALIDATION_JSON_UNAVAILABLE", "license JSON adapter unavailable") end
  local key = read_key(json, submitted_key)''',
}
# Exact replacements for all fail branches in the validator.
for old, new in [
('fail_with_popup("CONNECTION ERROR", "VALIDATION_REQUEST_INVALID", "could not encode license validation request")','return fail_with_popup("CONNECTION ERROR", "VALIDATION_REQUEST_INVALID", "could not encode license validation request")'),
('fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE host_missing", "license server unreachable")','return fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE host_missing", "license server unreachable")'),
('fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE wrapper_missing", "license server unreachable")','return fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE wrapper_missing", "license server unreachable")'),
('fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE wrapper_acquire_failed", "license server unreachable")','return fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE wrapper_acquire_failed", "license server unreachable")'),
('fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE request_missing", "license server unreachable")','return fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE request_missing", "license server unreachable")'),
('fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE response_event_missing", "license server unreachable")','return fail_with_popup("CONNECTION ERROR", "TRANSPORT_UNAVAILABLE response_event_missing", "license server unreachable")'),
('fail_with_popup("CONNECTION ERROR", "TRANSPORT_FAILED result=" .. tostring(result), "license server unreachable")','return fail_with_popup("CONNECTION ERROR", "TRANSPORT_FAILED result=" .. tostring(result), "license server unreachable")'),
('fail_with_popup("CONNECTION ERROR", "VALIDATION_HTTP_" .. tostring(result), "license server unreachable")','return fail_with_popup("CONNECTION ERROR", "VALIDATION_HTTP_" .. tostring(result), "license server unreachable")'),
('fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_MISSING", "license validation response was invalid")','return fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_MISSING", "license validation response was invalid")'),
('fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_INVALID", "license validation response was invalid")','return fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_INVALID", "license validation response was invalid")'),
('fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_EXPIRY_MISSING", "license validation response was invalid")','return fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_EXPIRY_MISSING", "license validation response was invalid")'),
('fail_with_popup(outcome.popup, "VALIDATION_FAILED " .. response.status .. " input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " validation_status=" .. response.status, outcome.stop_message)','return fail_with_popup(outcome.popup, "VALIDATION_FAILED " .. response.status .. " input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " validation_status=" .. response.status, outcome.stop_message)'),
('fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_REJECTED " .. tostring(response.status) .. " input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " validation_status=" .. tostring(response.status), "license validation response was rejected")','return fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_REJECTED " .. tostring(response.status) .. " input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " validation_status=" .. tostring(response.status), "license validation response was rejected")'),
('fail_with_popup("CONNECTION ERROR", "TRANSPORT_REQUEST_FAILED", "license server unreachable")','return fail_with_popup("CONNECTION ERROR", "TRANSPORT_REQUEST_FAILED", "license server unreachable")'),
]:
    s=s.replace(old,new)

# Maintenance-active must keep the key popup persistent and show the configured message.
old='''          pcall(write_status, "MAINTENANCE_ACTIVE")
          announce(message, title)
          return'''
new='''          pcall(write_status, "MAINTENANCE_ACTIVE")
          local login_popup = key_entry_handoff.popup
          if login_popup then
            pcall(function()
              if login_popup.Common_Popup and type(login_popup.Common_Popup.SetData) == "function" then
                login_popup.Common_Popup:SetData(login_popup, title .. "\\n\\n" .. message)
              end
              login_popup.submitted = false
            end)
          else
            announce(message, title)
          end
          -- Do not close the login popup or continue to Announcement/Telegram
          -- while server maintenance is active.
          return'''
if old not in s: raise SystemExit('maintenance active branch missing')
s=s.replace(old,new,1)

# Store the live popup and do not close it after submit/cancel.
s=s.replace('''local key_entry_handoff = { initial_key = "", on_submit = nil }''','''local key_entry_handoff = { initial_key = "", on_submit = nil, popup = nil }''',1)
s=s.replace('''    self.submitted = true
    self.on_submit(submitted_key, { source = input_source, length = #submitted_key })
    self:CloseSelf()
  end

  function Popup:OnCancel()
    -- Cancel deliberately performs no request and does not invoke main Lua.
    self:CloseSelf()
  end''','''    self.submitted = true
    key_entry_handoff.popup = self
    self.on_submit(submitted_key, { source = input_source, length = #submitted_key })
    -- Keep the same popup visible while validation is pending or failed.
  end

  function Popup:OnCancel()
    -- Do not permit cancellation before successful validation.
    self.submitted = false
    if self.Common_Popup and type(self.Common_Popup.SetData) == "function" then
      pcall(function() self.Common_Popup:SetData(self, "ENTER YOUR KEY TO CONTINUE") end)
    end
  end''',1)
s=s.replace('''  if not ok or not popup then
    stop("license key entry UI unavailable")
  end
end''','''  if not ok or not popup then
    stop("license key entry UI unavailable")
  end
  key_entry_handoff.popup = popup
end''',1)

s='-- Validation-only login copy; original BRPlayerCharacterBase-Merged.lua remains untouched.\\n'+s
out.write_text(s)
print(out)
