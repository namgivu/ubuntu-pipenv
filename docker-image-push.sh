#!/usr/bin/env bash
docstring='
              ./docker-image-push.sh
              ./docker-image-push.sh | tee ./tmp/log/docker-image-push.`date +%Y%m%d_%H%M%S_%N`
    u=namgivu ./docker-image-push.sh  # docker hub push to user/repo :u
'

SH=$(cd `dirname $BASH_SOURCE` && pwd)  # SH aka SCRIPT_HOME the containing folder of this script

IMAGE_NAME=${IMAGE_NAME:-'namgivu/ubuntu-1604-pipenv'}
IMAGE_TAG=${IMAGE_TAG:-"$IMAGE_NAME:latest"}

echo; echo -e "--> Checking image $IMAGE_TAG exists"
    set -x  # print executed commands ON
        docker image ls $IMAGE_NAME | grep $IMAGE_NAME --color=always
        image_result=`echo $?`
    { set +x; } 2>/dev/null  # print executed commands OFF ref. https://stackoverflow.com/a/19226038/248616

    if [[ $image_result != 0 ]]; then
        echo -e "[!] Docker image $IMAGE_NAME not found - please build one"
        exit
    fi

echo; echo -e "--> Log in docker hub"
set -x  # print executed commands ON
    u=${u:-'namgivu'}
    docker logout  # logout is required to switch login account ref. https://stackoverflow.com/a/41984666/248616
    docker login -u $u
{ set +x; } 2>/dev/null  # print executed commands OFF ref. https://stackoverflow.com/a/19226038/248616


echo; echo -e "--> Tag then push local image to remote image as $IMAGE_TAG"
set -e  # halt if error ON
    set -x  # print executed commands ON
        echo; echo "You may want to switch your repo :private first to get docker push working; then switch it back to :public"; echo

        #           #local image   #remote image
        docker tag  $IMAGE_TAG     "$IMAGE_TAG"
        docker push                "$IMAGE_TAG"

    { set +x; } 2>/dev/null  # print executed commands OFF ref. https://stackoverflow.com/a/19226038/248616
set +e  # halt if error OFF


echo; echo -e "--> Aftermath check"
    echo -e "\
    Docker image pushed as $IMAGE_TAG
                        at https://hub.docker.com/r/$u/$IMAGE_NAME
"
