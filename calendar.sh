#! /bin/bash

# exporting this function so it can be called from outside
export run_cal='@bash -c "calendar %1 %2"'

# export the two pipes to be accessed outside the program
export dpipe=/tmp/dpipe
export epipe=/tmp/epipe

# Check if pipes already exist, if not create them
if [[ ! -p $dpipe ]]; then
	mkfifo $dpipe
fi

if [[ ! -p $epipe ]]; then
	mkfifo $epipe
fi

# Clean Up function that deletes all temporary files created
function cleanup() {
	rm -f $dpipe
	rm -f $epipe
	rm -f cal.txt
}

# Catch the programs EXIT and run cleanup before it exits
trap cleanup EXIT

# Generate random ID for yad windows plugging
id=$(($RANDOM * $$))

# The main calendar generation function
function calendar {
	# Assign month and variable the first and second parameters
	month=$1
	year=$2

	# Get the calendar for said month and year and save it in 'cal.txt'
	cal "$month" "$year" > cal.txt
	# Perform 'sed' and 'grep' to get 'cal.txt' in the specific format we require
	sed -i '1,2d' cal.txt
	sed -i -e 's/   / - /g' cal.txt
	sed -i -e "s///g" cal.txt
	sed -i -e "s/_//g" cal.txt
	grep -o '[^ ]\+' cal.txt > temp.txt
	mv temp.txt cal.txt
	sed -i -e 's/^/ /' cal.txt
	sed -i -e 's/$/ /' cal.txt

	# Loop through 'cal.txt'
	while read date; do
		if [[ $date != "-" ]]; then # Make sure date is not blank
			# Check if date is single digit
			if [[ ${#date} -eq 1 ]]; then
				# If so then pad it with a 0
				sed -i -e "s/ $date /0$date/g" cal.txt
				date="0$date"
			fi
			# If the date is in 'events.txt'
			if grep "[|>]$date $month $year[|>]" events.txt; then
				# Get it's assigned color
				color=$(awk -F  "|" '/'"$date $month $year"'/{print $3; exit}' events.txt)
				# Format it according to said color
				sed -i -e 's/'"$date"'/'"<b><span color='$color'>$date<\/\span><\/\b>"'/g' cal.txt
			fi
		fi
	done < cal.txt

	# Clear the date pipe
	echo -e '\f' >> "$dpipe"
	# Loop through cal.txt
	while read date; do
		echo "$date" >> "$dpipe" # and each date to the date pipe
	done < cal.txt

	# Clear the events pipe
	echo -e '\f' >> "$epipe"
	# Loop through events.txt
	while read event; do
		# Split event into array for easier handling
		IFS='|' read -r -a arr <<< "$event"
		# Format event based on it's assigned color and add it to event pipe
		echo "<span color='${arr[2]}'>${arr[0]} : ${arr[1]}</span>" >> "$epipe"
	done < events.txt
}
export -f calendar # Export it because it will be called from outside

# Call initial calendar to start the program
calendar $(date +%B) $(date +%Y) &

# Create the window where you can change the month & year
yad --plug=$id --tabnum=3 --form --field="Month":CB \
	"January!February!March!April!May!June!July!August!September!October!November!Decemeber" \
	--field="Year" "$(date -d "$D" '+%Y')" \
    --field="Refresh Calendar":BTN "$run_cal" &

# Open the date pipe for read and write
exec 3<> $dpipe
yad --plug=$id --tabnum=1 --list --no-click --column="Su" --column="Mo" --column="Tu" \
--column="We" --column="Th" --column="Fr" --column="Sa" --expand-column=0 <&3 & # '<&3' is here to make sure that yad takes the output of the pipe as it's input
exec 3>&- # close the pipe

# The events pipe works exactly the same as above
exec 3<> $epipe
yad --plug=$id --tabnum=2 --list --column="Events" <&3 &
exec 3>&-

# Create the parent notebook that holds all the other tabs
yad --center --notebook --tab="Calendar" --tab="Events" --tab="Change Date" --key=$id \
	--button="Add Event:2" --button="Delete Event:3" --button="gtk-close:1" \
	--width=700 --height=500 --title="Calendar"

case $? in
	2) bash createEvent.sh;;
	3) bash deleteEvent.sh;;
	1) bash cw2.sh;;
esac