#!bash

DOCKER=docker
if [[ $(uname -r) == *"Microsoft"* ]]
then
  DOCKER=$DOCKER.exe
fi

TESTRUN=""
REBUILD=""

help_args="-h --help"
test_args="-t --test --dry-run"
rebuild_args="-r --rebuild --re-build"

if [[ " $help_args " == *" $1 "* ]]
then
    echo "Entry point for hazijavitorendszer."
    echo "USAGE:" "\`$1 [-h|-t|-r] [directory|[file] [file] ... ] \`"
    echo 
    echo "$help_args	Help"
    echo "		show this message and exit"
    echo "$test_args	Test (or dry run)"
    echo "		Run the whole system but with some notable changes:"
    echo "		force-rebuild the 'test' docker image"
    echo "		write logs onto screen rather than log-files"
    echo "		don't archive solutions"
    echo "		email answer is not sent, rather written to stderr"
    echo "		does not clean up incoming files"
    echo "$rebuild_args	Rebuild"
    echo "		force-rebuilding the 'release' docker image"
    echo "		Test mode always rebuilds the 'test' image"
    echo "		Rebuild mode is exclusive to Test mode and rebuilds the 'release' image only if set."
    exit
elif [[ " $test_args " == *" $1 "* ]]
then
    TESTRUN="$1"
    shift
elif [[ " $rebuild_args " == *" $1 "* ]]
then
    REBUILD="$1"
    shift
fi

mkdir -p logs

$DOCKER build -f hazijavitorendszer/Dockerfile -t hazibase hazijavitorendszer > /dev/null
if [ $? -ne 0 ]
then
    echo 'Failed to build image!' 1>&2
    exit 1
fi

DOCKER_CREATE="$DOCKER container create --cpus 1 --memory 100m"

if [ -n "$TESTRUN" ]
then
    $DOCKER build -f hazijavitorendszer/Dockerfile.test -t hazi_test hazijavitorendszer > /dev/null
    if [ $? -ne 0 ]
    then
        echo 'Failed to build image!' 1>&2
        exit 1
    fi
    container=$($DOCKER_CREATE --network none hazi_test)
else
    if [ `$DOCKER image ls -q hazi_release | wc -l` -lt 1 -o -n "$REBUILD" ]
    then
        $DOCKER build -f hazijavitorendszer/Dockerfile.release -t hazi_release hazijavitorendszer
        if [ $? -ne 0 ]
        then
            exit 1
        fi
    fi
    container=$($DOCKER_CREATE --network bridge --cap-add NET_ADMIN hazi_release)
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
        $DOCKER cp "$file" $container:/home/dummy/
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
            $DOCKER cp "$name" $container:/home/dummy/
            FILES+=("$name")
        fi
    done
fi

if [ "$TESTRUN" ]
then
    $DOCKER start -i $container
else
    $DOCKER start -i $container 2> logs/$container.err > logs/$container.log
    bash archive.sh "${FILES[@]}" < logs/$container.log
    if [ -d "$1" ]
    then
        rm -R "$1"
    fi
fi

$DOCKER rm $container > /dev/null
