#!/bin/bash
# Deploy Firestore rules and indexes
set -e
firebase deploy --only firestore:rules,firestore:indexes
echo "Firestore rules and indexes deployed."
