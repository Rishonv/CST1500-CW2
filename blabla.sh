export find_cmd='@bash -c "run_find %1 %2"'

export fpipe=$(mktemp -u --tmpdir find.XXXXXXXX)
mkfifo "$fpipe"

trap "rm -f $fpipe" EXIT

fkey=$(($RANDOM * $$))

function run_find {
    cal "$1" "$2"
}

export -f run_find

exec 3<> $fpipe

yad --plug="$fkey" --tabnum=1 --form --field="Name" '*' --field="Use regex:chk" '' \
    --field="Directory:dir" '' --field="Newer than:dt" '' \
    --field="Content" '' --field="gtk-find:fbtn" "$find_cmd" &

yad --plug="$fkey" --tabnum=2 --list --no-markup --dclick-action="bash -c 'open_file %s'" \
    --text "Search results:" --column="Name" --column="Size:sz" --column="Perms" \
    --column="Date" --column="Owner" --search-column=1 --expand-column=1 <&3 &

yad --paned --key="$fkey" --button="gtk-close:1" --width=700 --height=500 \
    --title="Find files" --window-icon="find"

exec 3>&-