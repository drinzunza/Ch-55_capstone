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

# Step 1: Clean up old files
echo "🗑️ Cleaning up old local files..."
[ -f "$DB_FILE" ] && rm -f "$DB_FILE"
[ -f "media.tar.gz" ] && rm -f "media.tar.gz"
[ -d "$MEDIA_DIR" ] && rm -rf "$MEDIA_DIR"

# Step 2: Download database
echo "⬇️ Downloading database from Heroku..."
if heroku ps:copy "$DB_FILE" --app "$HEROKU_APP_NAME"; then
  echo "✅ Database downloaded successfully."
else
  echo "❌ Failed to download database."
  exit 1
fi

# Step 3: Download media files - NEW RELIABLE METHOD
echo "⬇️ Downloading media files from Heroku..."
heroku run --no-tty --app "$HEROKU_APP_NAME" "cd /app && tar -czf /tmp/media.tar.gz $MEDIA_DIR" && \
heroku ps:copy /tmp/media.tar.gz --app "$HEROKU_APP_NAME" && \
tar -xzf media.tar.gz && \
rm media.tar.gz && \
echo "✅ Media files downloaded and extracted." || \
{ echo "❌ ERROR: Could not download media files"; exit 1; }

# Step 4: Push to Heroku (if needed)
echo "🚀 Pushing code to Heroku..."
git push heroku main && echo "✅ Deployed successfully!" || { echo "❌ Deployment failed"; exit 1; }