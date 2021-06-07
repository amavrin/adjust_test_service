#!/bin/bash

set -ue

APP_REPO=https://github.com/sawasy/http_server.git
APP_DOCKER_REPO=alexeymavrin/adjust-test-app
APP_IAMGE_TAG="$APP_DOCKER_REPO":latest

log() {
    echo "$@"
}

clean_up() {
    rm -rf "http_server"
}

clone_repo() {
    git clone "$APP_REPO"
}

apply_patch() {
    log "Applying patch to disable stdout buffering..."
    patch -u http_server/http_server.rb -i http_server.rb.patch
}

build_docker_image() {
    docker build -t "$APP_IAMGE_TAG" .
}

push_docker_image() {
    docker push "$APP_IAMGE_TAG"
}

clean_up
clone_repo
apply_patch
build_docker_image
push_docker_image
