# -------------------------------
# Bash Automation README (for script repo itself)
# -------------------------------
cat >README.md <<'EOF'
# React Development Project Initializer (Bash Script)

> Bootstrap modern React + Vite projects automatically

---

## 🚀 Overview

This repository contains a Bash script (`main.sh`) to quickly create new React projects with **JavaScript or TypeScript**, preconfigured with:

- **Vite** for fast builds
- **TailwindCSS** for styling
- **Axios** for HTTP requests
- **Lucide React** icons
- Git repository initialization
- Clean folder structure

The script focuses only on **tooling setup**, leaving architecture (routes, state, layouts) to the developer.

---

## 🛠 Features

- Interactive prompts for project name and flavour (JS / TS)
- Input validation
- Global `create-vite` or npx fallback
- Preinstalled dependencies
- Configured Vite + Tailwind
- Creates folders: components, contexts, pages, routes, types
- Initializes Git and `.gitignore`
- Creates `.env.example`

---

## ⚡ Usage

```bash
git clone <repo-url>
cd reactdev-init
./main.sh
