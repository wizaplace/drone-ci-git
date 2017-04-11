#!/bin/bash

echo "## Setting up .netrc"
echo "machine $DRONE_NETRC_MACHINE" >> "$HOME/.netrc"
echo "login $DRONE_NETRC_USERNAME" >> "$HOME/.netrc"
echo "password $DRONE_NETRC_PASSWORD" >> "$HOME/.netrc"

echo "## Setting up workspace @ ${DRONE_WORKSPACE}"
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
    echo "## Cloning bare repo from ${DRONE_REMOTE_URL} into ${bareRepoPath}"
    git clone --bare --mirror "$DRONE_REMOTE_URL" .
else
    git cat-file -t "$DRONE_COMMIT_SHA" 2>/dev/null 1>/dev/null # test if we have the requested commit locally already
    result=$?
    if [ $result != 0 ]; then
        echo "## Fetching repo updates"
        for i in {1..2}; do git fetch && break || sleep 1; done
    else
        echo "## Repo already has the required ref, nothing to fetch"
    fi
fi

echo "## Creating worktree@${DRONE_COMMIT_SHA} in workspace"
git worktree add "$DRONE_WORKSPACE" "$DRONE_COMMIT_SHA"

echo "## Cleaning up"
rm -f "$DRONE_WORKSPACE/.git" # the bare repo won't be accessible by other steps, no use in keeping the reference
git worktree prune

set -e
cd "$DRONE_WORKSPACE"
actualRev=$(git rev-parse --verify HEAD)
if [ $actualRev != $DRONE_COMMIT_SHA ]; then
    exit 1
fi
