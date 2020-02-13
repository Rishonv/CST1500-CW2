#!/bin/sh

month=`zenity --list --column="Month" "January" "February" "March" "April" \
	"May" "June" "July" "August" "September" "October" "November" "December"`

years=()
for ((i = $(date +%Y) ; i < $(date +%Y)+100 ; i++)); do
	years+=("$i")
done

year=`zenity --list --column="Years" "${years[@]}"`

echo "<h2>$(date +%b) $year</h2>"  > cal.html
echo "<table style='width:100%'>"  >> cal.html

if [ $# -eq 0 ]; then
	cal "$month" "$year" > calendar.txt
	sed -i '1d' calendar.txt
	sed -i -e "s/   / . /g" calendar.txt
	sed -i -e "s///g" calendar.txt
	sed -i -e "s/_//g" calendar.txt
	while line= read -r p; do
		echo "<tr>" >> cal.html
		IFS=' ' read -a arr <<< "$p"
		for day in "${arr[@]}"; do
		   if grep -Fq "$("$month" | cut -c1-3) $day $year" events.txt; then
			    echo "<td><mark>${day}</mark></td>" >> cal.html 
			else
			    echo "<td>${day}</td>" >> cal.html 
			fi
		done
		echo "</tr>" >> cal.html
	done < calendar.txt
	echo "</table>" >> cal.html
	echo "<h2>Events:</h2>" >> cal.html
	echo "<ul>" >> cal.html
	while read event; do
		echo "<li>$event</li>" >> cal.html
	done < events.txt
	echo "</ul>" >> cal.html
	cal=`zenity --text-info --filename="cal.html" --html --cancel-label="Close" --ok-label="Add event"`
	case $? in
		1) exit;;
		0) bash createEvent.sh
			bash calendar.sh;;
	esac
	exit
elif [ $# -eq 2 ]; then
	cal "$1" "$2" > calendar.txt
fi