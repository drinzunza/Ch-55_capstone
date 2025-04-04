#!/bin/bash

# before running this script, make it executable
# chmod +x deploy.sh
# Mac/Linux: ./deploy.sh

# Windows: Right-click → Git Bash Here
# and run it with ./deploy.sh


# This script automates the process of downloading a SQLite database from Heroku,
# deleting the local version, and then pushing the code to Heroku.
# It assumes you have the Heroku CLI installed and are logged in.
# It also assumes you have a git repository set up and are on the main branch.
# Make sure to replace "your-heroku-app-name" with your actual Heroku app name.


# Configuration
HEROKU_APP_NAME="capstone-ch52"  # Replace with your app name
DB_FILE="dbProd.sqlite3"
MEDIA_DIR="mediaProd"

# Step 1: Delete old local files (if they exist)
echo "🗑️ Cleaning up old local files..."
[ -f "$DB_FILE" ] && rm -f "$DB_FILE"
[ -d "$MEDIA_DIR" ] && rm -rf "$MEDIA_DIR"

# Step 2: Download dbProd.sqlite3 from Heroku
echo "⬇️ Downloading database from Heroku..."
if heroku ps:copy "$DB_FILE" --app "$HEROKU_APP_NAME"; then
  echo "✅ Database downloaded successfully."
else
  echo "❌ Failed to download via 'ps:copy'. Trying manual method..."
  heroku run --no-tty "cat /app/$DB_FILE" > "$DB_FILE" --app "$HEROKU_APP_NAME" && \
  echo "✅ Database downloaded manually." || \
  { echo "❌ ERROR: Could not download database."; exit 1; }
fi

# Step 3: Download media files (images) from Heroku
echo "⬇️ Downloading media files from Heroku..."
if heroku ps:copy "$MEDIA_DIR" --app "$HEROKU_APP_NAME" --recursive; then
  echo "✅ Media files downloaded successfully."
else
  echo "❌ Failed to download media via 'ps:copy'. Trying manual method..."
  heroku run --no-tty "tar -czf /tmp/media.tar.gz -C /app $MEDIA_DIR" --app "$HEROKU_APP_NAME" && \
  heroku ps:copy /tmp/media.tar.gz --app "$HEROKU_APP_NAME" && \
  tar -xzf media.tar.gz && \
  rm media.tar.gz && \
  echo "✅ Media files extracted manually." || \
  { echo "❌ ERROR: Could not download media files."; exit 1; }
fi

# Step 4: Push to Heroku (optional)
echo "🚀 Pushing code to Heroku..."
git push heroku main
if [ $? -eq 0 ]; then
  echo "✅ Successfully deployed to Heroku!"
else
  echo "❌ Failed to push to Heroku."
  exit 1
fi