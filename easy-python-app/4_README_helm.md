# HELM

Helm is a tool for managing Kubernetes packages called `charts`

The Helm client
* written in the Go programming language
* uses the gRPC protocol suite to interact with the Tiller server.

The Tiller server 
* written in Go
* provides a gRPC server to connect with the client
* uses the Kubernetes client library to communicate with Kubernetes
* stores information in ConfigMaps in K8S, it does not need its own database.

## Agenda
1. Using Helm
2. Chart deployments and customizations
3. Working with Charts
4. Developing own charts

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

Charts structure
```
wordpress/
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

### The `chart.yaml` file
```
apiVersion: The chart API version, always "v1" (required)
name: The name of the chart (required)
version: A SemVer 2 version (required)
kubeVersion: A SemVer range of compatible Kubernetes versions (optional)
description: A single-sentence description of this project (optional)
keywords:
  - A list of keywords about this project (optional)
home: The URL of this project's home page (optional)
sources:
  - A list of URLs to source code for this project (optional)
maintainers: # (optional)
  - name: The maintainer's name (required for each maintainer)
    email: The maintainer's email (optional for each maintainer)
    url: A URL for the maintainer (optional for each maintainer)
engine: gotpl # The name of the template engine (optional, defaults to gotpl)
icon: A URL to an SVG or PNG image to be used as an icon (optional).
appVersion: The version of the app that this contains (optional). This needn't be SemVer.
deprecated: Whether this chart is deprecated (optional, boolean)
tillerVersion: The version of Tiller that this chart requires. This should be expressed as a SemVer range: ">2.0.0" (optional)
```

Kubernetes Helm uses version numbers as release markers. Packages in repositories are identified by name plus version

More complex SemVer 2 names are also supported, such as `version: 1.2.3-alpha.1+ef365`. But non-SemVer names are explicitly disallowed by the system.

### Chart LICENSE, README and NODES

Charts can also contain files that describe the installation, configuration, usage and license of a chart

A `LICENSE` is a plain text file containing the license for the char

A `README` for a chart should be formatted in Markdown (README.md), and should generally contain:

* description of the application or service the chart provides
* Any prerequisites or requirements to run the chart
* Descriptions of options in values.yaml and default values
* Any other information that may be relevant to the installation or configuration of the chart

The chart can also contain a short plain text `templates/NOTES.txt` file that will be printed out after installation, and when viewing the status of a release. Is used to display usage notes, next steps, or any other information relevant to a release of the chart. 

For example, instructions could be provided for connecting to a database, or accessing a web UI. Since this file is printed to STDOUT when running helm install or helm status, it is recommended to keep the content brief and point to the README for greater detail.

### Chart dependencies

#### Managing Dependencies with `requirements.yaml`

A `requirements.yaml` file is a simple file for listing your dependencies.

```
dependencies:
  - name: apache
    version: 1.2.3
    repository: http://example.com/charts
  - name: mysql
    version: 3.2.1
    repository: http://another.example.com/charts
```
`helm dependency update <chart-dir>` will use your dependency file to download all the specified charts into your charts/ directory for your

```
charts/
  apache-1.2.3.tgz
  mysql-3.2.1.tgz
```
For more information see
https://helm.sh/docs/developing_charts/#chart-dependencies

#### Managing Dependencies manually via the `charts/` directory

Copy the dependency charts into the `charts/` directory

AGREGATE ALL 3 HELM CHARTS INTO ONE AT THE END OF THE WORKSHOP

## Developing own charts

* The `templates/` directory is for template files
* `Values.yaml` file contains the default values for a chart
* Tiller is responsible for rendering `templates` files with `values` file and sending them to Kubernetes API server
* Default rendering engine is set to `Gotpl`

### PostgreSQL chart

Lets create own lightweight postgresql helm chart
```
cd <LOCAL_PATH>/open-alt209/easy-python-app/database/
mkdir -p chart/postgresql-openalt
cd chart/postgresql-openalt

vim Chart.yaml
vim values.yaml
mkdir templates
```
Copy all yaml files from `k8s-objects` into `templates` dir
```
cp ../../k8s-objects/* templates/
```

#### Built-in Objects

* `Release`: This object describes the release itself
  * `Release.Name`: The release name
  * `Release.Time`: The time of the release
  * `Release.Namespace`: The namespace to be released into 
  * `Release.Revision`: The revision number of this release. It begins at 1 and is incremented for each helm upgrade.
  * `Release.IsUpgrade`: This is set to true if the current operation is an upgrade or rollback.
  * `Release.IsInstall`: This is set to true if the current operation is an install.

* `Values`: Values passed into the template from the values.yaml file and from user-supplied files.

* `Chart`: The contents of the Chart.yaml file. Any data in Chart.yaml will be accessible here. For example {{.Chart.Name}}-{{.Chart.Version}} will print out the mychart-0.1.0.

* `Files`: You can use it to access other files in the chart
  * `Files.Get` is a function for getting a file by name 
  * `Files.GetBytes` is a function for getting the contents of a file as an array of bytes instead of as a string. This is useful for things like images.


## Charts HOOKS

## Charts repository

## Helmfile