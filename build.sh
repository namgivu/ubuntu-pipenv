#!/usr/bin/env bash
docstring='
                     ./build.sh
    REMOVE_CURRENT=0 ./build.sh  # keep current image; also this is default
    REMOVE_CURRENT=1 ./build.sh  # delete the current image before build

                     ./build.sh | tee ./tmp/log/docker-build.`date +%Y%m%d_%H%M%S_%N`.log
'

SH=$(cd `dirname $BASH_SOURCE` && pwd)  # SH aka SCRIPT_HOME the containing folder of this script

IMAGE_NAME='ubuntu-1604-pipenv'

# remove the current as required by param :REMOVE_CURRENT
if [[ $REMOVE_CURRENT == 1 ]]; then
    # if exists, do remove
    if [[ `docker image ls $IMAGE_NAME | grep -c $IMAGE_NAME` == 1 ]]; then
        docker image rm -f $IMAGE_NAME
        yes | docker image prune
    fi
fi

image_already_exist=`docker image ls $IMAGE_NAME | grep -c $IMAGE_NAME`
if [[ $image_already_exist == 1 ]]; then
    docker image ls $IMAGE_NAME | grep --color=always -E "$IMAGE_NAME|TAG"
    echo
    echo "[!] Image $IMAGE_NAME already exists. No more build needed."
    exit
fi

echo; echo "--> Build the docker image $IMAGE_NAME"
set -e  # halt if error ON
    set -x  # print executed commands ON
        docker build  -t $IMAGE_NAME   $SH
        #             #image tag name  #working folder to build
    { set +x; } 2>/dev/null  # print executed commands OFF ref. https://stackoverflow.com/a/19226038/248616

    # aftermath check
    echo
    docker image ls | grep -iE "$IMAGE_NAME|REPOSITORY"
set -e  # halt if error OFF
