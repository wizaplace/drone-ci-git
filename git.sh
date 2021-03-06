#!/bin/bash

echo "## Setting up .netrc"
echo "machine $DRONE_NETRC_MACHINE" >> "$HOME/.netrc"
echo "login $DRONE_NETRC_USERNAME" >> "$HOME/.netrc"
echo "password $DRONE_NETRC_PASSWORD" >> "$HOME/.netrc"

if [ -z "$DRONE_WORKSPACE" ]; then
    DRONE_WORKSPACE=$(pwd)
else
    if [ ! -d "$DRONE_WORKSPACE" ]; then
        echo "## Creating workspace (${DRONE_WORKSPACE})"
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

echo "## Exporting ${DRONE_COMMIT_SHA} to workspace (${DRONE_WORKSPACE})"
set -e
git archive --format=tar "$DRONE_COMMIT_SHA" | (cd "$DRONE_WORKSPACE" && tar xf -)
