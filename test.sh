#!/usr/bin/env bash

set -e
trap "exit" SIGINT

if ! docker version &> /dev/null
then
    echo "Docker daemon is not running or you have unsufficient permissions!"
    exit 1
fi

IMAGE_NAME="steamcmd"
docker build --tag "$IMAGE_NAME" .
docker run --rm --interactive "$IMAGE_NAME" ./steamcmd.sh +login anonymous +quit
