FROM library/debian:stable-20210511-slim
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && \
    apt-get install --assume-yes \
        lib32gcc1=1:8.3.0-6 \
        ca-certificates=20200601~deb10u2 && \
    rm -r /var/lib/apt/lists /var/cache/apt

ARG STEAM_DIR="/var/lib/steam"
ARG STEAM_ARCHIVE="steamcmd_linux.tar.gz"
ADD "https://steamcdn-a.akamaihd.net/client/installer/$STEAM_ARCHIVE" "$STEAM_ARCHIVE"
RUN mkdir "$STEAM_DIR" && \
    tar --extract --directory "$STEAM_DIR" --file "$STEAM_ARCHIVE" && \
    rm "$STEAM_ARCHIVE"
ENV STEAM_DIR="$STEAM_DIR" \
    PATH="$STEAM_DIR:$PATH"
