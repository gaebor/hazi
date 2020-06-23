md5sum archive.sh run.sh run.cmd \
    `find hazijavitorendszer/ -maxdepth 1 -type f` \
    `find hazijavitorendszer/HW/ -maxdepth 1 -type f | grep -v '.answer' | grep -v '\.*.tsv'` | sort | (
if [ "$1" = "-l" -o "$1" = "--list" -o "$1" = "--long" ]
then
    cat
else
    md5sum
fi )
