FROM amd64/debian:stable-20220822-slim
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt update && \
    apt install --assume-yes \
        lib32gcc-s1=10.2.1-6 \
        ca-certificates=20210119 && \
    rm -r /var/lib/apt/lists /var/cache/apt

# Installation
ARG STEAM_DIR="/var/lib/steam"
RUN apt update && \
    apt install --no-install-recommends --assume-yes wget && \
    STEAM_ARCHIVE="steamcmd_linux.tar.gz" && \
    wget --quiet  "https://steamcdn-a.akamaihd.net/client/installer/$STEAM_ARCHIVE" && \
    apt purge --assume-yes --auto-remove wget && \
    rm -r /var/lib/apt/lists /var/cache/apt && \
    mkdir "$STEAM_DIR" && \
    tar --extract --directory "$STEAM_DIR" --file "$STEAM_ARCHIVE" && \
    rm "$STEAM_ARCHIVE"
ENV STEAM_DIR="$STEAM_DIR" \
    PATH="$STEAM_DIR:$PATH"
