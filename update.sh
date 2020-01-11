#!/usr/bin/env bash

set -e
trap "exit" SIGINT

if [ "$USER" == "root" ]
then
	echo "Must not be executed as user \"root\"!"
	exit -1
fi

if ! [ -x "$(command -v jq)" ]
then
	echo "JSON Parser \"jq\" is required but not installed!"
	exit -2
fi

if ! [ -x "$(command -v curl)" ]
then
	echo "\"curl\" is required but not installed!"
	exit -3
fi

WORK_DIR="${0%/*}"
cd "$WORK_DIR"

CURRENT_VERSION=$(git describe --tags --abbrev=0)
NEXT_VERSION="$CURRENT_VERSION"

# Base Image
IMAGE_RELEASE="stable"
CURRENT_IMAGE_VERSION=$(cat Dockerfile | grep -P -o "FROM debian:$IMAGE_RELEASE-\K(\d+)-slim")
CURRENT_IMAGE_VERSION="${CURRENT_IMAGE_VERSION%-slim}"
IMAGE_VERSION=$(curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/debian/tags?page_size=128' | jq '."results"[]["name"]' | grep -m 1 -P -o "$IMAGE_RELEASE-\K(\d+)-slim")
IMAGE_VERSION="${IMAGE_VERSION%-slim}"
if [ "$CURRENT_IMAGE_VERSION" != "$IMAGE_VERSION" ]
then
	echo "StableDebian $IMAGE_VERSION available!"

	RELEASE="${CURRENT_VERSION#*-}"
	NEXT_VERSION="${CURRENT_VERSION%-*}-$((RELEASE+1))"
fi

# lib32gcc
LIBGCC_PKG="lib32gcc1"
CURRENT_LIBGCC_VERSION=$(cat Dockerfile | grep -P -o "$LIBGCC_PKG=\K\d+:(\d+\.)+\d+-\d+")
LIBGCC_VERSION=$(curl -L -s "https://packages.debian.org/$IMAGE_RELEASE/$LIBGCC_PKG" | grep -P -o "$LIBGCC_PKG \(\K\d+:(\d+\.)+\d+-\d+")
if [ "$CURRENT_LIBGCC_VERSION" != "$LIBGCC_VERSION" ]
then
	echo "32bit GCC libs $LIBGCC_VERSION available!"

	RELEASE="${CURRENT_VERSION#*-}"
	NEXT_VERSION="${CURRENT_VERSION%-*}-$((RELEASE+1))"
fi

# ca-certificates
CA_PKG="ca-certificates"
CURRENT_CA_VERSION=$(cat Dockerfile | grep -P -o "$CA_PKG=\K\d+")
CA_VERSION=$(curl -L -s "https://packages.debian.org/$IMAGE_RELEASE/$CA_PKG" | grep -P -o "$CA_PKG \(\K\d+")
if [ "$CURRENT_CA_VERSION" != "$CA_VERSION" ]
then
	echo "CA-Certificates $CA_VERSION available!"

	RELEASE="${CURRENT_VERSION#*-}"
	NEXT_VERSION="${CURRENT_VERSION%-*}-$((RELEASE+1))"
fi

# SteamCMD
CURRENT_APP_VERSION=$(cat Dockerfile | grep -P -o "STEAM_SHA=\K\w+")
APP_VERSION=$(curl -L -s "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sha256sum | cut -d ' ' -f 1)
if [ "$CURRENT_APP_VERSION" != "$APP_VERSION" ]
then
	echo "SteamCMD sha256:$APP_VERSION available!"

	MINOR_VERSION="${CURRENT_VERSION%-*}"
	MINOR_VERSION="${MINOR_VERSION#*.}"
	NEXT_VERSION="1.$((MINOR_VERSION+1))-1"
fi

if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ]
then
	echo "No updates available."
else
	if [ "$1" == "--noconfirm" ]
	then
		SAVE="y"
	else
		read -p "Save changes? [y/n]" -n 1 -r SAVE && echo
	fi
	
	if [[ $SAVE =~ ^[Yy]$ ]]
	then
		if [ "$CURRENT_IMAGE_VERSION" != "$IMAGE_VERSION" ]
		then
			sed -i "s|FROM debian:$IMAGE_RELEASE.*|FROM debian:$IMAGE_RELEASE-$IMAGE_VERSION-slim|" Dockerfile
		fi

		if [ "$CURRENT_LIBGCC_VERSION" != "$LIBGCC_VERSION" ]
		then
			sed -i "s|$LIBGCC_PKG=.*|$LIBGCC_PKG=$LIBGCC_VERSION|" Dockerfile
		fi

		if [ "$CURRENT_CA_VERSION" != "$CA_VERSION" ]
		then
			sed -i "s|$CA_PKG=.*|$CA_PKG=$CA_VERSION|" Dockerfile
		fi

		if [ "$CURRENT_APP_VERSION" != "$APP_VERSION" ]
		then
			sed -i "s|STEAM_SHA=.*|STEAM_SHA=$APP_VERSION|" Dockerfile
		fi

		if [ "$1" == "--noconfirm" ]
		then
			COMMIT="y"
		else
			read -p "Commit changes? [y/n]" -n 1 -r COMMIT && echo
		fi

		if [[ $COMMIT =~ ^[Yy]$ ]]
		then
			git add Dockerfile
			git commit -m "Version bump to $NEXT_VERSION"
			git push
			git tag "$NEXT_VERSION"
			git push origin "$NEXT_VERSION"
		fi
	fi
fi
