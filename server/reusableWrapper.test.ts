import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

type CandidateResult = { kind: "key"; value: string } | { kind: "error"; message: string };

type ProbeDeps = {
  importer?: (name: string) => { DownloadFile?: (url: string, path: string) => void };
  readProbeFile: () => string | undefined;
  callDownloader?: (url: string, path: string) => void;
};

function simulateDownloaderProbe(deps: ProbeDeps): string {
  const writeStatus = (message: string) => message;
  if (!deps.importer) return writeStatus("DOWNLOADER_PROBE_UNAVAILABLE import_missing");

  let downloader: { DownloadFile?: (url: string, path: string) => void };
  try {
    downloader = deps.importer("Downloader");
  } catch {
    return writeStatus("DOWNLOADER_PROBE_UNAVAILABLE import_failed");
  }
  if (typeof downloader?.DownloadFile !== "function") {
    return writeStatus("DOWNLOADER_PROBE_UNAVAILABLE DownloadFile_missing");
  }

  try {
    (deps.callDownloader ?? downloader.DownloadFile)("https://example.invalid/downloader-probe.txt", "/tmp/.downloader_probe");
  } catch {
    return writeStatus("DOWNLOADER_PROBE_CALL_FAILED");
  }

  const body = deps.readProbeFile();
  return body?.includes("LUA_DOWNLOADER_PROBE_V1")
    ? writeStatus("DOWNLOADER_PROBE_SUCCESS GET_FILE_WRITE")
    : writeStatus("DOWNLOADER_PROBE_NO_VERIFIED_FILE");
}

function resolveKeyLikeWrapper(files: Record<string, string | undefined>): CandidateResult {
  const candidates = ["key.json", "key.txt", "key.in", "key.ini"];
  let selected: string | undefined;
  let raw: string | undefined;

  for (const candidate of candidates) {
    if (files[candidate] !== undefined) {
      selected = candidate;
      raw = files[candidate];
      break;
    }
  }

  if (raw === undefined || selected === undefined) {
    return { kind: "error", message: "key file not found" };
  }

  const trimmed = raw.trim();
  if (!trimmed) return { kind: "error", message: `key file is empty: ${selected}` };

  if (trimmed.startsWith("{")) {
    try {
      const parsed = JSON.parse(trimmed) as { key?: unknown };
      if (typeof parsed.key === "string" && parsed.key.length > 0) {
        return { kind: "key", value: parsed.key };
      }
    } catch {
      // The Lua wrapper stops on malformed JSON; this test models that fail-closed branch.
    }
    return { kind: "error", message: `${selected} must contain a string field named key` };
  }

  return { kind: "key", value: trimmed };
}

