# -------------------------------
# Bash Automation README (Updated)
# -------------------------------
# React Development Project Initializer (Bash Script)

> Bootstrap modern React + Vite projects automatically (JS or TS)

---

## 🚀 Overview

This repository contains a Bash script (`main.sh`) that scaffolds a fully configured React project using **Vite**, with optional enhancements similar to modern frameworks like Next.js.

It handles **tooling, structure, and developer experience setup**, so you can focus on building features.

---

## 🛠 Features

- Interactive CLI prompts:
  - Project name
  - JavaScript or TypeScript
  - Optional `@` import alias (like Next.js)

- Smart project setup:
  - Vite (latest)
  - TailwindCSS preconfigured
  - Axios installed
  - Lucide React icons

- Optional import alias:

  import { useAuth } from "@/contexts/authContext"

- Clean folder structure:

  src/
   ├─ components/
   ├─ contexts/
   ├─ pages/
   ├─ routes/
   ├─ types/

- Git initialized automatically
- `.gitignore` generated
- `.env` + `.env.example` created
- Minimal starter UI included

---

## ⚡ Usage

git clone <repo-url>
cd reactdev-init
chmod +x main.sh
./main.sh

---

## 📦 What Gets Installed

### Dependencies
- axios
- dotenv
- tailwindcss
- @tailwindcss/vite
- lucide-react

### Dev Dependencies
- @vitejs/plugin-react

---

## 🧠 Alias Support (`@`)

If enabled during setup, the script configures:

- Vite alias
- TypeScript paths (if TS selected)

So you can import like:

import Button from "@/components/ui/buttonComponent"

Instead of:

import Button from "../../../components/ui/buttonComponent"

---

## 📁 Project Structure

project-name/
 ├─ src/
 │   ├─ components/
 │   ├─ contexts/
 │   ├─ pages/
 │   ├─ routes/
 │   ├─ types/
 │   ├─ App.(js|tsx)
 │   └─ index.css
 ├─ .env
 ├─ .env.example
 ├─ vite.config.(js|ts)
 └─ README.md

---

## 🔧 Requirements

- Node.js (v18+ recommended)
- npm

---

## 🎯 Philosophy

This script:
- ✅ Sets up tools and environment
- ❌ Does NOT enforce architecture

You stay in control of:
- State management
- Routing patterns
- Folder organization beyond basics

---

## 🔮 Future Improvements

- React Router auto-setup
- Feature-based architecture option
- ESLint + Prettier integration
- UI presets (shadcn, etc.)
- CLI packaging (`npx reactdev-init`)

---

## 📄 License

MIT

