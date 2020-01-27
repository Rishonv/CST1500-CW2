#!/bin/sh

if [ $# -eq 0 ]; then
	cal $(date -d "$D" '+%m') $(date -d "$D" '+%y') > calendar.txt
	while read p; do
		echo "<tr><td>${p}</td></tr>" >> cal.html 
	done < calendar.txt
	sed -i "1i<table>" cal.html
	echo "</table>" >> cal.html
	exit
elif [ $# -eq 2 ]; then
	cal "$1" "$2" > calendar.txt
fi