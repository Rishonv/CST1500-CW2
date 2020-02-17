#! /bin/bash

events=()

while read ev; do
	IFS='|' read -r -a arr <<< "$ev"
	events+=("<span color='${arr[2]}'>${arr[0]} : ${arr[1]}</span>")
done < events.txt

event=`yad --center --width=300 --height=400 --list \
	--column="Events" --text="Choose an event to delete" "${events[@]}"\
	--button="Delete" --button="gtk-close:1"`

case $? in
	0)	del=$(echo "$event" | sed 's/<\/\?[^>]\+>//g')
		del=${del::-1}
		IFS=' ' read -r -a arr <<< "$del"
		sed -i "/\b${arr[0]}|${arr[2]} ${arr[3]} ${arr[4]}|*\b/d" events.txt
		;;
	1)	bash yad-update.sh;;
esac
