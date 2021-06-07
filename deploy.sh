#!/bin/bash

log() {
    echo "$@"
}

usage() {
    log "usage:"
    log "$0 -h: help"
    log "$0 -n NAMESPACE: create a given namespace and deploy app"
    log "$0 -u -n NAMESPACE: uninstall app and remove a namespace"
}

create_namespace() {
    if [[ "$NAMESPACE" != "default" ]]
    then
        kubectl create namespace "$NAMESPACE"
    fi
}

delete_namespace() {
    if [[ "$NAMESPACE" != "default" ]]
    then
        kubectl delete namespace "$NAMESPACE"
    fi
}

deploy_app() {
    kubectl apply -f kube/deploy.yml --namespace="$NAMESPACE"
}

uninstall_app() {
    kubectl delete -f kube/deploy.yml --namespace="$NAMESPACE"
}

ACTION="deploy"
NAMESPACE="default"

while getopts "hun:" opt
do
    case $opt in
        n) NAMESPACE="$OPTARG"
           ;;
        u) ACTION="uninstall"
           ;;
        h) usage
           exit 0
           ;;
        *) usage
           exit 1
           ;;
    esac
done

if [[ "$ACTION" == "deploy" ]]
then
    create_namespace "$NAMESPACE"
    deploy_app
elif [[ "$ACTION" == "uninstall" ]]
then
    uninstall_app
    delete_namespace "$NAMESPACE"
fi
