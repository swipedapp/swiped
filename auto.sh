#!/bin/bash
cd $WORKSPACE_PATH
cd ../../
git add .
added=$(git diff --cached --name-only --diff-filter=A | tr '\n' ' ')
modified=$(git diff --cached --name-only --diff-filter=M | tr '\n' ' ')
deleted=$(git diff --cached --name-only --diff-filter=D | tr '\n' ' ')
message=""
if [ -n "$added" ]; then
  message="${message}Added: ${added}"
fi
if [ -n "$modified" ]; then
  if [ -n "$message" ]; then
    message="${message}"
  fi
  message="${message}Modified: ${modified}"
fi
if [ -n "$deleted" ]; then
  if [ -n "$message" ]; then
    message="${message}"
  fi
  message="${message}Deleted: ${deleted}"
fi
if [ -z "$message" ]; then
  message="No Change"
  exit 0
fi

# Write message to the commit message file
git commit -m "$message"
