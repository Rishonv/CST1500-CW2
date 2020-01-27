event=`zenity --forms --add-entry="Event Name" --add-calendar=Date --text="Add an event"`

IFS='|' read -a arr <<< "$event"

if [[ -z `echo ${arr[0]}` ]]; then
	zenity --error --text="No name provided"
else
	echo "$event" >> events.txt
fi