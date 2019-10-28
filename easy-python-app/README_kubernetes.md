# Run simple python/react application in kubernetes

## Steps-to-follow
* Install minikube
* Build backend docker image from Dockerfile
* Run backend microservice in docker container 
* Build frontend docker image from Dockerfile
* Run frontend microservice in docker container

## Install minikube
Switch to `root`

### 1. Download `kubectl`

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

Make it executable
```
chmod +x ./kubectl
```
Move the binary in to your PATH.
```
sudo mv ./kubectl /usr/local/bin/kubectl
```
Test to ensure the version you installed is up-to-date:
```
kubectl version
```

### 2.Install Hypervisor (KVM, VirtualBox, etc.)
### 3.Install minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
```
Here’s an easy way to add the Minikube executable to your path:
```
sudo mv ./minikube /usr/local/bin/minikube
```
### 4. Start minikube
https://minikube.sigs.k8s.io/docs/start/

Switch back to normal non-root system user

```
minikube start
```
