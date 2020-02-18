#! /bin/bash

# Assign event to the result of the form
event=$(yad --center --form --field="Event name" "" \
	--field="Date":DT "" --date-format="%d %B %Y" \
	--field="Color":CB "red!blue!green!yellow")

# Check what return value yad returned
case $? in
	# '0' means that data was successfully entered
	0)	IFS='|' read -ra arr <<< "$event" # Split the data into an array
		for i in "${arr[@]}"; do
			if [[ -z "$i" ]]; then # Checks if any of the fields were empty
				yad --center --image=gtk-dialog-error --text="Empty field!" # Display error if so
				bash calendar.sh # Then bring user back to calendar without adding a new event
				exit
			fi
		done
		# Check if an event of the same name exists on the same day
		if grep -wq "${arr[0]}|${arr[1]}|*" events.txt; then
			yad --center  --image=gtk-dialog-error --text="The event already exists!" # Display error if so
			bash calendar.sh # Then bring user back to calendar without adding a new event
		else
			# If neither of the above statements execute
			echo -e "$event" >> events.txt # Add the event to events.txt
			bash calendar.sh # Then bring the user back to calendar
		fi
		;;
	# '1' means user exited
	1)	bash calendar.sh;; # If user exits then bring them back to calendar
esac