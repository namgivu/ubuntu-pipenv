#!/usr/bin/env bash
docstring='
                     ./docker-build.sh
    REMOVE_CURRENT=0 ./docker-build.sh  # keep current image; also this is default
    REMOVE_CURRENT=1 ./docker-build.sh  # delete the current image before build

                     ./docker-build.sh | tee ./tmp/log/docker-build.`date +%Y%m%d_%H%M%S_%N`.log

    PYTHON_VERSION=3.7 UBUNTU_VERSION=16.04 REMOVE_CURRENT=1  ./docker-build.sh
    PYTHON_VERSION=3.6 UBUNTU_VERSION=16.04 REMOVE_CURRENT=1  ./docker-build.sh

    PYTHON_VERSION=3.7 UBUNTU_VERSION=18.04 REMOVE_CURRENT=1  ./docker-build.sh
    PYTHON_VERSION=3.6 UBUNTU_VERSION=18.04 REMOVE_CURRENT=1  ./docker-build.sh

    PYTHON_VERSION=3.8 UBUNTU_VERSION=20.04 REMOVE_CURRENT=1  ./docker-build.sh
'

SH=$(cd `dirname $BASH_SOURCE` && pwd)  # SH aka SCRIPT_HOME the containing folder of this script

if [[ -z $UBUNTU_VERSION ]]; then echo 'Param :UBUNTU_VERSION is required in env variable'; exit 1; fi
if [[ -z $PYTHON_VERSION ]]; then echo 'Param :PYTHON_VERSION is required in env variable'; exit 1; fi

 IMAGE_TAG=${UBUNTU_VERSION}-${PYTHON_VERSION}
IMAGE_NAME=${IMAGE_NAME:-"namgivu/ubuntu-pipenv:$IMAGE_TAG"}
#                         registry/repo        :tag

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
    f="$SH/Dockerfile/Dockerfile"

    # create Dockerfile composed from env var
    UBUNTU_VERSION=$UBUNTU_VERSION PYTHON_VERSION=$PYTHON_VERSION envsubst < "$SH/Dockerfile/00.Dockerfile" > $f
    [[ -f $f ]] && echo "Dockerfile created at $f" || (echo "[!] File Dockerfile not found at $f"; exit 1 )
        # print to-be created info
        cat $f | grep 'FROM'             | grep --color=always -E "ubuntu.+$UBUNTU_VERSION"
        cat $f | grep '# install python' | grep --color=always -E "python.+$PYTHON_VERSION"
        yes | read -p "Confirm the above correct please. Any key to continue of Ctrl-C to stop."

    echo
    set -x  # print executed commands ON
        docker build  -t $IMAGE_NAME   --file=$f                $SH
        #             #image tag name  #custom Dockerfile path  #set :pwd folder for Dockerfile
    { set +x; } 2>/dev/null  # print executed commands OFF ref. https://stackoverflow.com/a/19226038/248616

    cp -f $f "$SH/Dockerfile/vault/$UBUNTU_VERSION-$PYTHON_VERSION.Dockerfile"

    # aftermath check
    echo
        docker image ls | grep -iE "$IMAGE_TAG|TAG" --color=always
    echo
        c="my$UBUNTU_VERSION-$PYTHON_VERSION"  # c aka container name
        echo "
DONE
Here are some fancy aftermath commands
    docker run -d --name $c $IMAGE_NAME ; docker ps | grep -E '$c|$IMAGE_NAME' --color=always
        docker exec $c python -V | grep $PYTHON_VERSION                       || echo '[!] Something not right; NOT FOUND python version $PYTHON_VERSION' ;
        docker exec $c cat /etc/os-release | grep -i 'ubuntu $UBUNTU_VERSION' || echo '[!] Something not right; NOT FOUND ubuntu version $PYTHON_VERSION' ;
    docker stop $c; docker rm $c; yes | docker container prune ;
"
set -e  # halt if error OFF
