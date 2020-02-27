FROM library/debian:stable-20200130-slim
RUN DEBIAN_FRONTEND="noninteractive" && \
    apt-get update && \
    apt-get install -y \
    lib32gcc1=1:8.3.0-6 \
    ca-certificates=20190110

ARG STEAM_DIR="/steam"
ARG STEAM_ARCHIVE="steamcmd_linux.tar.gz"
# STEAM_SHA=cebf0046bfd08cf45da6bc094ae47aa39ebf4155e5ede41373b579b8f1071e7c
ADD "https://steamcdn-a.akamaihd.net/client/installer/$STEAM_ARCHIVE" "$STEAM_DIR/$STEAM_ARCHIVE"
RUN tar --extract --directory "$STEAM_DIR" --file "$STEAM_DIR/$STEAM_ARCHIVE" && \
    rm "$STEAM_DIR/$STEAM_ARCHIVE"
ENV PATH="$STEAM_DIR:$PATH"
