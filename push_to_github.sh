#!/usr/bin/env bash
set -e
REPO_URL="https://github.com/Aureliengrl/Doron.git"
BRANCH="main"

if [ ! -d .git ]; then
  git init
  git checkout -b "$BRANCH"
fi

git add -A
git commit -m "DORON Dev Agent: sync 4f1a751dfc40"
git remote remove origin >/dev/null 2>&1 || true
git remote add origin "$REPO_URL"
git branch -M "$BRANCH"
git push -u origin "$BRANCH"
echo "✅ Push terminé. Repo: $REPO_URL"
