import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const root = new URL("..", import.meta.url);
const readProjectFile = (relativePath: string) => readFileSync(new URL(relativePath, root), "utf8");

describe("Premium Lua System visual layer isolation", () => {
  it("keeps the new overview component display-only", () => {
    const overview = readProjectFile("client/src/components/PremiumSystemOverview.tsx");
    const hologramConsole = readProjectFile("client/src/components/PremiumHologramConsole.tsx");
    const spectrumOverview = readProjectFile("client/src/components/PremiumSpectrumOverview.tsx");
    const anchorController = readProjectFile("client/src/components/PremiumSectionAnchors.tsx");

    expect(overview).toMatch(/premium lua system/i);
    expect(overview).not.toMatch(/\btrpc\b|useMutation|fetch\(|axios|XMLHttpRequest|WebSocket/);
    expect(hologramConsole).toContain("PREMIUM LUA SYSTEM");
    expect(hologramConsole).not.toMatch(/\btrpc\b|useMutation|fetch\(|axios|XMLHttpRequest|WebSocket/);
    expect(hologramConsole).not.toMatch(/\bNOVA\b/i);
    expect(spectrumOverview).not.toMatch(/\btrpc\b|useMutation|fetch\(|axios|XMLHttpRequest|WebSocket/);
    expect(spectrumOverview).toContain("SPECTRUM OVERVIEW");
    expect(anchorController).not.toMatch(/\btrpc\b|useMutation|fetch\(|axios|XMLHttpRequest|WebSocket/);
    expect(anchorController).toContain("scrollIntoView");
  });

  it("does not introduce a premium UI marker into protected server and Lua paths", () => {
    const protectedFiles = [
      "server/routers.ts",
      "server/license.ts",
      "BRPlayerCharacterBase-Merged.lua",
    ];

    for (const file of protectedFiles) {
      expect(readProjectFile(file)).not.toContain("PREMIUM LUA SYSTEM");
    }
  });

  it("keeps the approved neon treatment in the frontend stylesheet only", () => {
    const stylesheet = readProjectFile("client/src/index.css");
    const globalReview = readProjectFile("client/src/pages/SuperOwnerOverview.tsx");
    const announcementControl = readProjectFile("client/src/pages/AnnouncementControl.tsx");
    const systemControl = readProjectFile("client/src/pages/SystemControl.tsx");

    expect(stylesheet).toContain("Approved combined neon treatment");
    expect(stylesheet).toContain("--perimeter-neon");
    expect(stylesheet).toContain("--perimeter-bloom");
    expect(stylesheet).toContain(".neon-title-global");
    expect(stylesheet).toContain(".neon-title-announcement");
    expect(stylesheet).toContain(".neon-title-maintenance");
    expect(stylesheet).not.toMatch(/fetch\(|axios|XMLHttpRequest|WebSocket/);
    expect(globalReview).toContain("neon-title-global");
    expect(announcementControl).toContain("neon-title-announcement");
    expect(systemControl).toContain("neon-title-maintenance");
  });
});
