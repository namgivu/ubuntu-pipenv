#!/usr/bin/env bash
docstring='
              ./docker-image-push.sh
              ./docker-image-push.sh | tee ./tmp/log/docker-image-push.`date +%Y%m%d_%H%M%S_%N`
    u=namgivu ./docker-image-push.sh  # docker hub push to user/repo :u

    u=namgivu UBUNTU_VERSION=16.04 PYTHON_VERSION=3.7 ./docker-image-push.sh
'

SH=$(cd `dirname $BASH_SOURCE` && pwd)  # SH aka SCRIPT_HOME the containing folder of this script

if [[ -z $UBUNTU_VERSION ]]; then echo 'Param :UBUNTU_VERSION is required in env variable'; exit 1; fi
if [[ -z $PYTHON_VERSION ]]; then echo 'Param :PYTHON_VERSION is required in env variable'; exit 1; fi


 IMAGE_TAG=${IMAGE_TAG:-"$UBUNTU_VERSION-$PYTHON_VERSION"}
IMAGE_NAME=${IMAGE_NAME:-"namgivu/ubuntu-pipenv:$IMAGE_TAG"}

echo; echo -e "--> Checking image $IMAGE_TAG exists"
    set -x  # print executed commands ON
        docker image ls | grep $IMAGE_TAG --color=always
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
        docker tag  $IMAGE_NAME    $IMAGE_NAME
        docker push                $IMAGE_NAME

    { set +x; } 2>/dev/null  # print executed commands OFF ref. https://stackoverflow.com/a/19226038/248616
set +e  # halt if error OFF


echo; echo -e "--> Aftermath check"
    echo -e "\
    Docker image pushed as $IMAGE_TAG
                        at https://hub.docker.com/r/$u/$IMAGE_NAME
"
