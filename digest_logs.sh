#!/bin/bash
outfilename=logs/`date +%F -d '-3 day'`.txt

find logs -maxdepth 1 -type f -atime +1 -name '*.log' | xargs ls -tr "" 2> /dev/null | \
while read file
do
    echo -n $file
    cat $file >> $outfilename
    if [ $? -eq 0 ]
    then
        rm $file 2> /dev/null
        echo " DONE"
    else
        echo " ERROR"
    fi
done

rm -f `find logs -maxdepth 1 -type f -atime +1 -name '*.err'`
