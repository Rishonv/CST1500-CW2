#!/bin/sh

menu=("Date & Time" "Calendar" "Delete" "Exit")
answer=`zenity --list --title="Menu" --column=Menu "${menu[@]}" --width=240 --height=220`

case "$answer" in
    "Date & Time") zenity --info --title="Date & Time" --width=280 --height=100 \
        --text="The system date &amp; time is: \n$(date)"
                   bash cw2.sh;;
    "Calendar") bash calendar.sh;;
    "Delete") FILE=`zenity --file-selection --title="Select a File"`
        case $? in
         0) if zenity --question --width=280 --height=100 --title="Are you sure?" \
            --text="Are you sure you would like to delete \"$FILE\"?"
            then 
                rm $FILE
                echo "\"$FILE\" deleted successfully"
                bash cw2.sh
            else
                zenity --info --width=280 --height=100 --title="Delete unsuccessful" --text="File not deleted."
                bash cw2.sh
            fi;;

         1) bash cw2.sh;;
        -1) zenity --error --width=280 --height=100 --title="Error" --text="An unexpected error occurred"
            bash cw2.sh;;
        esac;;
    "Exit") exit;;
esac;