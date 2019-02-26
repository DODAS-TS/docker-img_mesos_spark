#!/usr/bin/env bash

if [ "$CONTAINER_TARGET" == "SSH" ] ; 
then
    if [ -z `pgrep sshd` ]
    then
        echo 1
    else
        echo 0
    fi
elif [ "$CONTAINER_TARGET" == "JUPYTER" ]
then
    if [ -z `pgrep python` ]
    then
        echo 1
    else
        echo 0
    fi
else
    echo "Target $CONTAINER_TARGET is not implemented..." 1>&2
    echo 1
fi