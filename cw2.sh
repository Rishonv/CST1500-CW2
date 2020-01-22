#!/usr/bin/env bash

function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    for opt; do printf "\n"; done

    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

function select_opt {
    select_option "$@" 1>&2
    local result=$?
    echo $result
    return $result
}

case `select_opt "Date & Time" "Calendar" "Delete" "Exit"` in
    0) zenity --info --title="Date & Time" --width=280 --height=100 \
		--text="The system date &amp; time is: \n$(date)"
		case $? in
    		0);;
    		1);;
		esac;;
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
esac

zenity --calendar