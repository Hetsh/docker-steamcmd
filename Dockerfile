FROM debian:buster-slim
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get install -y \
	lib32gcc1 \
	ca-certificates

ARG STEAM_DIR="/steam"
ARG STEAM_PKG="steamcmd_linux.tar.gz"
ADD "https://steamcdn-a.akamaihd.net/client/installer/$STEAM_PKG" "$STEAM_DIR/$STEAM_PKG"
RUN tar --extract --directory "$STEAM_DIR" --file "$STEAM_DIR/$STEAM_PKG" && \
	rm "$STEAM_DIR/$STEAM_PKG"
WORKDIR "$STEAM_DIR"
