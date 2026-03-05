#!/usr/bin/env bash

set -e

# -------------------------------
# Input Validation
# -------------------------------
validate_input() {
  local input_value=$1
  local type=$2

  if [[ -z "$input_value" ]]; then
    echo "The input for ${type} is empty. Try again."
    exit 1
  fi

  if [[ "$type" == "name" && -d "$input_value" ]]; then
    echo "Project already exists. Try again."
    exit 1
  fi

  if [[ "$type" == "flavour" && ! "$input_value" =~ ^[12]$ ]]; then
    echo "Invalid flavour selection. Enter 1 or 2."
    exit 1
  fi
}

# -------------------------------
# Project Creation Function
# -------------------------------
create_project() {

  local template=$1
  local project_name=$2

  config_ext="js"
  app_file="App.jsx"

  if [[ "$template" == "react-ts" ]]; then
    config_ext="ts"
    app_file="App.tsx"
  fi

  if command -v create-vite &>/dev/null; then
    yes n | create-vite "$project_name" -t "$template"
  else
    echo "create-vite not found globally, using npm exec..."
    yes n | npm exec create-vite@latest "$project_name" -- -t "$template"
  fi

  cd "$project_name" || exit

  rm -f src/App.css

  npm install
  npm install axios dotenv tailwindcss @tailwindcss/vite lucide-react
  npm install -D @vitejs/plugin-react

  # Vite config
  cat >"vite.config.${config_ext}" <<'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
})
EOF

  globalcss=$(find ./src -type f -name "index.css")

  if [[ -n "$globalcss" ]]; then
    echo "@import 'tailwindcss';" >"$globalcss"
  else
    echo "@import 'tailwindcss';" >./src/index.css
  fi

  # App component with logos and icon
  cat >"./src/${app_file}" <<'EOF'
import { Terminal } from "lucide-react";
import Reactimg from "./assets/react.svg";
import Viteimg from "/vite.svg";

export default function App() {
  return (
    <main className="min-h-screen flex items-center justify-center bg-slate-900 text-white">
      <div className="text-center space-y-6">

        <h1 className="text-4xl font-bold flex items-center justify-center gap-3">
          REACT
          <img src={Reactimg} className="h-10" alt="React logo" />
          +
          VITE
          <img src={Viteimg} className="h-10" alt="Vite logo" />
        </h1>

        <p className="text-slate-400 flex items-center justify-center gap-2">
          Automated with Bash
          <Terminal size={64} className="text-emerald-400" />
        </p>

        <p className="text-sm text-slate-500">
          Your development environment was scaffolded automatically.
        </p>

      </div>
    </main>
  );
}
EOF

  cd src
  mkdir -p components contexts pages routes types
  cd ..

  # Initialize Git
  if command -v git &>/dev/null; then
    git init
    cat >.gitignore <<EOF
node_modules
dist
.env
.vscode
.DS_Store
EOF
    git add .
    git commit -m "Initial commit: React + Vite setup automated with bash"
  fi

  # Create .env.example
  cat >.env.example <<EOF
VITE_API_URL=
EOF

  # Create .env from .env.example if missing
  if [[ ! -f ".env" ]]; then
    cp .env.example .env
    echo ".env file created from .env.example"
  fi

  # React project README
  cat >README.md <<EOF
# ${project_name}

> React + Vite Development Starter

This project was **automatically scaffolded** using a Bash script to set up a modern React environment with **TailwindCSS**, **Lucide Icons**, and common utilities.

---

## 🛠 Features

- JavaScript or TypeScript support
- Interactive input validation
- Preinstalled dependencies: axios, dotenv, tailwindcss, @tailwindcss/vite, lucide-react
- Configured Vite with React & Tailwind plugin
- Clean project structure: components/, contexts/, pages/, routes/, types/
- Git initialized with .gitignore
- Ready-to-use starter App

---

## ⚡ Usage

\`\`\`bash
cd ${project_name}
npm run dev
\`\`\`

Ensure \$(.env) exists (copied from \$(.env.example)):
\`\`\`bash
cp .env.example .env
\`\`\`

Open browser at [http://localhost:5173](http://localhost:5173)

---

## 📂 Folder Structure

\`\`\`text
src/
 ├─ components/
 ├─ contexts/
 ├─ pages/
 ├─ routes/
 ├─ types/
 ├─ App.${config_ext}
 └─ index.css
\`\`\`

---

## 🎨 Notes

- TailwindCSS is ready
- Lucide-react icons available
- Remove demo code and start building your app
EOF

  chmod -R 755 .

  echo ""
  echo "✅ Project created successfully."
  echo ""
  echo "Next steps:"
  echo "cd ${project_name}"
  echo "npm run dev"
}

# -------------------------------
# Script Entry Point
# -------------------------------
read -p $'Enter the name of the react(ts) project: \n> ' project_name
validate_input "$project_name" "name"

echo -e "Choose a Flavour to use:\n1) JavaScript (js)\n2) TypeScript (ts)"
read -p $'Enter choice (1 or 2): \n> ' flavour_type
validate_input "$flavour_type" "flavour"

case "$flavour_type" in
1)
  echo "Project Name: ${project_name} - Flavour: JavaScript"
  create_project "react" "$project_name"
  ;;
2)
  echo "Project Name: ${project_name} - Flavour: TypeScript"
  create_project "react-ts" "$project_name"
  ;;
*)
  echo "Answer is not valid"
  exit 1
  ;;
esac
