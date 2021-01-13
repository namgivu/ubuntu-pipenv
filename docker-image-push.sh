#!/usr/bin/env bash
docstring='
              ./docker-image-push.sh
              ./docker-image-push.sh | tee ./tmp/docker-image-push.`date +%Y%m%d_%H%M%S_%N.log`
    u=namgivu ./docker-image-push.sh  # docker hub push to user/repo :u

    PYTHON_VERSION=3.7 u=namgivu UBUNTU_VERSION=16.04 ./docker-image-push.sh
    PYTHON_VERSION=3.6 u=namgivu UBUNTU_VERSION=16.04 ./docker-image-push.sh

    PYTHON_VERSION=3.7 u=namgivu UBUNTU_VERSION=18.04 ./docker-image-push.sh
    PYTHON_VERSION=3.8 u=namgivu UBUNTU_VERSION=18.04 ./docker-image-push.sh

    PYTHON_VERSION=3.8 u=namgivu UBUNTU_VERSION=20.04 ./docker-image-push.sh
'

SH=$(cd `dirname $BASH_SOURCE` && pwd)  # SH aka SCRIPT_HOME the containing folder of this script

if [[ -z $UBUNTU_VERSION ]]; then echo 'Param :UBUNTU_VERSION is required in env variable'; exit 1; fi
if [[ -z $PYTHON_VERSION ]]; then echo 'Param :PYTHON_VERSION is required in env variable'; exit 1; fi


IMAGE_REG_REPO='namgivu/ubuntu-pipenv'
     IMAGE_TAG=${IMAGE_TAG:-"$UBUNTU_VERSION-$PYTHON_VERSION"}
    IMAGE_NAME=${IMAGE_NAME:-"$IMAGE_REG_REPO:$IMAGE_TAG"}
#eg                     namgivu/ubuntu-pipenv:16.04-3.7

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
                        to https://hub.docker.com/r/$IMAGE_REG_REPO
"
