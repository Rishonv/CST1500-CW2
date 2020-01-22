#!/bin/sh

MENU=`zenity --list --title="What would you like to do?" --column="Options"\
    "Date & Time" \
    "Calendar" \
    "Delete" \
    "Exit"`

case $? in
    0) zenity --info --title="Date & Time" --width=280 --height=100 \
        --text="The system date &amp; time is: \n$(date)";;
    1) zenity --calendar;;
    2) FILE=`zenity --file-selection --title="Select a File"`
        case $? in
         0) if zenity --question --width=280 --height=100 --title="Are you sure?" --text="Are you sure you would like to delete \"$FILE\"?"
            then 
                rm -rf $FILE
                echo "\"$FILE\" deleted successfully"
            else
                zenity --info --width=280 --height=100 --title="Delete unsuccessful" --text="File not deleted."
            fi;;
         1) zenity --info --width=280 --height=100 --title="No file" --text="No file selected.";;
        -1) zenity --error --width=280 --height=100 --title="Error" --text="An unexpected error occurred";;
        esac;;
    3) exit;;
esac;