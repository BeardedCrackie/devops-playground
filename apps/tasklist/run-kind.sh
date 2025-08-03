#!/bin/bash

if ! pgrep dockerd > /dev/null; then
    echo "Starting Docker..."
    sudo dockerd &
    sleep 5
else
    echo "Docker is already running."
fi

docker compose build

kind load docker-image tasklist-backend:latest
kind load docker-image tasklist-frontend:latest

helm upgrade --install tasklist-app ../../infra/apps/tasklist/helm

kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
