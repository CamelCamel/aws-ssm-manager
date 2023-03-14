#!/bin/sh

# docker images rm logs

# none image rm
RM_COMMANDS=$(docker images | grep '<none>' | awk '{ print $3 }')

for COMMAND in $RM_COMMANDS
do
        docker rmi $COMMAND
done
