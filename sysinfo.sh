#! /bin/bash

# Generate random ID to use as ID for plugging the windows
id=$(($RANDOM * $$))

# OS details
yad --plug=$id --tabnum=1 --text="$(cat /etc/*-release)" &

# CPU details
yad --plug=$id --tabnum=2 --text="$(lscpu)" & 

# Main Memory details
yad --plug=$id --tabnum=3 --text="$(sudo lshw -short -C memory)" &

# Hard Disk details
yad --plug=$id --tabnum=4 --text="$(sudo lshw -c disk)" &

# File System
yad --plug=$id --tabnum=5 --text="$(df)" &

# The parent container to all the above plugs (a yad notebook)
yad --center --notebook --tab="OS Type" --tab="CPU" --tab="Main Memory" --tab="Hard Disk" \
	--tab="File Systems" --key=$id --button="Go Back" --title="System Info"

# Call back to menu after user is done looking at info
bash cw2.sh