#!/bin/bash

# Prompt user for commit message
read -p "Enter commit message: " commit_msg

# Stage all changes
git add .

# Commit with user-provided message
git commit -m "$commit_msg"

# Rename current branch to main
git branch -M main

# Push to origin main
git push -u origin main
