#!/usr/bin/fish

# will record the current screen session at 1 FPS for tracking later

set -l DATE (date +%Y%m%d-%H%M)
set -l SCREEN DP-4
set -l FRAMERATE 5
set -l ROOT (cd (dirname (status -f)); and cd ..; and pwd)

mkdir -p $ROOT/recordings
gpu-screen-recorder -w $SCREEN -f $FRAMERATE -fm cfr -o $ROOT/recordings/$USER-$DATE.mp4 -v no
