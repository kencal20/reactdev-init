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

  config_ext="js"
  app_file="App.jsx"

  if [[ "$template" == "react-ts" ]]; then
    config_ext="ts"
    app_file="App.tsx"
  fi

  # Pass --yes to npm exec to prevent interactive package prompts
  printf '\n' | npm exec --yes create-vite@latest "$project_name" -- --template "$template"

  cd "$project_name" || exit
  rm -f src/App.css

  # Dependencies
  npm install axios dotenv tailwindcss@^4 @tailwindcss/vite@^4 lucide-react
  npm install -D @vitejs/plugin-react @types/node

  # -------------------------------
  # Vite Config (Clean setup without aliases)
  # -------------------------------
  cat <<'EOF' >"vite.config.${config_ext}"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
})
EOF

  # -------------------------------
  # Tailwind setup
  # -------------------------------
  echo "@import 'tailwindcss';" >src/index.css

  # -------------------------------
  # App Component
  # -------------------------------
  cat <<'EOF' >"./src/${app_file}"
import { Terminal } from "lucide-react";
import Reactimg from "./assets/react.svg";
import Viteimg from "./assets/vite.svg";

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
  # Vite env / asset types
  # -------------------------------
  if [[ "$template" == "react-ts" ]]; then
    cat <<'EOF' >src/vite-env.d.ts
/// <reference types="vite/client" />

declare module "*.svg" {
  const content: string;
  export default content;
}

declare module "*.png" {
  const content: string;
  export default content;
}

declare module "*.jpg" {
  const content: string;
  export default content;
}

declare module "*.jpeg" {
  const content: string;
  export default content;
}

declare module "*.gif" {
  const content: string;
  export default content;
}

declare module "*.webp" {
  const content: string;
  export default content;
}
EOF
  fi

  # -------------------------------
  # TS Config (Clean setup without paths key)
  # -------------------------------
  if [[ "$template" == "react-ts" ]]; then
    cat <<'EOF' >tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "useDefineForClassFields": true,
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
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
\`\`\`bash
npm run dev
\`\`\`

## Structure
\`\`\`
src/
 ├─ components/
 ├─ contexts/
 ├─ pages/
 ├─ routes/
 └─ types/
\`\`\`
EOF

  echo ""
  echo "✅ Project created successfully"
  echo "👉 cd ${project_name} && npm run dev"
}

# -------------------------------
# ENTRY POINT
# -------------------------------
validate_dependencies

read -p $'Enter project name:\n> ' -r project_name
validate_input "$project_name" "name"

echo -e "Choose:\n1) JavaScript\n2) TypeScript"
read -p $'> ' -r flavour
validate_input "$flavour" "flavour"

case "$flavour" in
1) create_project "react" "$project_name" ;;
2) create_project "react-ts" "$project_name" ;;
esac