describe("reusable wrapper key-file contract", () => {
  const source = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-Reusable.lua"), "utf8");
  const probeSource = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-DownloaderProbe-Test.lua"), "utf8");
  const bridgeInventorySource = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-BridgeInventory-Test.lua"), "utf8");
  const httpModuleInventorySource = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-HttpModuleInventory-Test.lua"), "utf8");
  const readme = readFileSync(resolve(process.cwd(), "README.md"), "utf8");

  it("checks key.json, key.txt, key.in, then key.ini in order", () => {
    const jsonIndex = source.indexOf('KEY_DIR .. "/key.json"');
    const txtIndex = source.indexOf('KEY_DIR .. "/key.txt"');
    const inIndex = source.indexOf('KEY_DIR .. "/key.in"');
    const iniIndex = source.indexOf('KEY_DIR .. "/key.ini"');

    expect(jsonIndex).toBeGreaterThan(-1);
    expect(txtIndex).toBeGreaterThan(jsonIndex);
    expect(inIndex).toBeGreaterThan(txtIndex);
    expect(iniIndex).toBeGreaterThan(inIndex);
  });

  it("stops on a malformed first readable file instead of falling through", () => {
    expect(resolveKeyLikeWrapper({
      "key.json": "{not-valid-json}",
      "key.txt": "VALID-LATER-KEY",
    })).toEqual({
      kind: "error",
      message: "key.json must contain a string field named key",
    });
  });

  it("accepts key.ini as the final compatibility fallback", () => {
    expect(resolveKeyLikeWrapper({ "key.ini": "VALID-INI-KEY" })).toEqual({
      kind: "key",
      value: "VALID-INI-KEY",
    });
  });

  it("fails closed when no supported key file is readable", () => {
    expect(resolveKeyLikeWrapper({})).toEqual({
      kind: "error",
      message: "key file not found",
    });
  });

  it("keeps missing-file and empty-file failures explicit", () => {
    expect(source).toContain("key file not found; tried key.json, key.txt, key.in, and key.ini");
    expect(source).toContain('key file is empty: " .. selected_file');
    expect(source).toContain("error(text, 0)");
  });

  it("accepts JSON key objects and plain key strings", () => {
    expect(source).toContain('raw:sub(1, 1) == "{"');
    expect(source).toContain("type(parsed.key) == \"string\"");
    expect(source).toContain("return raw");
  });

  it("uses the verified direct HttpWrapper callback for the canonical validation endpoint", () => {
    expect(source).toContain('API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"');
    expect(source).toContain('rawget(_G, "slua_GameFrontendHUD")');
    expect(source).toContain("response_event:Add(function(reqIndex, elapsedTime, data, content, success, result)");
    expect(source).toContain('http_wrapper:RequestForLua(API_URL, "POST", headers, payload, 0, 0)');
    expect(source).toContain('["Content-Type"] = "application/json"');
    expect(source).toContain('["Accept-Encoding"] = "identity"');
    expect(source).not.toContain('pcall(require, "ssl.https")');
    expect(source).not.toContain('pcall(require, "socket.http")');
  });

  it("keeps callback and canonical-status failures fail-closed and explicit", () => {
    expect(source).toContain('stop("license server unreachable")');
    expect(source).toContain('fail_with_popup("CONNECTION ERROR", "VALIDATION_RESPONSE_INVALID", "license validation response was invalid")');
    expect(source).toContain('expired = { popup = "KEY EXPIRED", stop_message = "key has expired" }');
    expect(source).toContain('not_registered = { popup = "INVALID KEY", stop_message = "key is not registered" }');
    expect(source).toContain('invalid = { popup = "KEY REVOKED", stop_message = "key has been revoked or banned" }');
    expect(source).toContain('device_max_reached = { popup = "DEVICE LIMIT REACHED", stop_message = "device limit reached for this key" }');
    expect(source).toContain("Nothing below the marker runs until the asynchronous callback");
    expect(source).toContain("start_license_validation(run_authorized_main, entered_raw_key)");
  });

  it("aligns the downloadable wrapper with valid-first entered-key replacement while preserving prior keys on all unsuccessful branches", () => {
    const successfulBranch = source.indexOf('response.status == "valid" and response.success == true');
    const saveIndex = source.indexOf("save_validated_key(json, key)", successfulBranch);
    const maintenanceGateIndex = source.indexOf("gate_server_maintenance(json, response, key, on_authorized)", successfulBranch);
    const failureBranch = source.indexOf("local outcome = outcomes[response.status]", maintenanceGateIndex);
    expect(source).toContain("local function save_validated_key(json, key)");
    expect(successfulBranch).toBeGreaterThan(-1);
    expect(saveIndex).toBeGreaterThan(successfulBranch);
    expect(maintenanceGateIndex).toBeGreaterThan(saveIndex);
    expect(failureBranch).toBeGreaterThan(maintenanceGateIndex);
    expect(source.slice(failureBranch)).not.toContain("save_validated_key(json, key)");
  });

  it("uses the approved isolated Maintenance gate before Main Lua, then restores presentation-only Announcement and explicit Telegram ticket handling", () => {
    const gateIndex = source.indexOf("local function gate_server_maintenance");
    const authorizedIndex = source.indexOf("on_authorized(validated_response, validated_key)", gateIndex);
    const mainIndex = source.indexOf("local function run_authorized_main");
    const announcementIndex = source.indexOf("fetch_active_announcement(validated_key)", mainIndex);
    expect(source).toContain('MAINTENANCE_URL = "https://luapanel-8355ybgt.manus.space/api/maintenance/active"');
    expect(source).toContain('http_wrapper:RequestForLua(MAINTENANCE_URL, "GET", headers, "", 0, 0)');
    expect(source).toContain("if response.active == true then");
    expect(source).toContain("announce(message, title)");
    expect(authorizedIndex).toBeGreaterThan(gateIndex);
    expect(source).toContain('ANNOUNCEMENT_URL = "https://luapanel-8355ybgt.manus.space/api/announcement/active"');
    expect(source).toContain('TELEGRAM_TICKET_URL = "https://luapanel-8355ybgt.manus.space/api/telegram/ticket"');
    expect(source).toContain('TELEGRAM_REDEEM_URL = "https://luapanel-8355ybgt.manus.space/api/telegram/redeem"');
    expect(source).toContain("request_telegram_ticket(validated_key, device_id");
    expect(source).toContain("show_system_announcement(title, message, ticket, device_id)");
    expect(announcementIndex).toBeGreaterThan(mainIndex);
  });

  it("writes a non-secret runtime capability report for HTTP discovery", () => {
    expect(source).toContain('RUNTIME_REPORT_FILE = KEY_DIR .. "/.runtime_globals"');
    expect(source).toContain("pcall(pairs, _G)");
    expect(source).toContain('value_type == "function" or value_type == "table"');
    expect(source).toContain("Global capabilities:");
    expect(source).toContain('Nested network namespaces inspected: Net, NetUtil, UnrealNet');
    expect(source).toContain('Candidate function metadata (descriptive only; no candidate is invoked)');
    expect(source).toContain('debug_api.getinfo');
    expect(source).toContain('Metatable structure (keys/types only; no metamethods or candidates are invoked)');
    expect(source).toContain('pcall(getmetatable, value)');
    expect(source).toContain('write_metatable_summary("NetUtil"');
    expect(source).toContain('NetUtil.ConnectToURLDirectly');
    expect(source).toContain('if (name == "Net" or name == "NetUtil" or name == "UnrealNet")');
    expect(source).toContain("names/types only");
  });

  it("keeps the Downloader capability probe opt-in and non-secret", () => {
    expect(source).toContain("ENABLE_DOWNLOADER_PROBE = false");
    expect(source).toContain('importer, "Downloader"');
    expect(source).toContain('downloader:DownloadFile(DOWNLOADER_PROBE_URL, DOWNLOADER_PROBE_FILE)');
    expect(source).toContain("DOWNLOADER_PROBE_SUCCESS GET_FILE_WRITE");
    expect(source).toContain("DOWNLOADER_PROBE_NO_VERIFIED_FILE");
    expect(source).toContain("No key, device ID, game packet, or main code");
    expect(source).toContain('DOWNLOADER_PROBE_URL = "https://luapanel-8355ybgt.manus.space/downloader-probe.txt"');
    expect(source).not.toContain("Net.SendPacket(DOWNLOADER_PROBE_URL");
  });

  it("keeps the final bridge inventory diagnostic non-invasive", () => {
    expect(bridgeInventorySource).toContain("BRIDGE_INVENTORY_V1");
    expect(bridgeInventorySource).toContain("pcall(importer, module_name)");
    expect(bridgeInventorySource).toContain("No network or packet function was invoked");
    expect(bridgeInventorySource).not.toContain("DownloadFile(");
    expect(bridgeInventorySource).not.toContain("SendPacket(");
    expect(bridgeInventorySource).not.toContain("ConnectToURL(");
    expect(bridgeInventorySource).not.toContain("socket.http");
    expect(bridgeInventorySource).not.toContain("HTTP_POST(");
  });

  it("keeps the expanded host-surface inventory non-invasive", () => {
    const hostSurfaceSource = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-HostSurfaceInventory-Test.lua"), "utf8");
    expect(hostSurfaceSource).toContain("HOST_SURFACE_INVENTORY_V1");
    expect(hostSurfaceSource).toContain("ScriptHelperNetInterface");
    expect(hostSurfaceSource).toContain("Callback");
    expect(hostSurfaceSource).toContain("FileUtil");
    expect(hostSurfaceSource).toContain("pcall(importer, module_name)");
    expect(hostSurfaceSource).toContain("No host-native method, network call, packet call, callback, or delegate was invoked.");
    expect(hostSurfaceSource).not.toContain("DownloadFile(");
    expect(hostSurfaceSource).not.toContain("SendPacket(");
    expect(hostSurfaceSource).not.toContain("ConnectToURL(");
    expect(hostSurfaceSource).not.toContain("HTTP_POST(");
    expect(hostSurfaceSource).not.toContain("socket.http");
  });

  it("keeps the host contract-shape diagnostic metadata-only", () => {
    const contractShapeSource = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-HostContractShape-Test.lua"), "utf8");
    expect(contractShapeSource).toContain("HOST_CONTRACT_SHAPE_V1");
    expect(contractShapeSource).toContain("ScriptHelperNetInterface");
    expect(contractShapeSource).toContain("ScriptHelperClient");
    expect(contractShapeSource).toContain("debug.getinfo");
    expect(contractShapeSource).toContain("getmetatable");
    expect(contractShapeSource).toContain("No candidate method, callback, delegate, network, URL, download, packet, or game API was invoked.");
    expect(contractShapeSource).not.toContain("Connect(");
    expect(contractShapeSource).not.toContain("OpenURLInSDK(");
    expect(contractShapeSource).not.toContain("LoadH5FromCache(");
    expect(contractShapeSource).not.toContain("socket.http");
    expect(contractShapeSource).not.toContain("HTTP_POST(");
  });

  it("limits the next discovery test to selected zero-argument getters", () => {
    const getterSource = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-GetterReturn-Test.lua"), "utf8");
    expect(getterSource).toContain("GETTER_RETURN_PROBE_V1");
    expect(getterSource).toContain("pcall(fn)");
    expect(getterSource).toContain("GameMasterGetWebUIUrl");
    expect(getterSource).toContain("GetFileDirPath");
    expect(getterSource).toContain("No license key, device ID, URL request, Connect, OpenURLInSDK, download, callback, or main Lua was invoked.");
    expect(getterSource).not.toContain("Connect(");
    expect(getterSource).not.toContain("OpenURLInSDK(");
    expect(getterSource).not.toContain("DownloadFile(");
    expect(getterSource).not.toContain("socket.http");
    expect(getterSource).not.toContain("HTTP_POST(");
  });

  it("keeps the friend-code HTTP module inventory non-invasive", () => {
    expect(httpModuleInventorySource).toContain("HTTP_MODULE_INVENTORY_V1");
    expect(httpModuleInventorySource).toContain('inspect_require("Http")');
    expect(httpModuleInventorySource).toContain('inspect_require("WebRequest")');
    expect(httpModuleInventorySource).toContain('inspect_require("SimpleHttp")');
    expect(httpModuleInventorySource).toContain("No HTTP request, URL open, callback, downloader, packet, or license function was invoked.");
    expect(httpModuleInventorySource).not.toContain("NewRequest()");
    expect(httpModuleInventorySource).not.toContain("SetUrl(");
    expect(httpModuleInventorySource).not.toContain("Send()");
    expect(httpModuleInventorySource).not.toContain("WebRequest:Get(");
    expect(httpModuleInventorySource).not.toContain("SimpleHttp:Get(");
    expect(httpModuleInventorySource).not.toContain("loadstring(");
  });

  it("documents the friend-code security hazards before any adapter integration", () => {
    expect(httpModuleInventorySource).toContain("exposes the key in a URL/log");
    expect(httpModuleInventorySource).toContain("evaluates the response with loadstring");
  });

  it("covers each Downloader probe outcome without invoking license validation", () => {
    expect(simulateDownloaderProbe({ readProbeFile: () => undefined })).toBe("DOWNLOADER_PROBE_UNAVAILABLE import_missing");
    expect(simulateDownloaderProbe({ importer: () => { throw new Error("missing"); }, readProbeFile: () => undefined })).toBe("DOWNLOADER_PROBE_UNAVAILABLE import_failed");
    expect(simulateDownloaderProbe({ importer: () => ({}), readProbeFile: () => undefined })).toBe("DOWNLOADER_PROBE_UNAVAILABLE DownloadFile_missing");
    expect(simulateDownloaderProbe({ importer: () => ({ DownloadFile: () => { throw new Error("failed"); } }), readProbeFile: () => undefined })).toBe("DOWNLOADER_PROBE_CALL_FAILED");
    expect(simulateDownloaderProbe({ importer: () => ({ DownloadFile: () => undefined }), readProbeFile: () => "not-the-fixture" })).toBe("DOWNLOADER_PROBE_NO_VERIFIED_FILE");
    expect(simulateDownloaderProbe({ importer: () => ({ DownloadFile: () => undefined }), readProbeFile: () => "LUA_DOWNLOADER_PROBE_V1\n" })).toBe("DOWNLOADER_PROBE_SUCCESS GET_FILE_WRITE");
  });

  it("short-circuits the temporary Downloader copy before license POST validation", () => {
    const probeGate = probeSource.indexOf("if ENABLE_DOWNLOADER_PROBE == true then");
    const probeCall = probeSource.indexOf("run_downloader_probe()", probeGate);
    const probeReturn = probeSource.indexOf("return", probeCall);
    const validationCall = probeSource.indexOf("local LICENSE_SESSION = validate_license()");

    expect(probeGate).toBeGreaterThan(-1);
    expect(probeCall).toBeGreaterThan(probeGate);
    expect(probeReturn).toBeGreaterThan(probeCall);
    expect(validationCall).toBeGreaterThan(probeReturn);
    expect(probeSource).toContain("guarantees that no main Lua code runs during capability testing");
    expect(probeSource).not.toContain("pcall(run_downloader_probe)");
  });

  it("keeps the production wrapper probe-disabled", () => {
    expect(source).toContain("ENABLE_DOWNLOADER_PROBE = false");
    expect(source).not.toContain("if ENABLE_DOWNLOADER_PROBE == true then\n  run_downloader_probe()\n  return\nend");
  });

  it("documents the verified production HttpWrapper contract and retains historical diagnostic boundaries", () => {
    expect(readme).toContain("slua_GameFrontendHUD:GetHttpWrapper()");
    expect(readme).toContain("OnResponseEvent:Add(...)");
    expect(readme).toContain('RequestForLua(..., "POST", ...)');
    expect(readme).toContain("success=true");
    expect(readme).toContain("license server unreachable");
    expect(readme).toContain("does not fall back to `HTTP_POST`, LuaSocket, LuaSec, hidden transport discovery, or undocumented native calls");
    expect(readme).toContain("If the callback reports `success=false`, the loader stops");
    expect(readme).toContain("Getter-return probe decision table");
    expect(readme).toContain("No `.getter_return_probe` is created and the Lua host remains alive");
    expect(readme).toContain("The host closes, crashes, or silently stops during the test");
    expect(readme).toContain("pcall` can contain ordinary Lua errors but cannot guarantee recovery from a native host crash");
    expect(readme).toContain("GameMasterGetWebUIUrl");
    expect(readme).toContain("GetFileDirPath");
    expect(readme).toContain("require arguments; it does not establish their argument semantics");
    expect(readme).toContain("Http`, `WebRequest`, and `SimpleHttp`");
    expect(readme).toContain("loadstring");
    expect(readme).toContain("key in a URL");
  });
});

export {};
