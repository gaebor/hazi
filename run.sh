#!/usr/bin/env bash

TESTRUN=""

if [ "$1" = "--help" -o "$1" = "-help" -o "$1" = "-h" ]
then
    echo "Entry point for hazijavitorendszer."
    echo "USAGE:" "\`$1 [-h|--help|-t|--dry-run|--test] [directory|[file] [file] ... ] \`"
    echo 
    echo "Test (or dry run) does the same, with the notable exceptions:"
    echo " * force-rebuilding the docker image"
    echo " * without logging/archiving"
    echo " * without email answering"
    echo " * does not clean up incoming files"
    exit
elif [ "$1" = "--test" -o "$1" = "-t" -o "$1" = "--dry-run" ]
then
    TESTRUN="$1"
    shift
fi

mkdir -p logs

docker build -f hazijavitorendszer/Dockerfile -t hazibase hazijavitorendszer > /dev/null
if [ $? -ne 0 ]
then
    echo 'Failed to build image!' 1>&2
    exit 1
fi
    
if [ -n "$TESTRUN" ]
then
    docker build -f hazijavitorendszer/Dockerfile.test -t hazi_test hazijavitorendszer > /dev/null
    if [ $? -ne 0 ]
    then
        echo 'Failed to build image!' 1>&2
        exit 1
    fi
    container=$(docker container create --memory 100m --network none hazi_test)
else
    if [ `docker image ls -q hazi_release | wc -l` -lt 1 ]
    then
        docker build -f hazijavitorendszer/Dockerfile.release -t hazi_release hazijavitorendszer > /dev/null
        if [ $? -ne 0 ]
        then
            exit 1
        fi
    fi
    container=$(docker container create --memory 100m --network bridge --cap-add NET_ADMIN hazi_release)
fi

if [ -z "$container" ]
then
    exit 1
fi

FILES=()

if [ -d "$1" ]
then
    for file in "$1"/*
    do
        docker cp "$file" $container:/home/dummy/
        if [ $? -eq 0 ]
        then 
            FILES+=("$file")
        fi
    done
else
    for name in "$@"
    do
        if [ -f "$name" ]
        then
            docker cp "$name" $container:/home/dummy/
            FILES+=("$name")
        fi
    done
fi

if [ "$TESTRUN" ]
then
    docker start -i $container
else
    docker start -i $container 2> logs/$container.err > logs/$container.log
    bash archive.sh "${FILES[@]}" < logs/$container.log
    if [ -d "$1" ]
    then
        rm -R "$1"
    fi
fi

docker rm $container > /dev/null
