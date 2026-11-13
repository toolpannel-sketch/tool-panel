import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";

const projectRoot = path.resolve(import.meta.dirname, "..");
const reusableWrapper = readFileSync(path.join(projectRoot, "BRPlayerCharacterBase-Reusable.lua"), "utf8");
const mergedWrapper = readFileSync(path.join(projectRoot, "BRPlayerCharacterBase-Merged.lua"), "utf8");
const routeSource = readFileSync(path.join(projectRoot, "server", "licenseRoutes.ts"), "utf8");
const httpManagerProbe = readFileSync(path.join(projectRoot, "BRPlayerCharacterBase-HttpManagerProbe.lua"), "utf8");
const httpManagerLongProbe = readFileSync(path.join(projectRoot, "BRPlayerCharacterBase-HttpManagerLongTimeoutProbe.lua"), "utf8");
const httpWrapperDirectPostProbe = readFileSync(path.join(projectRoot, "BRPlayerCharacterBase-HttpWrapperDirectPostPingProbe.lua"), "utf8");

describe("Lua online validation adapter contract", () => {
  it("uses only the verified documented direct HttpWrapper contract in the production loader", () => {
    expect(reusableWrapper).toContain('API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"');
    expect(reusableWrapper).toContain('rawget(_G, "slua_GameFrontendHUD")');
    expect(reusableWrapper).toContain("hud.GetHttpWrapper");
    expect(reusableWrapper).toContain("response_event:Add(function(reqIndex, elapsedTime, data, content, success, result)");
    expect(reusableWrapper).toContain('http_wrapper:RequestForLua(API_URL, "POST", headers, payload, 0, 0)');
    expect(reusableWrapper).not.toContain('pcall(require, "ssl.https")');
    expect(reusableWrapper).not.toContain("HTTP_POST(url, body)");
    expect(routeSource).toContain('app.post("/api/license/validate"');
  });

  it("keeps the asynchronous event path fail-closed until an authoritative valid response", () => {
    expect(reusableWrapper).toContain("if success ~= true then");
    expect(reusableWrapper).toContain('stop("license server unreachable")');
    expect(reusableWrapper).toContain("if tonumber(result) ~= 200 then");
    expect(reusableWrapper).toContain('if response.status == "valid" and response.success == true then');
    expect(reusableWrapper).toContain("gate_server_maintenance(json, response, key, on_authorized)");
    expect(reusableWrapper).toContain("start_license_validation(run_authorized_main, entered_raw_key)");
    expect(reusableWrapper).not.toContain("local LICENSE_SESSION = validate_license()");
  });

  it("declares the key reader in the enclosing scope and records a non-secret earliest startup marker", () => {
    const keyReaderDeclaration = reusableWrapper.indexOf("local read_key");
    const validationDispatcher = reusableWrapper.indexOf("local function start_license_validation(on_authorized, submitted_key)");
    const keyReaderAssignment = reusableWrapper.indexOf("read_key = function(json, submitted_key)");
    const validationInvocation = reusableWrapper.lastIndexOf("start_license_validation(run_authorized_main, entered_raw_key)");

    expect(keyReaderDeclaration).toBeGreaterThan(-1);
    expect(keyReaderDeclaration).toBeLessThan(validationDispatcher);
    expect(keyReaderAssignment).toBeGreaterThan(validationDispatcher);
    expect(keyReaderAssignment).toBeLessThan(validationInvocation);
    expect(reusableWrapper).toContain('pcall(write_status, "LOADER_STARTED")');
    expect(reusableWrapper).toContain("It never contains a license key or device identity.");
  });

  it("maps canonical validation statuses to distinct popup and fail-closed stop messages", () => {
    expect(reusableWrapper).toContain('expired = { popup = "KEY EXPIRED", stop_message = "key has expired" }');
    expect(reusableWrapper).toContain('not_registered = { popup = "INVALID KEY", stop_message = "key is not registered" }');
    expect(reusableWrapper).toContain('invalid = { popup = "KEY REVOKED", stop_message = "key has been revoked or banned" }');
    expect(reusableWrapper).toContain('device_mismatch = { popup = "INVALID KEY", stop_message = "key is bound to a different device" }');
    expect(reusableWrapper).toContain('device_max_reached = { popup = "DEVICE LIMIT REACHED", stop_message = "device limit reached for this key" }');
  });

  it("shows only non-sensitive, server-result-driven validation popups before the valid-only gate", () => {
    expect(reusableWrapper).toContain('Msg.Show(4, tostring(title or "LICENSE VALIDATION"), tostring(message), function() end)');
    expect(reusableWrapper).toContain("local function format_expiry_for_popup(iso_value)");
    expect(reusableWrapper).toContain('announce("KEY VALID\\nACCESS GRANTED\\nExpires: " .. format_expiry_for_popup(response.expiresAt), "AUTHENTICATION SUCCESS")');
    expect(reusableWrapper).toContain('return formatted .. " (local time)"');
    expect(reusableWrapper).toContain('type(response.expiresAt) ~= "string" or #response.expiresAt == 0');
    expect(reusableWrapper).toContain('expired = { popup = "KEY EXPIRED"');
    expect(reusableWrapper).toContain('not_registered = { popup = "INVALID KEY"');
    expect(reusableWrapper).toContain('invalid = { popup = "KEY REVOKED"');
    expect(reusableWrapper).toContain('device_max_reached = { popup = "DEVICE LIMIT REACHED"');
    expect(reusableWrapper).toContain('fail_with_popup("CONNECTION ERROR"');
    expect(reusableWrapper).toContain("Never include the key,");
    const successPopup = reusableWrapper.indexOf('announce("KEY VALID\\nACCESS GRANTED\\nExpires: " .. format_expiry_for_popup(response.expiresAt), "AUTHENTICATION SUCCESS")');
    const authorization = reusableWrapper.indexOf("gate_server_maintenance(json, response, key, on_authorized)");
    expect(successPopup).toBeGreaterThan(-1);
    expect(successPopup).toBeLessThan(authorization);
  });

  it("uses only the user-supplied widget APIs for a visible popup, before fallback notifiers and authorization", () => {
    expect(reusableWrapper).toContain('local LICENSE_POPUP_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"');
    expect(reusableWrapper).toContain("local function show_license_popup_widget(message, title)");
    expect(reusableWrapper).toContain("local popup = slua.loadUI(LICENSE_POPUP_BP)");
    expect(reusableWrapper).toContain('require("game_frontend_hud")');
    expect(reusableWrapper).toContain("frontend_hud.AddToContainer(UIContainers.Top, popup, 11000)");
    expect(reusableWrapper).toContain("player_controller:AddGameTimer(LICENSE_POPUP_DURATION_SECONDS, false");
    expect(reusableWrapper).toContain("if slua.isValid(popup) then popup:RemoveFromParent() end");
    const widgetAnnouncement = reusableWrapper.indexOf("show_license_popup_widget(message, title)");
    const fallbackNotifier = reusableWrapper.indexOf('rawget(_G, "TOAST")', widgetAnnouncement);
    const authorization = reusableWrapper.indexOf("gate_server_maintenance(json, response, key, on_authorized)");
    expect(widgetAnnouncement).toBeGreaterThan(-1);
    expect(widgetAnnouncement).toBeLessThan(fallbackNotifier);
    expect(widgetAnnouncement).toBeLessThan(authorization);
  });

  it("keeps the supplied main Lua inside the valid-only authorized callback in the merged artifact", () => {
    const authorizationGate = mergedWrapper.indexOf('if response.status == "valid" and response.success == true then');
    const maintenanceGate = mergedWrapper.indexOf("gate_server_maintenance(json, response, key, on_authorized)");
    const mainCallback = mergedWrapper.indexOf("local function run_authorized_main(LICENSE_SESSION, validated_key)");
    const userMainStart = mergedWrapper.indexOf("-- BEGIN USER-SUPPLIED MAIN LUA");
    const mainStart = mergedWrapper.indexOf("StartEnemyCounter()", userMainStart);
    const announcement = mergedWrapper.indexOf("fetch_active_announcement(validated_key)", userMainStart);
    const dispatch = mergedWrapper.lastIndexOf("start_license_validation(run_authorized_main, entered_raw_key, submission_trace)");

    expect(authorizationGate).toBeGreaterThan(-1);
    expect(maintenanceGate).toBeGreaterThan(authorizationGate);
    expect(mainCallback).toBeGreaterThan(maintenanceGate);
    expect(userMainStart).toBeGreaterThan(mainCallback);
    expect(mainStart).toBeGreaterThan(userMainStart);
    expect(announcement).toBeGreaterThan(mainStart);
    expect(dispatch).toBeGreaterThan(mainStart);
    expect(mergedWrapper).toContain("local function format_expiry_for_popup(iso_value)");
    expect(mergedWrapper).toContain('announce("KEY VALID\\nACCESS GRANTED\\nExpires: " .. format_expiry_for_popup(response.expiresAt), "AUTHENTICATION SUCCESS")');
    expect(mergedWrapper).toContain('http_wrapper:RequestForLua(API_URL, "POST", headers, payload, 0, 0)');
    expect(mergedWrapper).toContain('local MAINTENANCE_URL = "https://luapanel-8355ybgt.manus.space/api/maintenance/active"');
    expect(mergedWrapper).toContain('local ANNOUNCEMENT_URL = "https://luapanel-8355ybgt.manus.space/api/announcement/active"');
    expect(mergedWrapper).toContain('local function gate_server_maintenance(json, validated_response, validated_key, on_authorized)');
    expect(mergedWrapper).toContain('local function fetch_active_announcement(validated_key)');
    expect(mergedWrapper).toContain('local function request_telegram_ticket(key, device_id, on_ticket)');
    expect(mergedWrapper).toContain('local function redeem_telegram_ticket(ticket, device_id)');
    expect(mergedWrapper).toContain('local TELEGRAM_DIAGNOSTIC_FILE = KEY_DIR .. "/.telegram_redirect_diagnostic"');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("OK_CALLBACK")');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("TICKET_PRESENT")');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("TICKET_CREATOR_CHANNEL_MISSING")');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("TICKET_CREATOR_CHANNEL_DISABLED")');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("TICKET_MISSING")');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("REDEEM_CHANNEL_PRESENT")');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("REDEEM_CHANNEL_MISSING")');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("OPEN_URL_AVAILABLE")');
    expect(mergedWrapper).toContain('write_telegram_diagnostic("OPEN_URL_MISSING")');
  });

  it("keeps the compile-ready Merged artifact as the source of the approved key-entry bridge and valid-only key-save alignment", () => {
    const validResponse = mergedWrapper.indexOf('if response.status == "valid" and response.success == true then');
    const saveKey = mergedWrapper.indexOf("local saved, save_error = save_validated_key(json, key)");
    const successPopup = mergedWrapper.indexOf('announce("KEY VALID\\nACCESS GRANTED\\nExpires: " .. format_expiry_for_popup(response.expiresAt), "AUTHENTICATION SUCCESS")');
    const mainGate = mergedWrapper.indexOf("gate_server_maintenance(json, response, key, on_authorized)");
    const popupOpen = mergedWrapper.lastIndexOf("local function open_key_entry()");
    const validatedDispatch = mergedWrapper.lastIndexOf("start_license_validation(run_authorized_main, entered_raw_key, submission_trace)");

    expect(mergedWrapper).toContain('local KEY_ENTRY_MODULE = "lua_license.production_key_entry_popup_v1"');
    expect(mergedWrapper).toContain("local function read_saved_key_for_popup(json)");
    expect(mergedWrapper).toContain("local function save_validated_key(json, key)");
    expect(mergedWrapper).toContain("local wrapped_key = input:match('^%{%s*\"key\"%s*:%s*\"([A-Za-z0-9%-]+)\"%s*%}$')");
    expect(mergedWrapper).toContain("return wrapped_key or input");
    expect(mergedWrapper).toContain("key_entry_handoff.on_submit = submit_key");
    expect(mergedWrapper).toContain("return manager.ShowUIWithLuaAndBpPath(KEY_ENTRY_CONFIG, KEY_ENTRY_MODULE, KEY_ENTRY_BLUEPRINT,");
    expect(mergedWrapper).toContain('local KEY_ENTRY_SESSION_GUARD = "__LuaLicenseKeyEntryProductionV1Opened"');
    expect(mergedWrapper).toContain("if rawget(_G, KEY_ENTRY_SESSION_GUARD) ~= true then");
    expect(mergedWrapper).toContain("rawset(_G, KEY_ENTRY_SESSION_GUARD, true)");
    expect(mergedWrapper).toContain("  open_key_entry()\nend\nreturn nil");
    expect(validResponse).toBeGreaterThan(-1);
    expect(saveKey).toBeGreaterThan(validResponse);
    expect(saveKey).toBeLessThan(successPopup);
    expect(successPopup).toBeLessThan(mainGate);
    expect(popupOpen).toBeGreaterThan(mainGate);
    expect(validatedDispatch).toBeGreaterThan(popupOpen);
    expect(mergedWrapper).toContain("local function start_license_validation(on_authorized, submitted_key, submission_trace)");
    expect(mergedWrapper).toContain('local SAVED_KEY_DIAGNOSTIC_FILE = KEY_DIR .. "/.saved_key_diagnostic"');
    expect(mergedWrapper).toContain("local function write_saved_key_diagnostic(source, length, status)");
    expect(mergedWrapper).toContain("write_saved_key_diagnostic(trace_source, trace_length, response.status)");
    expect(mergedWrapper).toContain('"input_source=" .. safe_source');
    expect(mergedWrapper).toContain('input_length=" .. tostring(safe_length)');
    expect(mergedWrapper).toContain('validation_status=" .. safe_status');
    expect(mergedWrapper).not.toContain('TELEGRAM_DIAGNOSTIC_FILE, channel_url');
    expect(mergedWrapper).not.toContain('SAVED_KEY_DIAGNOSTIC_FILE, key');
    expect(reusableWrapper).toContain("lua_license.production_key_entry_popup_v1");
    expect(reusableWrapper).toContain("start_license_validation(run_authorized_main, entered_raw_key)");
  });

  it("does not add hidden discovery or automatic runtime inventory to production wrappers", () => {
    expect(reusableWrapper).toContain("local ENABLE_DOWNLOADER_PROBE = false");
    expect(reusableWrapper).not.toContain("pcall(run_downloader_probe)");
    expect(reusableWrapper).toContain("The callback is asynchronous, so this function only dispatches the request.");
    expect(reusableWrapper).not.toContain("loadstring");
  });

  it("uses only the documented user-authorized http_manager module contract in its separate probe", () => {
    expect(httpManagerProbe).toContain('module_manager.GetModule, common_config.http_manager');
    expect(httpManagerProbe).toContain('http_manager:Post(API_URL, headers, probe_body');
    expect(httpManagerProbe).toContain("function(success, data, content, result)");
    expect(httpManagerProbe).toContain("HTTP_MANAGER_CALLBACK");
    expect(httpManagerProbe).not.toContain("loadstring");
    expect(httpManagerProbe).not.toContain("debug.getinfo");
  });

  it("uses a bounded longer timeout only as a key-free http_manager follow-up", () => {
    expect(httpManagerLongProbe).toContain("local TIMEOUT_SECONDS = 45");
    expect(httpManagerLongProbe).toContain('http_manager:Post(API_URL, headers, probe_body');
    expect(httpManagerLongProbe).toContain("HTTP_MANAGER_LONG_TIMEOUT");
    expect(httpManagerLongProbe).toContain("HTTP_MANAGER_LONG_CALLBACK");
    expect(httpManagerLongProbe).toContain("HTTP_MANAGER_LONG_TRANSPORT_PROBE");
    expect(httpManagerLongProbe).not.toContain("loadstring");
  });

  it("uses only the documented direct HttpWrapper event and RequestForLua POST contract", () => {
    expect(httpWrapperDirectPostProbe).toContain('rawget(_G, "slua_GameFrontendHUD")');
    expect(httpWrapperDirectPostProbe).toContain("hud.GetHttpWrapper");
    expect(httpWrapperDirectPostProbe).toContain("response_event:Add(function(reqIndex, elapsedTime, data, content, success, result)");
    expect(httpWrapperDirectPostProbe).toContain('http_wrapper:RequestForLua(API_URL, "POST", headers, REQUEST_BODY, PRIORITY, QUEUE_TYPE)');
    expect(httpWrapperDirectPostProbe).toContain('local REQUEST_BODY = \'{"test":"ping"}\'');
    expect(httpWrapperDirectPostProbe).toContain("HTTP_WRAPPER_DIRECT_POST_PING_CALLBACK");
    expect(httpWrapperDirectPostProbe).not.toContain("loadstring");
    expect(httpWrapperDirectPostProbe).not.toContain("device_id");
    expect(httpWrapperDirectPostProbe).not.toContain("/api/license/validate");
  });
});
