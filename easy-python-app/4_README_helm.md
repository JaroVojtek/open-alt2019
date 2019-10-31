# HELM

## Agenda
1. Using Helm


## Using helm

### Deploy Nginx-controller using helm into minikube to leverage ingress objects

![Alt text](../nginx-controller.png?raw=true "Nginx controller")

Enable helm-tiller addon in minikube
```
minikube addons enable helm-tiller
```

![Alt text](../helm-workflow.png?raw=true "Helm Workflow")

Deploy nginx-controller into minikube using helm
```
helm install \
--name ingress \
--set controller.service.type=NodePort \
--set controller.service.nodePorts.http=30444 \
stable/nginx-ingress
```
Try backend and frontend 
```
wget -O - http://minikube:30444/api/isalive
wget -O - http://minikube:30444/app/
```

Check installed helm charts and their status
```
helm list

NAME    REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
ingress 1               Thu Oct 31 10:57:41 2019        DEPLOYED        nginx-ingress-1.24.4    0.26.1          default  
```

Whenever you install a chart, a new release is created. So one chart can be installed multiple times into the same cluster. And each can be independently managed and upgraded.

To uninstall chart from Kubernetes cluster
```
$ helm delete ingress

release "ingress" deleted
```
Rollback deleted chart
```
$ helm rollback ingress 1

Rollback was a success.
```
To uninstall a release absolutely, use the `helm delete` command:
```
helm delete ingress --purge
```
