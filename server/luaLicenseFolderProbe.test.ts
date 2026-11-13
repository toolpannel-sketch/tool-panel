import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";

const projectRoot = path.resolve(import.meta.dirname, "..");
const probe = readFileSync(path.join(projectRoot, "LuaLicenseFolderCapabilityProbe.lua"), "utf8");
const mergedLoader = readFileSync(path.join(projectRoot, "BRPlayerCharacterBase-Merged.lua"), "utf8");
const executableProbe = probe
  .split("\n")
  .filter(line => !line.trimStart().startsWith("--"))
  .join("\n");

describe("LuaLicense standalone folder capability probe", () => {
  it("targets only the existing lowercase Android license directory and a probe-only file", () => {
    expect(probe).toContain('local LICENSE_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"');
    expect(probe).toContain('local PROBE_RESULT_PATH = LICENSE_DIR .. "/.lua_license_folder_probe"');
    expect(probe).toContain('local MARKER = "LUA_LICENSE_FOLDER_PROBE_MARKER_V1"');
    expect(mergedLoader).not.toContain(".lua_license_folder_probe");
  });

  it("uses only the statically observed full-path Client writer candidate", () => {
    expect(probe).toContain('return client.WriteFileAtPath');
    expect(probe).toContain("pcall(writer, PROBE_RESULT_PATH, MARKER)");
    expect(executableProbe).not.toContain("Client.SaveStringToFile");
    expect(executableProbe).not.toContain("CreateDirectory");
    expect(executableProbe).not.toContain("MakeDirectory");
    expect(executableProbe).not.toContain("DirectoryExists");
    expect(executableProbe).not.toContain("os.execute");
    expect(executableProbe).not.toContain("lfs.");
  });

  it("reports only fixed non-secret capability labels and has no protected flow", () => {
    expect(probe).toContain('"path_available=true"');
    expect(probe).toContain('"directory_exists=" .. directory_exists');
    expect(probe).toContain('"create_supported=" .. create_supported');
    expect(probe).toContain('"create_result=" .. create_result');
    expect(probe).toContain('"verify_result=" .. verify_result');
    expect(probe).toContain('or "not_proven_no_directory_query"');
    expect(probe).toContain('and "marker_readable"');
    expect(probe).not.toContain("/api/");
    expect(probe).not.toContain("RequestForLua");
    expect(probe).not.toContain("Msg.Show");
    expect(probe).not.toContain("GetHttpWrapper");
    expect(probe).not.toContain("loadstring");
    expect(probe).not.toContain("require(");
  });
});
