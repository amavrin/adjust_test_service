# Goal

To deploy app from `https://github.com/sawasy/http_server.git`
in Kubernetes.

# Files in this directory

* `README.md`: this file
* `Dockerfile`: config file for building Docker image
* `build_and_push.sh`: script to build an image and push it to repository
* `deploy.sh`: script to deploy the service to Kubernetes
* `http_server.rb.patch`: patch to set io unbuffered
* `kube/deploy.yml`: deployment and service definition

# Notes

1. the test
   [server](https://github.com/sawasy/http_server/blob/main/http_server.rb)
   uses buffered io, so logs are delayed. To overcome it I insert
   ```
   $stdout.sync = true
   ```
   See `http_server.rb.patch`.

2. Despite on talking on port 80, `http_server.rb` does not talk HTTP.
   For example, it does not return http status.
   For this reason I had to use "exec" `readinessProbe`,
   and not `httpGet`.

3. For the same reason, it was impossible to make an ingress.
   I suggest to add at least basic http responce (`"HTTP/1.1 200`)
   to the example. If this would the case we could use `Ingress`.
   See, for example, `kube/ingress.yml`.

4. In the provided sample deploy, I use `kubectl port-forward`
   to connect to the service. Another option was to use
   `nodePort` service type.

# Build an image and push it to Docker hub

```
bash build_and_push.sh
```

This script:
1. clones repository with the simple server
2. applies a patch to server (to make logs appear as soon as request is made)
3. builds docker image
4. pushes it to the Docker hub.

# Deploy to Kubernetes with `kubectl`
## Install

```
bash deploy.sh -n test -P
```

This script basically
1. creates a namespace if not `default` (`test` in this case)
2. applies `kube/deploy.yml` with `Deployment` and `Service`
3. executes `kubectl port-forward` to allow to connect to the service

## Uninstall

```
bash deploy.sh -n test -u
```

This would
1. removes Deployment and Service from `kube/deploy.yml` from Kubernetes
2. removes namespace if not `default`.
