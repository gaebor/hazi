
ECHO OFF
ECHO [BUILD]
docker build -f Dockerfile -t hazicp . > nul
IF %ERRORLEVEL% NEQ 0 ( GOTO:eof )

ECHO [CREATE]
docker container create --memory 100m --network bridge --cap-add NET_ADMIN hazicp > temp.txt
IF %ERRORLEVEL% NEQ 0 ( GOTO:eof )

SET /P _container=<temp.txt

ECHO [COPY]
docker cp solution/info %_container%:/home/dummy/
FOR %%G IN (%*) DO ( docker cp %%G %_container%:/home/dummy/ )

ECHO [RUN]
docker start -i %_container%

ECHO [DELETE]
docker rm %_container% > nul
