import { execFileSync } from "node:child_process";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

describe("production Lua saved-key runtime behavior", () => {
  it("validates the entered key and preserves or replaces key.json only after the authoritative callback outcome", () => {
    const harness = resolve(process.cwd(), "server/lua_saved_key_runtime_harness.lua");
    const productionLoader = resolve(process.cwd(), "BRPlayerCharacterBase-Reusable.lua");
    const output = execFileSync("lua", [harness, productionLoader], {
      cwd: process.cwd(),
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    });

    expect(output).toContain("LUA_SAVED_KEY_RUNTIME_HARNESS_PASS");
  });
});
