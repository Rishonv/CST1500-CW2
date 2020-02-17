#!/bin/sh

function deleteFile() {
    FILE=`yad --file --title="Select a File"`
    case $? in
        0)  if yad --center --image=gtk-dialog-question --width=280 --height=100 \
                --title="Are you sure?" --text="Are you sure you would like to delete \"$FILE\"?"
            then 
                rm $FILE
                echo "\"$FILE\" deleted successfully"
                bash cw2.sh
            else
                yad --center --image=gtk-dialog-info --width=280 --height=100 \
                --title="Delete unsuccessful" --text="File not deleted."
                bash cw2.sh
            fi;;

        1)  bash cw2.sh;;
        -1) yad --center --image=gtk-dialog-error --width=280 --height=100\
            --title="Error" --text="An unexpected error occurred"
            bash cw2.sh;;
    esac
}

function dateAndTime() {
    yad --center --image=gtk-dialog-info --title="Date & Time" --width=280 --height=100 \
        --text="The system date and time is: \n$(date)"
    bash cw2.sh
}

menu=("Date and Time" "Calendar" "Delete" "Exit")
answer=`yad --center --list --separator="" --title="Menu" --column=Menu "${menu[@]}" --width=240 --height=220`

case "$answer" in
    "Date and Time") dateAndTime;;
    "Calendar") bash calendar.sh;;
    "Delete") deleteFile;;
    "Exit") exit;;
esac;