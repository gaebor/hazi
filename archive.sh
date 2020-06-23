grep -P '^\[[^]]+\] <SUCCESS> submission from "' | while read line
do
    sender=`cut -f2 -d'"'<<<"$line"`
    exercise=`cut -f4 -d'"'<<<"$line"`
    point=`tr " " "\n" <<<"$line"| tail -n 1`
    
    if [ ! -d "archive/$exercise" ]
    then
        mkdir -p archive
        mkdir -p "archive/$exercise"
    fi
    
    printf "%s\n" "$@" | grep -P '(^|/)'"$exercise"'\.[^.]+' | \
    while read file
    do
        extension="${file##*.}"
        cp "$file" "archive/$exercise/$sender~$point.$extension"
    done
done
