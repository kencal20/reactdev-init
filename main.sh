#!/usr/bin/env bash

validate_input() {
  local input_value=$1
  local type=$2 # "name" or "flavour"

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

# Helper to create Vite project, either with global CLI or npx
create_project() {
  local template=$1
  local project_name=$2

  # Determine config file extension
  local config_ext="js"
  if [[ "$template" == "react-ts" ]]; then
    config_ext="ts"
  fi

  if command -v create-vite &>/dev/null; then
    yes n | create-vite "$project_name" -t "$template"
  elif command -v npm &>/dev/null; then
    echo "create-vite not found globally, using npx..."
    yes n | npm exec create-vite@latest "$project_name" -- -t "$template"
  else
    echo "Error: npm or create-vite CLI not found. Install Node.js first."
    echo "You can install Nodejs from https://nodejs.org/en"
    exit 1
  fi

  cd "$project_name" || exit

  npm install axios dotenv tailwindcss @tailwindcss/vite lucide-react

  # Create config file with correct extension
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

  # Find and update CSS file
  globalcss=$(find ./src -type f -name "index.css")
  if [[ -n "$globalcss" ]]; then
    echo "@import 'tailwindcss';" >"$globalcss"
    echo "Updated $globalcss with Tailwind import"
  else
    echo "Warning: index.css not found in ./src"
    echo "@import 'tailwindcss';" >./src/index.css
    echo "Created ./src/index.css with Tailwind import"
  fi
}

# Prompt project name
read -p $'Enter the name of the react(ts) project: \n> ' project_name
validate_input "$project_name" "name"

# Prompt flavour
echo -e "Choose a Flavour to use:\n1) JavaScript (js)\n2) TypeScript (ts)"
read -p $'Enter choice (1 or 2): \n> ' flavour_type
validate_input "$flavour_type" "flavour"

# Create project based on flavour
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
  ;;
esac
