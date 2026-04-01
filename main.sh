#!/usr/bin/env bash

set -e

# -------------------------------
# Dependency Validation
# -------------------------------
validate_dependencies() {
  if ! command -v node &>/dev/null; then
    echo "Error: Node.js is not installed."
    exit 1
  fi

  if ! command -v npm &>/dev/null; then
    echo "Error: npm is not installed."
    exit 1
  fi
}

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
# Project Creation
# -------------------------------
create_project() {
  local template=$1
  local project_name=$2
  local use_alias=$3

  config_ext="js"
  app_file="App.jsx"

  if [[ "$template" == "react-ts" ]]; then
    config_ext="ts"
    app_file="App.tsx"
  fi

  # Create project
  if command -v create-vite &>/dev/null; then
    yes n | create-vite "$project_name" -t "$template"
  else
    yes n | npm exec create-vite@latest "$project_name" -- -t "$template"
  fi

  cd "$project_name" || exit

  rm -f src/App.css

  npm install
  npm install axios dotenv tailwindcss @tailwindcss/vite lucide-react
  npm install -D @vitejs/plugin-react

  # -------------------------------
  # Vite Config (with optional alias)
  # -------------------------------
  if [[ "$use_alias" == "y" ]]; then
    npm install -D path

    cat >"vite.config.${config_ext}" <<'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
})
EOF
  else
    cat >"vite.config.${config_ext}" <<'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
})
EOF
  fi

  # -------------------------------
  # Tailwind setup
  # -------------------------------
  echo "@import 'tailwindcss';" >src/index.css

  # -------------------------------
  # App Component
  # -------------------------------
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
          <img src={Reactimg} className="h-10" />
          +
          VITE
          <img src={Viteimg} className="h-10" />
        </h1>

        <p className="text-slate-400 flex items-center justify-center gap-2">
          Automated with Bash
          <Terminal size={64} className="text-emerald-400" />
        </p>
      </div>
    </main>
  );
}
EOF

  # -------------------------------
  # Folder Structure
  # -------------------------------
  mkdir -p src/components src/contexts src/pages src/routes src/types

  # -------------------------------
  # TS Alias config
  # -------------------------------
  if [[ "$template" == "react-ts" && "$use_alias" == "y" ]]; then
    cat >tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ESNext",
    "useDefineForClassFields": true,
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": false,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src"]
}
EOF
  fi

  # -------------------------------
  # Git Setup
  # -------------------------------
  if command -v git &>/dev/null; then
    git init
    echo -e "node_modules\ndist\n.env\n.vscode\n.DS_Store" >.gitignore
    git add .
    git commit -m "Initial commit: React setup"
  fi

  # -------------------------------
  # Env Setup
  # -------------------------------
  echo "VITE_API_URL=" >.env.example
  cp .env.example .env

  # -------------------------------
  # README
  # -------------------------------
  cat >README.md <<EOF
# ${project_name}

React + Vite starter (automated)

## Run
npm run dev

## Structure
src/
 ├─ components/
 ├─ contexts/
 ├─ pages/
 ├─ routes/
 ├─ types/
EOF

  echo ""
  echo "✅ Project created successfully"
  echo "👉 cd ${project_name} && npm run dev"
}

# -------------------------------
# ENTRY
# -------------------------------
validate_dependencies

read -p $'Enter project name:\n> ' -r project_name
validate_input "$project_name" "name"

echo -e "Choose:\n1) JavaScript\n2) TypeScript"
read -p $'> ' -r flavour
validate_input "$flavour" "flavour"

read -p $'Enable @ alias? (y/n):\n> ' -r use_alias

case "$flavour" in
1) create_project "react" "$project_name" "$use_alias" ;;
2) create_project "react-ts" "$project_name" "$use_alias" ;;
esac
