nextcloud upgrade
=================

..  code::bash

    cd /root
    update build_nc.sh tag to nc:16-fpm-alpine
    update nc/Dockerfile to pull nextcloud:16-fpm-alpine

    update /var/opt/nc/docker-compose.yaml
    app:
        image: nc:16-fpm-alpine


    docker-compose exec -u www-data app /bin/ash
    ./occ maintenance:mode --on
    ./occ upgrade
    ./occ maintenance:mode --off

    login
    update apps and enable groupfolders
