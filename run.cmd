@ECHO OFF

IF [%1]==[--help] GOTO:help
IF [%1]==[-h] GOTO:help

ECHO [BUILD]
docker build -f hazijavitorendszer/Dockerfile -t hazibase hazijavitorendszer > nul
IF %ERRORLEVEL% NEQ 0 GOTO:eof

set "TESTRUN="

IF [%1]==[--test] ( set "TESTRUN=true" )
IF [%1]==[-t] ( set "TESTRUN=true" )
IF [%1]==[--dry-run] ( set "TESTRUN=true" )

IF [%TESTRUN%]==[] (
    ECHO [RELEASE]
    docker build -f hazijavitorendszer/Dockerfile.release -t hazi_release hazijavitorendszer > nul
    IF %ERRORLEVEL% NEQ 0 GOTO:eof
    ECHO [CREATE]
    docker container create --memory 100m --network bridge --cap-add NET_ADMIN hazi_release > temp.txt
) ELSE (
    ECHO [TEST]
    docker build -f hazijavitorendszer/Dockerfile.test -t hazi_test hazijavitorendszer > nul
    IF %ERRORLEVEL% NEQ 0 GOTO:eof
    ECHO [CREATE]
    docker container create --memory 100m --network none hazi_test > temp.txt
)

SET /P _container=<temp.txt

IF [%_container%]==[] GOTO:eof

ECHO [COPY]
docker cp solution/info %_container%:/home/dummy/
FOR %%G IN (%*) DO ( docker cp %%G %_container%:/home/dummy/ )

mkdir logs 2> nul

ECHO [RUN]
IF [%TESTRUN%]==[] (
    docker start -i %_container% 2> logs/%_container%.err > logs/%_container%.log
    bash archive.sh %* < logs/%_container%.log
) ELSE (
    docker start -i %_container%
)

REM ECHO [DELETE]
docker rm %_container% > nul

GOTO:eof

:help
ECHO Entry point for hazijavitorendszer.
ECHO USAGE: ^`%0 [-h^|--help^|-t^|--dry-run^|--test] [file] [file] ... ^`
ECHO.
ECHO Test (or dry run) does the same, with the notable exceptions:
ECHO. * force-rebuilding the docker image
ECHO. * without logging/archiving
ECHO. * without email answering
ECHO. * does not clean up incoming files
