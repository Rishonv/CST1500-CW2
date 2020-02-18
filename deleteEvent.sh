#! /bin/bash

# Initialize empty events array
events=()

# Loop through events.txt file
while read ev; do
	IFS='|' read -r -a arr <<< "$ev" # Split event into array for easier handling
	# Add each event to events array styled based on it's color
	events+=("<span color='${arr[2]}'>${arr[0]} : ${arr[1]}</span>")
done < events.txt

# Assign event to what event the user selects from the list
event=`yad --center --width=300 --height=400 --list --column="Events" \
	--text="Choose an event to delete" "${events[@]}" \
	--button="Delete" --button="gtk-close:1" --separator=" "`
# Pass the events array as input to yad list

# Check what return value yad returned
case $? in
	# '0' means user successfully selected an event
	0)	del=$(echo "$event" | sed 's/<\/\?[^>]\+>//g') # Destructure the event from the styled format
		IFS=' ' read -r -a arr <<< "$del"
		# Use 'sed' to delete the event from events.txt
		sed -i "/\b${arr[0]}|${arr[2]} ${arr[3]} ${arr[4]}|*\b/d" events.txt
		bash calendar.sh # Bring user back to calendar
		;;
	# '1' means user exited
	1)	bash calendar.sh;; # So bring them back to calendar
esac