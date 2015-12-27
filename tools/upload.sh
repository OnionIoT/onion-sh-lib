#!/bin/sh

# check for argument
if [ "$1" == "" ]
then
    echo "ERROR: expecting Omega hex code as argument!"
    echo "$0 <hex code>"
    exit
fi

localPath="lib.sh"
remotePath="/usr/lib/onion/lib.sh"

cmd="rsync -va --progress $localPath root@omega-$1.local:$remotePath"
echo "$cmd"
eval "$cmd"

