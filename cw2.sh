#!/bin/sh

function deleteFile() {
    # Assign value of file selection to FILE
    FILE=`yad --center --file --title="Select a File"`

    # Do actions based on yad's return value
    case $? in
        # '0' means user successfully selected an event
        0)  if yad --center --image=gtk-dialog-question --width=280 --height=100 \
                --title="Are you sure?" --text="Are you sure you would like to delete \"$FILE\"?"
            then # Make sure they want to delete the file with an extra dialog
                rm -f $FILE # If they choose yes then use 'rm' to delete the file
                yad --center --image=gtk-dialog-info --width=280 --height=100 \
                --title="File deleted successfully" --text="File deleted." 
                # Display an info dialog saying that file was deleted
                bash cw2.sh # Bring user back to menu
            else # If user cancels
                yad --center --image=gtk-dialog-info --width=280 --height=100 \
                --title="Delete unsuccessful" --text="File not deleted."
                # Display an info dialog saying that file was not deleted
                bash cw2.sh # Bring user back to menu
            fi;;

        # '1' means user exited
        1)  bash cw2.sh;; # So bring them back to menu
    esac
}

function dateAndTime() {
    # Display simple dialog using 'date' to show the system date and time
    yad --center --image=gtk-dialog-info --title="Date & Time" --width=280 --height=100 \
        --text="The system date and time is: \n$(date)"
    bash cw2.sh # Bring user back to menu
}

# Create array of menu items
menu=("Date and Time" "Calendar" "Delete" "System Info" "Exit")
# Pass array as input to yad list and assign what user selects to 'answer'
answer=`yad --center --list --separator="" --title="Menu" --column=Menu "${menu[@]}" --width=240 --height=220`

# Check what user selected and do action
case "$answer" in
    "Date and Time") dateAndTime;; # Call 'dateAndTime' if user selects it
    "Calendar") bash calendar.sh;; # Call 'calendar.sh' if user selects it
    "Delete") deleteFile;; # Call 'deleteFile' if user selects it
    "System Info") bash sysinfo.sh;; # Call 'sysinfo.sh' if user selects it
    "Exit") exit;; # Exit the program if user selects it
esac;