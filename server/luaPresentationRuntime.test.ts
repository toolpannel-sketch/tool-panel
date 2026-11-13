import { execFileSync } from "node:child_process";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

describe("production Lua announcement presentation behavior", () => {
  it("checks Maintenance before Main Lua, then fetches Announcement and redirects only through an explicit ticket", () => {
    const harness = resolve(process.cwd(), "server/lua_presentation_runtime_harness.lua");
    const loaders = ["BRPlayerCharacterBase-Reusable.lua", "BRPlayerCharacterBase-Merged.lua"];
    const outputs = loaders.map((loader) => execFileSync("lua", [harness, resolve(process.cwd(), loader)], {
      cwd: process.cwd(),
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    }));

    for (const output of outputs) expect(output).toContain("LUA_PRESENTATION_RUNTIME_HARNESS_PASS");
  });
});
