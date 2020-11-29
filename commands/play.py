from psutil import process_iter as pi
from os import system as sy

if "spotify" in (p.name() for p in pi()):
    sy("spotifycli --playpause")
else:
    sy("env LD_PRELOAD=/usr/lib/spotify-adblock.so spotify %U")
