import React, { createContext, useContext, useEffect, useState } from "react";

export type Theme = "light" | "dark";
export type VisualTheme = "cosmic";

interface ThemeContextType {
  theme: Theme;
  toggleTheme?: () => void;
  visualTheme: VisualTheme;
  switchable: boolean;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

interface ThemeProviderProps {
  children: React.ReactNode;
  defaultTheme?: Theme;
  switchable?: boolean;
}

export function ThemeProvider({
  children,
  defaultTheme = "dark",
  switchable = false,
}: ThemeProviderProps) {
  const [theme, setTheme] = useState<Theme>("dark");
  const visualTheme: VisualTheme = "cosmic";

  useEffect(() => {
    const root = document.documentElement;
    root.classList.add("dark");
    root.setAttribute("data-visual-theme", "cosmic");
    root.classList.add("theme-cosmic");
    root.classList.remove("theme-cyber");
    try {
      localStorage.setItem("theme", "dark");
      localStorage.setItem("visualTheme", "cosmic");
    } catch {}
  }, []);

  const toggleTheme = undefined;

  return (
    <ThemeContext.Provider
      value={{
        theme,
        toggleTheme,
        visualTheme,
        switchable,
      }}
    >
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error("useTheme must be used within ThemeProvider");
  }
  return context;
}
