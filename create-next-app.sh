#!/bin/bash

# Function to update JSON files using sed
update_json() {
  file="$1"
  tmpfile=$(mktemp)
  sed 's/\("extends": \)\("[^"]*"\)/\1\[\2, "prettier"\]/' "$file" >"$tmpfile" && mv "$tmpfile" "$file"
}

# Check if a project name is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi
# Use the provided project name or default to "my-next-app"
project_name="${1:-my-next-app}"

# Create a new Next.js app with the provided project name
yes "" | npx create-next-app@14.1.4 "$project_name"

# Wait for the project directory to be created
while [ ! -d "$project_name" ]; do
  echo "Waiting for project directory to be created..."
  sleep 1
done

echo "Project Name: $project_name"

# Navigate into the project directory
cd "$project_name" || exit

# Install Shadcn
yes "" | npx shadcn-ui@latest init

# Install few components from Shadcn
npx shadcn-ui@latest add button
npx shadcn-ui@latest add input

# Install prettier and eslint plugin
npm install --save-dev prettier eslint-config-prettier prettier-plugin-tailwindcss

# Create a .prettierrc file with default configuration
echo '{
  "trailingComma": "es5",
  "semi": false,
  "tabWidth": 2,
  "singleQuote": true,
  "jsxSingleQuote": true,
  "plugins": ["prettier-plugin-tailwindcss"]
}' >.prettierrc

# Modifies the eslintrc.json file to extend prettier
update_json .eslintrc.json

# Modify package.json to include format scripts
sed -i '/"scripts": {/a\
  "format": "prettier --check --ignore-path .gitignore .",\
  "format:fix": "prettier --write --ignore-path .gitignore .",\
' package.json

# Run the format:fix script to format the project files
npm run format:fix

# Finish the setup
echo "Setup complete! Navigate to the project directory with 'cd $project_name' and start the development server with 'npm run dev'."

echo "You might still want to edit the layout file according to your needs and shadcn docs"
