#! /bin/bash

info=()

# adds os type to info
info+=("<span color='teal'><b>Operating System Info</b></span>\n")
info+=$(cat /etc/*-release)

# adds cpu details to info
info+=("<span color='teal'><b>CPU Info</b></span>\n")
info+=$(lscpu)

yad --list --column="Information" --width=400 --height=700 --text="${info[@]}"