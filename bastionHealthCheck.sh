#!/usr/bin/env bash

if [ "$CONTAINER_TARGET" == "SSH" ] ; 
then
    if [ -z `pgrep sshd` ]
    then
        exit 1
    else
        exit 0
    fi
elif [ "$CONTAINER_TARGET" == "JUPYTER" ]
then
    if [ -z `pgrep jupyter` ]
    then
        exit 1
    else
        exit 0
    fi
else
    echo "Target $CONTAINER_TARGET is not implemented..." 1>&2
    exit 1
fi