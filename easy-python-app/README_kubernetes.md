# Run simple python/react application in kubernetes

## Steps-to-follow
* Install minikube
* Deploy PostgreSQL database into minikube using kubernetes yaml objects
* Build and Deploy backend microservice into minikube using kubernetes yaml objects 
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
https://minikube.sigs.k8s.io/docs/reference/drivers/
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
Verify if minikube started properly

```
kubectl get pods -A

NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-5644d7b6d9-nnw8v           1/1     Running   1          9h
kube-system   coredns-5644d7b6d9-zwrjz           1/1     Running   1          9h
kube-system   etcd-minikube                      1/1     Running   1          9h
kube-system   kube-addon-manager-minikube        1/1     Running   1          9h
kube-system   kube-apiserver-minikube            1/1     Running   1          9h
kube-system   kube-controller-manager-minikube   1/1     Running   1          9h
kube-system   kube-proxy-vddfb                   1/1     Running   1          9h
kube-system   kube-scheduler-minikube            1/1     Running   1          9h
kube-system   storage-provisioner                1/1     Running   1          9h
```

### 5. Configure local docker cli to connect to minikube docker cli

```
minikube docker-env

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.39.93:2376"
export DOCKER_CERT_PATH="/home/jvojtek/.minikube/certs"
# Run this command to configure your shell:
# eval $(minikube docker-env)
```
Run `eval $(minikube docker-env)` and add this command into your `bash_profile`


## Deploy Postgres Database into minikube

```
              +--------------------------------------------------------------------------+
              |DATABASE   TIER                                                           |
              |     +-----------------------------+  +----------------------------+      |
              |     |SERVICE                      |  |INGRESS                     |      |
              |     |                             |  |                            |      |
              |     |                             |  |                            |      |
              |     |                             |  |                            |      |
              |     +-----------------------------+  +----------------------------+      |
              |     +-----------------------------+                                      |
              |     |CONFIGMAP                    |                                      |
              |     |                             |                                      |
              |     |                             |                                      |
              |     |                             |                                      |
              |     +-----------------------------+                                      |
              |     +-----------------------------+  +----------------------------+      |
              |     |SECRET                       |  |PERSISTENT VOLUME           |      |
              |     |                             |  |                            |      |
              |     |                             |  |                            |      |
              |     |                             |  |                            |      |
              |     +-----------------------------+  +----------------------------+      |
              |     +----------------------------------------------------+               |
              |     |DEPLOYMENT                                          |               |
              |     |  +--------------------------------------+          |               |
              |     |  |POD                                   |          |               |
              |     |  | +-----------+                        |          |               |
              |     |  | | Container |                        |          |               |
              |     |  | |           |                        |          |               |
              |     |  | +-----------+                        |          |               |
              |     |  +--------------------------------------+          |               |
              |     +----------------------------------------------------+               |
              |                                                                          |
              +--------------------------------------------------------------------------+

```
Deploy PostgreSQL database into minikube using prepared kubernetes yaml objects
```
kubectl apply -f <LOCAL_PATH>/open-alt209/easy-python-app/database/k8s-objects/*
```
Connect to deployed PostgreSQL instance and create database and user for our application

Run `minikube ip` to get minikube vm IP
```
$ minikube ip
192.168.39.93
```
Test connection to PostgreSQL
```
$ telnet 192.168.39.93 30543
Trying 192.168.39.93...
Connected to 192.168.39.93.
Escape character is '^]'.
```
Connect to database
```
psql --host=192.168.39.93 --port=30543 -U postgres
```
Run
```
CREATE DATABASE  microservice;
CREATE USER micro WITH ENCRYPTED PASSWORD 'password'; 
GRANT ALL PRIVILEGES ON DATABASE microservice TO micro;
ALTER DATABASE microservice OWNER TO micro;
```

## Build and Deploy backend microservice into minikube using kubernetes yaml objects 

Switch to project dir
```
cd <LOCAL_PATH>/open-alt209/easy-python-app/backend/
```
Build backend docker image from Dockerfile
```
docker build -t backend-microservice:0.0.1 .
```
Check newly build backend microservice docker image
```
docker images
```
Deploy backend microservice into minikube using prepared kubernetes yaml objects
```
kubectl apply -f <LOCAL_PATH>/open-alt209/easy-python-app/backend/k8s-objects/*
```
Verify backend microservice is running properly 
```
wget -O http://192.168.39.93:30800/api/isalive
wget -O http://192.168.39.93:30800/api/saveip
wget -O http://192.168.39.93:30800/api/getallips
```



Enable helm-tiller addon in minikube
```
minikube addons enable helm-tiller
```