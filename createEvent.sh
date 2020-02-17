#! /bin/bash

event=$(yad --form --field="Event name" "" --field="Date":DT "" --date-format="%d %B %Y" \
 --field="Color":CB "red!blue!green!yellow")

case $? in
	0)	IFS='|' read -ra arr <<< "$event"
		for i in "${arr[@]}"; do
			if [[ -z "$i" ]]; then
				bash yad-update.sh
				exit
			fi
		done
		if grep -wq "${arr[0]}|${arr[1]}|*" events.txt; then
			yad --image=gtk-dialog-error --text="The event already exists!"
			bash yad-update.sh
		else
			echo -e "$event" >> events.txt
			bash yad-update.sh
		fi
		;;
	1)	bash yad-update.sh;;
esac