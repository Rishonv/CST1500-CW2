#! /bin/bash

export run_cal='@bash -c "calendar %1 %2"'

export fpipe=/tmp/fpipe
export epipe=/tmp/epipe

if [[ ! -p $fpipe ]]; then
	mkfifo $fpipe
fi

if [[ ! -p $epipe ]]; then
	mkfifo $epipe
fi

function cleanup() {
	rm -f $fpipe
	rm -f $epipe
	rm -f cal.txt
}

trap cleanup EXIT

fkey=$(($RANDOM * $$))
id=$(($fkey + 1))

function calendar {
	month=$1
	year=$2
	cal "$month" "$year" > cal.txt
	sed -i '1,2d' cal.txt
	sed -i -e 's/   / . /g' cal.txt

	sed -i -e "s///g" cal.txt
	sed -i -e "s/_//g" cal.txt

	grep -o '[^ ]\+' cal.txt > temp.txt
	mv temp.txt cal.txt

	while read date; do
		if grep -wq "$date $month $year" events.txt; then
			color=$(awk -F  "|" '/'"$date $month $year"'/{print $3; exit}' events.txt)
			sed -i -e 's/'"$date"'/'"<b><span color='$color'>$date<\/\span><\/\b>"'/g' cal.txt
		fi
	done < cal.txt

	echo -e '\f' >> "$fpipe"
	while read date; do
		echo "$date" >> "$fpipe"
	done < cal.txt

	echo -e '\f' >> "$epipe"
	while read event; do
		IFS='|' read -r -a arr <<< "$event"
		echo "<span color='${arr[2]}'>${arr[0]} : ${arr[1]} </span>" >> "$epipe"
	done < events.txt
}
export -f calendar

yad --plug=$id --tabnum=3 --form --field="Month":CB \
	"January!February!March!April!May!June!July!August!September!October!November!Decemeber" \
	--field="Year" "$(date -d "$D" '+%Y')" \
    --field="Refresh Calendar":BTN "$run_cal" &

exec 3<> $fpipe
yad --plug=$id --tabnum=1 --list --no-click --column="Su" --column="Mo" --column="Tu" \
--column="We" --column="Th" --column="Fr" --column="Sa" --expand-column=0 `calendar $(date +%B) $(date +%Y)` <&3 &
exec 3>&-

exec 3<> $epipe
yad --plug=$id --tabnum=2 --list --column="Events" <&3 &
exec 3>&-

yad --notebook --tab="Calendar" --tab="Events" --tab="Change Date" --key=$id \
	--button="Add Event" --button="Delete Event" --button="gtk-close:2" \
	--width=700 --height=500 --title="Calendar"

case $? in
	0) bash createEvent.sh;;
	1) bash deleteEvent.sh;;
	2) bash cw2.sh;;
esac