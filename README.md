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
* `helm/`: simple Helm chart to deploy the app

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

   The probes do
   ```
   curl -s http://localhost:80/healthcheck | grep OK
   ```
   as the probe command.

3. For the same reason, it was impossible to make an ingress.
   I suggest to add at least basic http response (`"HTTP/1.1 200`)
   to the example. If this would the case we could use `Ingress`.
   See, for example, `kube/ingress.yml`.

4. In the provided sample deploy, I use `kubectl port-forward`
   to connect to the service. Another option was to use
   `nodePort` service type.

5. For checking, I used
   * simple self-deployed cluster
   * "Docker desktop for MAC"

   As I have a MAC-based computer, I did not use "minicube", as
   suggested in the task.

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

See `./deploy.sh -h` for help.

## Uninstall

```
bash deploy.sh -n test -u
```

This would
1. removes Deployment and Service from `kube/deploy.yml` from Kubernetes
2. removes namespace if not `default`.

# Deploy with Helm

See [helm install instructions](https://helm.sh/docs/intro/install/)
for the info how to install helm, if needed.

## Install

Change directory to `helm/` and execute:
```
helm install -n test adjust-test-app adjust-test-app --create-namespace
```
This should deploy the app with 3 replicas in the `test` namespace.
Namespace will be created if not exists.

This command also outputs short instructions on how to connect to app with
`cubectl port-forward`.

## Uninstall

```
helm uninstall -n test adjust-test-app
kubectl delete ns test
```
