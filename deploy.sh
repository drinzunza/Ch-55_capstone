#!/bin/bash

# before running this script, make it executable
# chmod +x deploy.sh
# and run it with ./deploy.sh


# This script automates the process of downloading a SQLite database from Heroku,
# deleting the local version, and then pushing the code to Heroku.
# It assumes you have the Heroku CLI installed and are logged in.
# It also assumes you have a git repository set up and are on the main branch.
# Make sure to replace "your-heroku-app-name" with your actual Heroku app name.


# Configuration
HEROKU_APP_NAME="capstone-ch52"  # Replace with your app name
DB_FILE="dbProd.sqlite3"

# Step 1: Delete local dbProd.sqlite3 if it exists
if [ -f "$DB_FILE" ]; then
  echo "🗑️ Deleting local $DB_FILE..."
  rm "$DB_FILE"
else
  echo "ℹ️ Local $DB_FILE not found. Skipping deletion."
fi

# Step 2: Download dbProd.sqlite3 from Heroku
echo "⬇️ Downloading $DB_FILE from Heroku..."
if heroku ps:copy "$DB_FILE" --app "$HEROKU_APP_NAME"; then
  echo "✅ Successfully downloaded $DB_FILE from Heroku."
else
  echo "❌ Failed to download $DB_FILE. Falling back to manual method..."
  # Alternative: Use `heroku run` + `curl` if `ps:copy` fails
  heroku run --no-tty "cat /app/$DB_FILE" > "$DB_FILE" --app "$HEROKU_APP_NAME" && \
  echo "✅ Downloaded via manual method." || \
  { echo "❌ ERROR: Could not download $DB_FILE."; exit 1; }
fi

# Step 3: Push to Heroku
echo "🚀 Pushing code to Heroku..."
git push heroku main
if [ $? -eq 0 ]; then
  echo "✅ Successfully deployed to Heroku!"
else
  echo "❌ Failed to push to Heroku."
  exit 1
fi
