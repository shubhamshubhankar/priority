#!/bin/bash
# Build Flutter Web and deploy to Firebase Hosting
set -e

echo "Building Flutter Web (CanvasKit renderer)..."
flutter build web --release --web-renderer canvaskit

echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "Done. Your app is live at https://<project-id>.web.app"
