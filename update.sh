#!/usr/bin/env bash


# Abort on any error
set -eu

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/debian.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Current version of docker image
register_current_version

# Base Image
update_image "amd64" "stable-\d+-slim"

# 32bit GCC libs
update_pkg "lib32gcc1" "32bit GCC libs" "false" "\d+:(\d+\.)+\d+-\d+"

# CA-Certificates
update_pkg "ca-certificates" "CA-Certificates" "false" "\d+"

# SteamCMD
# SHA256 checksum for identification
# ToDo: Scrape real version
STEAM_PKG="STEAM_SHA"
CURRENT_STEAM_VERSION=$(cat Dockerfile | grep -P -o "$STEAM_PKG=\K\w+")
NEW_STEAM_VERSION=$(curl -L -s "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sha256sum | cut -d ' ' -f 1)
if [ "$CURRENT_STEAM_VERSION" != "$NEW_STEAM_VERSION" ]; then
	prepare_update "$STEAM_PKG" "SteamCMD" "$CURRENT_STEAM_VERSION" "$NEW_STEAM_VERSION"

	# Generate pseudo version
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
	save_changes

	if [ "${1+}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi