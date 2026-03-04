# React Development Project Initializer

This repository contains a Bash script (`main.sh`) to quickly bootstrap a new React project with **JavaScript or TypeScript**, preconfigured with **Vite**, **TailwindCSS**, and some common utilities.

---

## Features

- Interactive script to create **React (JS/TS) projects**.
- Automatic **input validation** for project name and flavour.
- Supports both **global `create-vite` CLI** and **npx fallback**.
- Installs additional dependencies:  
  - `axios` – HTTP requests  
  - `dotenv` – Environment variables  
  - `tailwindcss` & `@tailwindcss/vite` – Styling  
  - `lucide-react` – Icon library
- Generates a **Vite config** (`vite.config.js` / `vite.config.ts`) with Tailwind plugin.
- Automatically updates or creates `src/index.css` with Tailwind import.

---

## Usage

1. Clone the repository:

```bash
git clone <repo-url>
cd reactdev-init
