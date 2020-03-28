# public built image at docker hub
at https://hub.docker.com/r/namgivu/ubuntu-pipenv

# target image name
namgivu/ubuntu-pipenv:UU-PP

UU = 16.04 or 18.04

PP = 3.6 or 3.7

```
python   ubuntu   image name                        docker hub   Dockerfile
------   ------   -------------------------------   ----------   ---------------------------
3.6      16.04    namgivu/ubuntu-pipenv:16.04-3.6   docker hub   ./Dockerfile/vault/16.04-3.6.Dockerfile
3.6      18.04    namgivu/ubuntu-pipenv:18.04-3.6   docker hub   TODO
3.7      16.04    namgivu/ubuntu-pipenv:16.04-3.7   docker hub   ./Dockerfile/vault/16.04-3.7.Dockerfile 
3.7      18.04    namgivu/ubuntu-pipenv:18.04-3.7   docker hub   TODO
```


# info 0th

ubuntu with python docker image

ref. https://gist.github.com/monkut/c4c07059444fd06f3f8661e13ccac619


# TODO 
TODO need test/docker-run.sh using the image

TODO need test/docker-compose.sh using the image
