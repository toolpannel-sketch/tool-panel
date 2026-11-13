import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";

const projectRoot = path.resolve(import.meta.dirname, "..");
const probe = readFileSync(path.join(projectRoot, "PhoneDeviceIdRestartProbe.lua"), "utf8");
const executableProbe = probe.replace(/--[^\n]*/g, "");

describe("standalone PhoneDeviceID restart probe", () => {
  it("uses only the V3-observed Client.GetPhoneDeviceID member with protected dot-call access", () => {
    expect(probe).toContain("return client.GetPhoneDeviceID");
    expect(probe).toContain("local call_ok, value = pcall(candidate)");
    expect(probe).toContain('local RESULT_FILE = LICENSE_DIR .. "/.phone_device_id_probe_result"');
    expect(probe).toContain('local STATE_FILE = LICENSE_DIR .. "/.phone_device_id_probe_state"');
  });

  it("reports only allowlisted labels and never persists or prints the raw value", () => {
    expect(probe).toContain('"api_available=" .. api_available');
    expect(probe).toContain('"value_present=" .. value_present');
    expect(probe).toContain('"restart_stable=" .. restart_stable');
    expect(probe).toContain("value = nil");
    expect(probe).not.toContain("write_file(STATE_FILE, value)");
    expect(probe).not.toContain('.. value ..');
    expect(probe).not.toContain("print(value)");
  });

  it("cannot read or modify production device, key, status, validation, or presentation flows", () => {
    for (const forbidden of [
      ".device_id",
      "key.json",
      ".license_status",
      "/api/license/validate",
      "Maintenance",
      "Announcement",
      "Telegram",
      "WriteFileAtPath",
      "math.random",
      "getPersistentDeviceId",
      "getDeviceId",
    ]) {
      expect(executableProbe).not.toContain(forbidden);
    }
  });
});
