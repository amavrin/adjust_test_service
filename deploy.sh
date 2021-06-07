#!/bin/bash

log() {
    echo "$@"
}

usage() {
    log "usage:"
    log "$0 -h: help"
    log "$0 -n NAMESPACE: create a given namespace and deploy app"
    log "$0 -u -n NAMESPACE: uninstall app and remove a namespace"
    log
    log "Additional options:"
    log " -P: add port-forward after the deploy ($0 will continue running)"
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

port_forward() {
    kubectl wait \
        --for=condition=available \
        --timeout=600s deployment/adjust-test-app -n test
    kubectl port-forward \
        -n "$NAMESPACE" \
        service/adjust-test-app \
        8080:80
}

deploy_app() {
    kubectl apply -f kube/deploy.yml --namespace="$NAMESPACE"
}

uninstall_app() {
    kubectl delete -f kube/deploy.yml --namespace="$NAMESPACE"
}

ACTION="deploy"
NAMESPACE="default"
PORT_FORWARD="no"

while getopts "hPun:" opt
do
    case $opt in
        n) NAMESPACE="$OPTARG"
           ;;
        u) ACTION="uninstall"
           ;;
        P) PORT_FORWARD="yes"
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
    if [[ "$PORT_FORWARD" == "yes" ]]
    then
        port_forward
    fi
elif [[ "$ACTION" == "uninstall" ]]
then
    uninstall_app
    delete_namespace "$NAMESPACE"
fi
