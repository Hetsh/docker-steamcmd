FROM library/debian:stable-20201012-slim
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && \
    apt-get install --assume-yes \
        lib32gcc1=1:8.3.0-6 \
        ca-certificates=20190110 && \
    rm -r /var/lib/apt/lists /var/cache/apt

# Download SteamCMD
ENV STEAM_DIR="/var/lib/steam"
ARG STEAM_ARCHIVE="steamcmd_linux.tar.gz"
ADD "https://steamcdn-a.akamaihd.net/client/installer/$STEAM_ARCHIVE" "$STEAM_ARCHIVE"
RUN mkdir "$STEAM_DIR" && \
    tar --extract --directory "$STEAM_DIR" --file "$STEAM_ARCHIVE" && \
    rm -r "$STEAM_ARCHIVE"
ENV PATH="$STEAM_DIR:$PATH"

# Update client
ARG STEAM_VERSION="02 Nov 2020 21:30:00"
RUN steamcmd.sh +quit && \
    rm -r /tmp/dumps /root/.steam /root/Steam
