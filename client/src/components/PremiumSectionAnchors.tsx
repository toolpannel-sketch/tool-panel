import { useEffect } from "react";

const anchorMap = [
  ["provision-access", "Generate key"],
  ["key-registry", "Keys you generated"],
  ["identity-control", "User roles"],
] as const;

export function PremiumSectionAnchors() {
  useEffect(() => {
    const assignAnchors = () => {
      for (const [id, heading] of anchorMap) {
        const node = Array.from(document.querySelectorAll("h2")).find(element => element.textContent?.trim() === heading)?.closest(".hud-panel");
        if (node) node.id = id;
      }
    };
    const scrollToHash = () => {
      const id = window.location.hash.slice(1);
      if (!id) return;
      const scroll = () => document.getElementById(id)?.scrollIntoView({ behavior: "smooth", block: "start" });
      window.requestAnimationFrame(() => window.requestAnimationFrame(scroll));
      window.setTimeout(scroll, 120);
    };

    assignAnchors();
    scrollToHash();
    window.addEventListener("hashchange", scrollToHash);
    return () => window.removeEventListener("hashchange", scrollToHash);
  }, []);

  return null;
}
