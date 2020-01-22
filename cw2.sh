#!/bin/sh

menu=("Date & Time" "Calendar" "Delete" "Exit")
answer=`zenity --list --column=Menu "${menu[@]}" --height 170`

case "$answer" in
    "Date & Time") zenity --info --title="Date & Time" --width=280 --height=100 \
        --text="The system date &amp; time is: \n$(date)";;
    "Calendar") zenity --calendar;;
    "Delete") FILE=`zenity --file-selection --title="Select a File"`
        case $? in
         0) if zenity --question --width=280 --height=100 --title="Are you sure?" --text="Are you sure you would like to delete \"$FILE\"?"
            then 
                rm -rf $FILE
                echo "\"$FILE\" deleted successfully"
            else
                zenity --info --width=280 --height=100 --title="Delete unsuccessful" --text="File not deleted."
            fi;;
        -1) zenity --error --width=280 --height=100 --title="Error" --text="An unexpected error occurred";;
        esac;;
    "Exit") exit;;
esac;