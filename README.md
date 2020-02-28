# SteamCMD
Small image equipped with steamcmd, intended to be a foundation for game servers.

## Use it
To use this image as a foundation for a game server, simply include it in your Dockerfile:
```Dockerfile
FROM hetsh/steamcmd:<version>
```
`steamcmd.sh` can then be called from everywhere since it is included in `PATH`.

## Known Errors
> Failed to init SDL priority manager: SDL not found
> Failed to set thread priority: per-thread setup failed
> Failed to set thread priority: per-thread setup failed

This error occurs because steamcmd cannot find libsdl. Since installing `libsdl` in this base image would increase its size by 50% and `steamcmd` seems to work fine without it, i made the decision to not include it for now. If you encounter any breaking errors with `steamcmd` ar a game server you want to set up, `libsdl` can be easily installed:
```Dockerfile
RUN DEBIAN_FRONTEND="noninteractive" && apt-get install -y libsdl2-2.0-0
```

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-steamcmd)). Please feel free to ask questions, file an issue or contribute to it.