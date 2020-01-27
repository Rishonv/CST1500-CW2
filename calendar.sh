#!/bin/sh

month=$(date -d "$D" '+%m')
year=$(date -d "$D" '+%y') 
echo "<table style='width:100%'>"  > cal.html

if [ $# -eq 0 ]; then
	cal "$month" "$year" > calendar.txt
	while line= read -r p; do
		echo "<tr>" >> cal.html
		IFS=' ' read -a arr <<< "$p"
		for day in "${arr[@]}"; do
		   if grep -Fq "$month/$day/$year" events.txt; then
			    echo "<td><mark>${day}</mark></td>" >> cal.html 
			else
			    echo "<td>${day}</td>" >> cal.html 
			fi
		done
		echo "</tr>" >> cal.html
	done < calendar.txt
	echo "</table>" >> cal.html
	cal=`zenity --text-info --filename="cal.html" --html --cancel-label="Close" --ok-label="Add event"`
	case $? in
		1) bash cw2.sh
			exit;;
		0) bash createEvent.sh
			bash calendar.sh;;
	esac
	exit
elif [ $# -eq 2 ]; then
	cal "$1" "$2" > calendar.txt
fi