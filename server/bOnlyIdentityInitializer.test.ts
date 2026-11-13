import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

describe("B-only identity initializer", () => {
  const source = readFileSync(resolve(process.cwd(), "BOnlyIdentityInitializer.lua"), "utf8");

  it("uses the exact existing random fallback format and no production paths", () => {
    expect(source).toContain('local DEVICE_FILE = KEY_DIR .. "/.device_id"');
    expect(source).toContain('local alphabet = "0123456789abcdef"');
    expect(source).toContain('for i = 1, 32 do');
    expect(source).toContain('report("CREATED")');
  });

  it("reports fixed non-secret outcomes without exposing the identity", () => {
    expect(source).toContain('local RESULT_FILE = KEY_DIR .. "/.b_identity_initializer"');
    expect(source).toContain('report("PROVIDER_READY")');
    expect(source).toContain('report("EXISTING")');
    expect(source).toContain('report("STORAGE_UNAVAILABLE")');
    expect(source).not.toContain('print(provider_value)');
    expect(source).not.toContain('print(existing)');
    expect(source).not.toContain('print(chars)');
  });

  it("does not read keys, call the server, validate a license, or run presentation flow", () => {
    const executable = source
      .split("\n")
      .filter(line => !line.trimStart().startsWith("--"))
      .join("\n");
    expect(executable).not.toContain('key.json');
    expect(executable).not.toContain('license/validate');
    expect(executable).not.toContain('RequestForLua');
    expect(executable).not.toContain('HttpWrapper');
    expect(executable).not.toContain('run_authorized_main');
    expect(executable).not.toContain('.license_status');
    expect(executable).not.toContain('TELEGRAM_');
  });
});
