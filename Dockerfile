FROM debian:stable-20191224-slim
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y \
	lib32gcc1=1:8.3.0-6 \
	ca-certificates=20190110

ARG STEAM_DIR="/steam"
ARG STEAM_PKG="steamcmd_linux.tar.gz"
# STEAM_SHA=cebf0046bfd08cf45da6bc094ae47aa39ebf4155e5ede41373b579b8f1071e7c
ADD "https://steamcdn-a.akamaihd.net/client/installer/$STEAM_PKG" "$STEAM_DIR/$STEAM_PKG"
RUN tar --extract --directory "$STEAM_DIR" --file "$STEAM_DIR/$STEAM_PKG" && \
	rm "$STEAM_DIR/$STEAM_PKG"
WORKDIR "$STEAM_DIR"
