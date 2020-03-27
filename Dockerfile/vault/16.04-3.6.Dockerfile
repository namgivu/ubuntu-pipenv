# ref. ubuntu 16.04 with python https://gist.github.com/monkut/c4c07059444fd06f3f8661e13ccac619
FROM ubuntu:16.04

# change suffix _x to any new value to force a rebuild from this step
RUN echo 200327_x1

# deb package initials
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install -y build-essential

# install python 3.6
RUN apt-get install -y python3.6 python3.6-dev python3-pip python3.6-venv

# make binary python linked to this 3.6
RUN ln -sf /usr/bin/python3.6 /usr/bin/python

# update pip
RUN python -m pip install --upgrade pip
RUN python -m pip install wheel

# install pipenv
RUN python -m pip install pipenv

# set utf8 to fix error when running pipenv > Click will abort further execution because Python 3 was configured to use ASCII as encoding for the environment  # ref. https://github.com/docker-library/python/issues/13#ref-pullrequest-164133459
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# confirm installed softwares
RUN echo `python --version`; \
    echo `python -m pipenv --version`; \
    echo `pipenv --version`;

###endregion installing ubuntu with python


# install fancy utility eg ping, httpie, git, etc - useful for healthcheck
RUN echo; echo 'Installing ping ...';   apt-get update; apt-get install -y apt-utils iputils-ping 1>/dev/null
RUN echo; echo 'Installing httpie - caution: DO NOT apt-get install httpie cause it will install python 2 and overwrite our installed-python ...'; pip install httpie
RUN echo; echo 'Installing git ...';   apt-get update; apt-get install -y git
RUN echo; echo 'Installing nano ...';  apt-get update; apt-get install -y nano

# confirm installed softwares
RUN echo; \
    echo   '-----------------------------------------------------'; \
    echo   'Confirm installed softwares'; \
    printf "`python --version`" ;               echo " at `which python`"; \
    printf "`python -m pipenv --version`";      echo " at `which pipenv`"; \
    printf "`pipenv --version`" ;               echo " at `which pipenv`"; \
    printf "httpie `http --version`";           echo " at `which http`"; \
    echo   `type ping`; \
    printf "`git --version`" ;                  echo " at `which git`"; \
    printf "nano `nano --version | head -n1`" ; echo " at `which nano`"; \
    echo   '-----------------------------------------------------'; \
    :
# create THIS_APP folder
WORKDIR /app

# change suffix _x to any new value to force a rebuild from this step
RUN echo 200327_x2

# pipenv setup
ENV PIPENV_VERBOSITY=-1
    # skip any pipenv warning
ENV PIPENV_VENV_IN_PROJECT=1
    # .venv in same folder
ENV PIPENV_CACHE_DIR=/root/.pipenv/cache
    # cache folder for pipenv so as to pipenv command executed faster

# Default command when running container
CMD tail -F `mktemp`
