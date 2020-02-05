#!/usr/bin/env bash


# Abort on any error
set -eu

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Current version of docker image
CURRENT_VERSION=$(git describe --tags --abbrev=0)
register_current_version "$CURRENT_VERSION"

# Base Image
IMAGE_PKG="debian"
IMAGE_NAME="Debian"
IMAGE_CHANNEL="stable"
IMAGE_REGEX="$IMAGE_CHANNEL-(\d+)-slim"
IMAGE_TAGS=$(curl -L -s "https://registry.hub.docker.com/v2/repositories/library/$IMAGE_PKG/tags?page_size=128" | jq '."results"[]["name"]' | grep -P -w "$IMAGE_REGEX" | tr -d '"')
IMAGE_VERSION=$(echo "$IMAGE_TAGS" | sort | tail -n 1)
CURRENT_IMAGE_VERSION=$(cat Dockerfile | grep -P -o "$IMAGE_PKG:\K$IMAGE_REGEX")
if [ "$CURRENT_IMAGE_VERSION" != "$IMAGE_VERSION" ]; then
	echo "$IMAGE_NAME $IMAGE_VERSION available!"
	update_release
fi

# 32bit GCC libs
LIBGCC_PKG="lib32gcc1"
LIBGCC_NAME="32bit GCC libs"
LIBGCC_REGEX="\d+:(\d+\.)+\d+-\d+"
LIBGCC_VERSION=$(curl -L -s "https://packages.debian.org/$IMAGE_CHANNEL/$LIBGCC_PKG" | grep -P -o "$LIBGCC_PKG \(\K$LIBGCC_REGEX")
CURRENT_LIBGCC_VERSION=$(cat Dockerfile | grep -P -o "$LIBGCC_PKG=\K$LIBGCC_REGEX")
if [ "$CURRENT_LIBGCC_VERSION" != "$LIBGCC_VERSION" ]; then
	echo "$LIBGCC_NAME $LIBGCC_VERSION available!"
	update_release
fi

# CA-Certificates
CA_PKG="ca-certificates"
CA_NAME="CA-Certificates"
CA_REGEX="\d+"
CA_VERSION=$(curl -L -s "https://packages.debian.org/$IMAGE_CHANNEL/$CA_PKG" | grep -P -o "$CA_PKG \(\K$CA_REGEX")
CURRENT_CA_VERSION=$(cat Dockerfile | grep -P -o "$CA_PKG=\K$CA_REGEX")
if [ "$CURRENT_CA_VERSION" != "$CA_VERSION" ]; then
	echo "$CA_NAME $CA_VERSION available!"
	update_release
fi

# SteamCMD
STEAM_PKG="STEAM_SHA" # sha256 checksum, not package name
STEAM_NAME="SteamCMD"
STEAM_REGEX="\w+"
STEAM_VERSION=$(curl -L -s "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sha256sum | cut -d ' ' -f 1)
CURRENT_STEAM_VERSION=$(cat Dockerfile | grep -P -o "STEAM_SHA=\K$STEAM_REGEX")
if [ "$CURRENT_STEAM_VERSION" != "$STEAM_VERSION" ]; then
	echo "$STEAM_NAME sha256:$STEAM_VERSION available!"
	
	# Generate pseudo version
	# ToDo: Scrape real version
	MINOR_VERSION="${CURRENT_VERSION%-*}"
	MINOR_VERSION="${MINOR_VERSION#*.}"
	update_version "1.$((MINOR_VERSION+1))-1"
fi

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1+}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	if [ "$CURRENT_IMAGE_VERSION" != "$IMAGE_VERSION" ]; then
		sed -i "s|$IMAGE_PKG:$CURRENT_IMAGE_VERSION|$IMAGE_PKG:$IMAGE_VERSION|" Dockerfile
		CHANGELOG+="$IMAGE_NAME $CURRENT_IMAGE_VERSION -> $IMAGE_VERSION, "
	fi
	if [ "$CURRENT_LIBGCC_VERSION" != "$LIBGCC_VERSION" ]; then
		sed -i "s|$LIBGCC_PKG=$CURRENT_LIBGCC_VERSION|$LIBGCC_PKG=$LIBGCC_VERSION|" Dockerfile
		CHANGELOG+="$LIBGCC_NAME $CURRENT_LIBGCC_VERSION -> $LIBGCC_VERSION, "
	fi
	if [ "$CURRENT_CA_VERSION" != "$CA_VERSION" ]; then
		sed -i "s|$CA_PKG=$CURRENT_CA_VERSION|$CA_PKG=$CA_VERSION|" Dockerfile
		CHANGELOG+="$CA_NAME $CURRENT_CA_VERSION -> $CA_VERSION, "
	fi
	if [ "$CURRENT_STEAM_VERSION" != "$STEAM_VERSION" ]; then
		sed -i "s|$STEAM_PKG=$CURRENT_STEAM_VERSION|$STEAM_PKG=$STEAM_VERSION|" Dockerfile
		CHANGELOG+="$STEAM_NAME $CURRENT_STEAM_VERSION -> $STEAM_VERSION, "
	fi
	CHANGELOG="${CHANGELOG%,*}"

	if [ "${1+}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes "$CHANGELOG"
	fi
fi
