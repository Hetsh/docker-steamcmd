FROM library/debian:stable-20201012-slim
ARG DEBIAN_FRONTEND="noninteractive"
ARG STEAM_DIR="/usr/lib/steam"
RUN dpkg --add-architecture i386 && \
    sed -i "s|main|main non-free|" /etc/apt/sources.list && \
    echo "steam steam/question select I AGREE" | debconf-set-selections && \
    apt-get update && \
    apt-get install --no-install-recommends --assume-yes \
        ca-certificates=20190110 \
        steamcmd:i386=0~20180105-3 && \
    mv /usr/lib/games "$STEAM_DIR" && \
    mv "$STEAM_DIR/steam/steamcmd.sh" "$STEAM_DIR" && \
    mv "$STEAM_DIR/steam" "$STEAM_DIR/linux32" && \
    rm -r /var/lib/apt/lists /var/cache/apt
ENV STEAM_DIR="$STEAM_DIR" \
    PATH="$STEAM_DIR:$PATH"
