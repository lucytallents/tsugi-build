A Set of Docker Images for Tsugi
--------------------------------

These are some docker images for Tsugi.  They live in a hierarchy so you can make
everything from a developer environment on localhost all the way up to an AWS image
that uses Aurora, DynamoDB, and EFS.  Or the nightly servers somewhere in-between.


For now we build three images - the `tsugi_dev:latest` image is a developer instance
with all of the pieces running on one server.

    $ bash build.sh    (Will take some time)

    $ docker images    (make sure they all build)

    REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
    tsugi_dev       latest    7705578909c8   14 seconds ago   431MB
    tsugi_mariadb   latest    57f9bb037655   16 seconds ago   416MB
    tsugi_prod      latest    f484f91386e1   32 seconds ago   65.6MB
    tsugi_base      latest    7308bd1b0fe3   33 seconds ago   65.6MB
    tsugi_ubuntu    latest    7308bd1b0fe3   33 seconds ago   65.6MB

    $ docker run -p 8080:80 -e TSUGI_SERVICENAME=TSFUN -e MYSQL_ROOT_PASSWORD=secret --name tsugi -dit tsugi_dev:latest

Navigate to http://localhost:8080/

To log in and look around, use:

    $ docker exec -it tsugi bash
    root@73c370052747:/var/www/html/tsugi/admin# 

To attach and watch the tail logs:

    $ docker attach 73c...e21
    root@73c370052747:/var/www/html/tsugi/admin# 

To detatch press CTRL-p and CRTL-q

To see the entire startup log:

    $ docker logs 73c...e21

Cleaning up

    docker stop 73c3700527470dc10f58b3e6b2a8837b22d3d2b6790cb70346b02a8a64d3ce21
    docker container prune
    docker image prune

Big clean up:

    docker rmi $(docker images -a -q)
    docker image prune

To build one image

    docker build --tag tsugi_base .

To test the ami scripts in a docker container so you can start over and over:

    docker run -p 8080:80 -p 3306:3306 --name tsugi -dit ubuntu:20.04
    docker exec -it tsugi bash

Then in the docker:

    apt update
    apt-get install -y git
    apt-get install -y vim
    git config user.name "Charles R. Severance"
    git config user.email "csev@umich.edu"

    cd /root
    git clone https://github.com/tsugiproject/docker-php.git

    cd docker-php
    bash ami/build.sh 

This does all of the docker stuff.  Then to bring it up / configure it:

    cp ami-env-dist.sh  ami-env.sh
    bash /usr/local/bin/tsugi-dev-startup.sh return


Debugging commands
------------------

    service --status-all

