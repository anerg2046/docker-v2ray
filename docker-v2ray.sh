#!/bin/sh
SOURCE="$0"
COMMAND="$1"
while [ -h "$SOURCE"  ]; do
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

cd $DIR
cd build

if [ "$COMMAND" == "start" ]; then
    docker-compose -p v2ray up -d
elif [ "$COMMAND" == "stop" ]; then
    docker-compose -p v2ray stop
elif [ "$COMMAND" == "build" ]; then
    docker-compose -p v2ray build --force-rm --no-cache
    docker-compose -p v2ray up -d
    # docker rmi $(docker images | grep "none" | awk '{print $3}')
    docker ps -a | grep "Exited" | awk '{print $1}' | xargs docker stop || :
    docker ps -a | grep "Exited" | awk '{print $1}' | xargs docker rm || :
    docker images | grep "none" | awk '{print $3}' | xargs docker rmi || :
else
    echo "useage: docker-v2ray start|stop|build"
fi
