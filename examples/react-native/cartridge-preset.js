const nativewind = require("nativewind/preset");
const twAnimate = require("tailwindcss-animate");

const cartridgePreset = {
  presets: [nativewind],
  darkMode: "selector",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    colors: {
      transparent: "transparent",
      current: "currentColor",
      background: {
        DEFAULT: "hsl(var(--background-100) / <alpha-value>)",
        100: "hsl(var(--background-100) / <alpha-value>)",
        125: "hsl(var(--background-125) / <alpha-value>)",
        150: "hsl(var(--background-150) / <alpha-value>)",
        200: "hsl(var(--background-200) / <alpha-value>)",
        300: "hsl(var(--background-300) / <alpha-value>)",
        400: "hsl(var(--background-400) / <alpha-value>)",
        500: "hsl(var(--background-500) / <alpha-value>)",
      },
      "translucent-dark": {
        DEFAULT: "hsl(var(--translucent-dark-100))",
        100: "hsl(var(--translucent-dark-100))",
        150: "hsl(var(--translucent-dark-150))",
        200: "hsl(var(--translucent-dark-200))",
        300: "hsl(var(--translucent-dark-300))",
      },
      "translucent-light": {
        DEFAULT: "hsl(var(--translucent-light-100))",
        100: "hsl(var(--translucent-light-100))",
        150: "hsl(var(--translucent-light-150))",
        200: "hsl(var(--translucent-light-200))",
        300: "hsl(var(--translucent-light-300))",
      },
      spacer: {
        DEFAULT: "hsl(var(--spacer-100) / <alpha-value>)",
        100: "hsl(var(--spacer-100) / <alpha-value>)",
      },
      foreground: {
        DEFAULT: "hsl(var(--foreground-100) / <alpha-value>)",
        100: "hsl(var(--foreground-100) / <alpha-value>)",
        200: "hsl(var(--foreground-200) / <alpha-value>)",
        300: "hsl(var(--foreground-300) / <alpha-value>)",
        400: "hsl(var(--foreground-400) / <alpha-value>)",
      },
      primary: {
        DEFAULT: "hsl(var(--primary-100) / <alpha-value>)",
        100: "hsl(var(--primary-100) / <alpha-value>)",
        200: "hsl(var(--primary-200) / <alpha-value>)",
        foreground: "hsl(var(--primary-foreground-100) / <alpha-value>)",
      },
      secondary: {
        DEFAULT: "hsl(var(--secondary-100) / <alpha-value>)",
        100: "hsl(var(--secondary-100) / <alpha-value>)",
      },
      destructive: {
        DEFAULT: "hsl(var(--destructive-100) / <alpha-value>)",
        100: "hsl(var(--destructive-100) / <alpha-value>)",
        foreground: "hsl(var(--spacer-100) / <alpha-value>)",
      },
      constructive: {
        DEFAULT: "hsl(var(--constructive-100) / <alpha-value>)",
        100: "hsl(var(--constructive-100) / <alpha-value>)",
        foreground: "hsl(var(--spacer-100) / <alpha-value>)",
      },
      "wallet-theme": {
        DEFAULT: "hsl(var(--wallet-theme-100) / <alpha-value>)",
        100: "hsl(var(--wallet-theme-100) / <alpha-value>)",
        200: "hsl(var(--wallet-theme-200) / <alpha-value>)",
        300: "hsl(var(--wallet-theme-300) / <alpha-value>)",
        400: "hsl(var(--wallet-theme-400) / <alpha-value>)",
        500: "hsl(var(--wallet-theme-500) / <alpha-value>)",
        600: "hsl(var(--wallet-theme-600) / <alpha-value>)",
      },
      border: "hsl(var(--background-100) / <alpha-value>)",
      input: "hsl(var(--background-300) / <alpha-value>)",
    },
    extend: {
      fontFamily: {
        sans: "Inter",
        mono: "IBM Plex Mono",
      },
      fontSize: {
        "2xs": "10px",
      },
      borderRadius: {
        xl: "12px",
        lg: "8px",
        md: "6px",
        sm: "4px",
        full: "9999px",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
        shimmer: {
          "0%": { backgroundPosition: "100% 0" },
          "20%": { backgroundPosition: "-100% 0" },
          "100%": { backgroundPosition: "-100% 0" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
        shimmer: "shimmer 2s linear infinite",
      },
    },
  },
  plugins: [twAnimate],
};

module.exports = { cartridgePreset };

