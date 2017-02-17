#!/bin/bash

echo "machine $DRONE_NETRC_MACHINE" >> "$HOME/.netrc"
echo "login $DRONE_NETRC_USERNAME" >> "$HOME/.netrc"
echo "password $DRONE_NETRC_PASSWORD" >> "$HOME/.netrc"

if [ -z "$DRONE_WORKSPACE" ]; then
    DRONE_WORKSPACE=$(pwd)
else
    if [ ! -d "$DRONE_WORKSPACE" ]; then
        mkdir -p "$DRONE_WORKSPACE"
    fi
fi

bareRepoPath="/bareRepo"

mkdir -p "$bareRepoPath"
cd "$bareRepoPath"

if [ ! -d "$bareRepoPath/refs" ]; then
    git clone --bare --mirror "$DRONE_REMOTE_URL" .
else
    git cat-file -t "$DRONE_COMMIT_SHA" 2>/dev/null 1>/dev/null
    result=$?
    if [ $result != 0 ]; then
        git fetch
    fi
fi

git worktree add "$DRONE_WORKSPACE" "$DRONE_COMMIT_SHA"

