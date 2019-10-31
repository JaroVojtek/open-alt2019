# HELM

## Agenda
1. Using Helm


## Using helm
## Chart deployments and customizations
## Working with Charts
## Creating own Charts

### Deploy Nginx-controller using helm into minikube to leverage ingress objects

![Alt text](../images/nginx-controller.png?raw=true "Nginx controller")

Enable helm-tiller addon in minikube
```
minikube addons enable helm-tiller
```

![Alt text](../images/helm-workflow.png?raw=true "Helm Workflow")

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
To see DELETED charts
```
helm list -a
```
Rollback deleted chart
```
$ helm rollback ingress 1

Rollback was a success.
```
To uninstall a release absolutely, use the `helm delete --purge` command:
```
helm delete ingress --purge
```
To list configured charts repositories for helm client run
```
$ helm repo list
NAME                    URL                                                                      
stable                  https://kubernetes-charts.storage.googleapis.com
```
To add new helm repository for helm client
```
helm repo add <repository_name> <repository_url>
```
To search for available charts within configured repositories run `helm search <chart_name>`
```
$ helm search nginx-ingress   

NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                                 
stable/nginx-ingress                    1.24.4          0.26.1          An nginx Ingress controller that uses ConfigMap to store ...
stable/nginx-lego                       0.3.1                           Chart for 
nginx-ingress-controller and kube-lego     
```
To see installed status of chart release
```
helm status ingress
```
## Chart deployments and customizations 

A chart is organized as a collection of files inside of a directory. The directory name is the name of the chart (without versioning information). Thus, a chart describing Nginx-ingress controller would be stored in the `nginx-ingress/` directory.

```
<chart_name_dir>/
  Chart.yaml          # A YAML file containing information about the chart
  LICENSE             # OPTIONAL: A plain text file containing the license for the chart
  README.md           # OPTIONAL: A human-readable README file
  requirements.yaml   # OPTIONAL: A YAML file listing dependencies for the chart
  values.yaml         # The default configuration values for this chart
  charts/             # A directory containing any charts upon which this chart depends.
  templates/          # A directory of templates that, when combined with values,
                      # will generate valid Kubernetes manifest files.
  templates/NOTES.txt # OPTIONAL: A plain text file containing short usage notes
```
#### Customizing the Chart Before Installing

Chart is installed using default values in `values.yaml` of the that chart

To inspect possible configuration which chart provides either run
```
helm inspect values stable/nginx-ingress
```
or `fetch` entire chart from chart repository and explore
```
helm fetch --untar stable/nginx-ingress
```
You can then override any of these settings in a YAML formatted file, and then pass that file during installation.

```
$ cat << EOF > own_values.yaml
controller:
  service:
    type: NodePort
    nodePorts:
      http: 30444
EOF

$ helm install -f own_values.yaml stable/nginx-ingress
```
It is possible to change values for chart deployment via `--set` flag of helm client like we did it at the begining of this section
```
helm install \
--name ingress \
--set controller.service.type=NodePort \
--set controller.service.nodePorts.http=30444 \
stable/nginx-ingress
```
To set `extraEnv` vars for nginx-ingress 
```
helm install --name ingress-test \
--set controller.extraEnvs[0].name="IS_TRUE" \
--set controller.extraEnvs[0].valueFrom.secretKeyRef.name="secret-env" \
--set controller.extraEnvs[0].valueFrom.secretKeyRef.key="IS_TRUE_KEY" \
stable/nginx-ingress
```
to set `metrics.service.annotations` for nginx-ingress 
```
helm install --name ingress-test \
--set-string controller.metrics.service.annotations."prometheus\.io\/scrape"=true \
stable/nginx-ingress
```
To see applied custom configuration values
```
$ helm get values ingress-test

controller:
  metrics:
    service:
      annotations:
        prometheus.io/scrape: "true"
```

To `--set` more various types of values via helm client see documentatio below
https://helm.sh/docs/using_helm/#the-format-and-limitations-of-set

It is possible to install chart in other ways also
```
helm install foo-0.1.1.tgz                              # A local chart archive
helm install path/to/foo                                # An unpacked chart directory
helm install https://example.com/charts/foo-1.2.3.tgz   # A full URL 
```
#### Upgrading released chart
```
helm search nginx-ingress -l
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                                 
stable/nginx-ingress         1.24.4          0.26.1          An nginx Ingress controller that uses ConfigMap to store ...
stable/nginx-ingress         1.24.3          0.25.0          An nginx Ingress controller that uses ConfigMap to store ...
.
.
.
```
Install lower version of nginx-ingress chart
```
helm install --name ingress-test \
--version 1.24.3 \
--set-string controller.metrics.service.annotations."prometheus\.io\/scrape"=true \
stable/nginx-ingress
```
To upgrade released chart with new version of chart simply run
```
helm upgrade ingress stable/nginx-ingress
```
If new version of the chart is available, the upgrade will take efect

To upgrade configuration values of latest release
```
$ cat << EOF > upgrade_values.yaml
controller:
  service:
    type: NodePort
    nodePorts:
      http: 30555
EOF
```
```
helm upgrade -f upgrade_values.yaml ingress-test stable/nginx-ingress
```
```
$ helm get values ingress-test

controller:
  service:
    nodePorts:
      http: 30555
    type: NodePort
```
NOTE: Annotation was removed from release at it was not preset in `upgrade_values.yaml`

## Working with Charts


## Creating own charts