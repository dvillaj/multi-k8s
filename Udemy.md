# Deploy complex project in Kubernetes

## Architecture

![](images/Architecture.png)


## Applying multiple files in Kubernetes

First delete old objects

```
$ kubectl get deployments
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
client-deployment   1/1     1            1           23h

$ kubectl delete deployment client-deployment
deployment.apps "client-deployment" deleted

$ kubectl get deployments
No resources found in default namespace.

$ kubectl get services
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
client-node-port   NodePort    10.103.113.235   <none>        3050:31515/TCP   3d20h
kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP          4d22h

$ kubectl delete service client-node-port
service "client-node-port" deleted

$ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   4d22h

```

- Apply all config files at the same time
```
$ cd projects/complexk8s/

$ kubectl apply -f k8s
service/client-cluster-ip-service created
deployment.apps/client-deployment created
service/server-cluster-ip-service created
deployment.apps/server-deployment created

$ kubectl get deployments
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
client-deployment   0/3     3            0           0s
server-deployment   0/3     3            0           0s

$ kubectl get pods
NAME                                 READY   STATUS    RESTARTS   AGE
client-deployment-5f9f5b6bfb-l8r22   1/1     Running   0          104s
client-deployment-5f9f5b6bfb-p2ll6   1/1     Running   0          104s
client-deployment-5f9f5b6bfb-tcxf5   1/1     Running   0          104s
server-deployment-69645f89d9-8bmv7   1/1     Running   0          104s
server-deployment-69645f89d9-gtqbp   1/1     Running   0          104s
server-deployment-69645f89d9-xjb6k   1/1     Running   0          104s

$ kubectl get services
NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
client-cluster-ip-service   ClusterIP   10.100.180.157   <none>        3000/TCP   2m4s
kubernetes                  ClusterIP   10.96.0.1        <none>        443/TCP    4d22h
server-cluster-ip-service   ClusterIP   10.109.94.11     <none>        5000/TCP   2m4s

```

## Reapplying a Batch of config files

```
$ kubectl apply -f k8s
service/client-cluster-ip-service unchanged
deployment.apps/client-deployment unchanged
service/server-cluster-ip-service unchanged
deployment.apps/server-deployment unchanged
deployment.apps/worker-deployment created

$ kubectl get deployments
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
client-deployment   3/3     3            3           9m13s
server-deployment   3/3     3            3           9m13s
worker-deployment   1/1     1            1           30s

$ kubectl get pods
NAME                                 READY   STATUS    RESTARTS   AGE
client-deployment-5f9f5b6bfb-l8r22   1/1     Running   0          9m41s
client-deployment-5f9f5b6bfb-p2ll6   1/1     Running   0          9m41s
client-deployment-5f9f5b6bfb-tcxf5   1/1     Running   0          9m41s
server-deployment-69645f89d9-8bmv7   1/1     Running   0          9m41s
server-deployment-69645f89d9-gtqbp   1/1     Running   0          9m41s
server-deployment-69645f89d9-xjb6k   1/1     Running   0          9m41s
worker-deployment-7f746f957d-n7fr9   1/1     Running   0          58s

$ kubectl logs server-deployment-69645f89d9-8bmv7

> @ start /app
> node index.js

Listening
Error: connect ECONNREFUSED 127.0.0.1:5432
    at TCPConnectWrap.afterConnect [as oncomplete] (net.js:1137:16) {
  errno: -111,
  code: 'ECONNREFUSED',
  syscall: 'connect',
  address: '127.0.0.1',
  port: 5432
}

```

## Create secret

```
$ kubectl create secret generic pgpassword --from-literal PGPASSWORD=12345asfd
secret/pgpassword created
```

## Applying PVC and variables

```
$ kubectl apply -f k8s
service/client-cluster-ip-service created
deployment.apps/client-deployment configured
persistentvolumeclaim/database-persistent-volume-claim created
service/postgres-cluster-ip-service created
deployment.apps/postgres-deployment created
service/redis-cluster-ip-service created
deployment.apps/redis-deployment created
service/server-cluster-ip-service created
deployment.apps/server-deployment created
deployment.apps/worker-deployment created

$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
client-deployment-5f9f5b6bfb-7d6tt    1/1     Running   0          2m17s
client-deployment-5f9f5b6bfb-cg8x5    1/1     Running   0          2m39s
client-deployment-5f9f5b6bfb-x7vfh    1/1     Running   0          12s
postgres-deployment-78bc4cf96-5m2gf   1/1     Running   0          2m39s
redis-deployment-5f458546b8-mjm6d     1/1     Running   0          2m39s
server-deployment-77b8658699-62gpz    1/1     Running   0          2m38s
server-deployment-77b8658699-gp928    1/1     Running   0          2m38s
server-deployment-77b8658699-kw7g8    1/1     Running   0          2m38s
worker-deployment-75d8f9659c-xdxsg    1/1     Running   0          2m38s

$ kubectl get services
NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
client-cluster-ip-service     ClusterIP   10.101.175.68    <none>        3000/TCP   5m50s
kubernetes                    ClusterIP   10.96.0.1        <none>        443/TCP    41h
postgres-cluster-ip-service   ClusterIP   10.96.165.77     <none>        5432/TCP   5m50s
redis-cluster-ip-service      ClusterIP   10.98.239.67     <none>        6379/TCP   5m50s
server-cluster-ip-service     ClusterIP   10.101.177.194   <none>        5000/TCP   5m50s

$ kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
client-deployment     3/3     3            3           25h
postgres-deployment   1/1     1            1           3m2s
redis-deployment      1/1     1            1           3m2s
server-deployment     3/3     3            3           3m2s
worker-deployment     1/1     1            1           3m1s

$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-gqcll   kubernetes.io/service-account-token   3      41h
pgpassword            Opaque             

$ kubectl get pvc
NAME                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
database-persistent-volume-claim   Bound    pvc-805c5848-ad19-4e60-815c-11bb31db3bd6   1Gi        RWO            standard       3m45s

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                      STORAGECLASS   REASON   AGE
pvc-805c5848-ad19-4e60-815c-11bb31db3bd6   1Gi        RWO            Delete           Bound    default/database-persistent-volume-claim   standard                4m4s
```

## Ingress Nginx

```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml

namespace/ingress-nginx created
configmap/nginx-configuration created
configmap/tcp-services created
configmap/udp-services created
serviceaccount/nginx-ingress-serviceaccount created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-role created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-role-nisa-binding created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-clusterrole-nisa-binding created
deployment.apps/nginx-ingress-controller created
limitrange/ingress-nginx created

$ minikube addons enable ingress
* The 'ingress' addon is enabled

$ kubectl apply -f k8s
service/client-cluster-ip-service unchanged
deployment.apps/client-deployment unchanged
persistentvolumeclaim/database-persistent-volume-claim unchanged
persistentvolume/database-persistent-volume unchanged
ingress.extensions/ingress-service created
service/postgres-cluster-ip-service unchanged
deployment.apps/postgres-deployment unchanged
service/redis-cluster-ip-service unchanged
deployment.apps/redis-deployment unchanged
service/server-cluster-ip-service unchanged
deployment.apps/server-deployment unchanged
deployment.apps/worker-deployment unchanged

$ kubectl get services
NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
client-cluster-ip-service     ClusterIP   10.111.244.175   <none>        3000/TCP   62m
kubernetes                    ClusterIP   10.96.0.1        <none>        443/TCP    80m
postgres-cluster-ip-service   ClusterIP   10.101.216.81    <none>        5432/TCP   62m
redis-cluster-ip-service      ClusterIP   10.109.172.172   <none>        6379/TCP   62m
server-cluster-ip-service     ClusterIP   10.98.150.186    <none>        5000/TCP   62m
```
# Kubernetes Production Deployment

## Create a GitHub Repository

```
$ git init
Initialized empty Git repository in /home/vagrant/projects/complexk8s/.git/
$ git add .
$ git commit -m "first commit"
git remote add origin git@github.com[master (root-commit) 6f1d799] first commit
:dvilla 43 files changed, 3445 insertions(+)
j create mode 100644 .gitignore
 create mode 100644 Readme.md
 create mode 100644 client/.gitignore
 create mode 100644 client/Dockerfile
 create mode 100644 client/Dockerfile.dev
 create mode 100644 client/README.md
 create mode 100644 client/nginx/default.conf
 create mode 100644 client/package.json
 create mode 100644 client/public/favicon.ico
 create mode 100644 client/public/index.html
 create mode 100644 client/public/manifest.json
 create mode 100644 client/src/App.css
 create mode 100644 client/src/App.js
 create mode 100644 client/src/App.test.js
 create mode 100644 client/src/Fib.js
 create mode 100644 client/src/OtherPage.js
 create mode 100644 client/src/index.css
 create mode 100644 client/src/index.js
 create mode 100644 client/src/logo.svg
 create mode 100644 client/src/registerServiceWorker.js
 create mode 100644 images/Architecture.png
 create mode 100644 k8s/client-cluster-ip-service.yaml
 create mode 100644 k8s/client-deployment.yaml
 create mode 100644 k8s/database-persistent-volume-claim.yaml
 create mode 100644 k8s/database-persistent-volume.yamlm
 create mode 100644 k8s/ingress-service.yaml
 create mode 100644 k8s/postgres-cluster-ip-service.yaml
 create mode 100644 k8s/postgres-deployment.yaml
 create mode 100644 k8s/redis-cluster-ip-service.yaml
 create mode 100644 k8s/redis-deployment.yaml
 create mode 100644 k8s/server-cluster-ip-service.yaml
 create mode 100644 k8s/server-deployment.yaml
 create mode 100644 k8s/worker-deployment.yaml
 create mode 100644 server/Dockerfile
 create mode 100644 server/Dockerfile.dev
 create mode 100644 server/index.js
 create mode 100644 server/keys.js
 create mode 100644 server/package.json
 create mode 100644 worker/Dockerfile
 create mode 100644 worker/Dockerfile.dev
 create mode 100644 worker/index.js
 create mode 100644 worker/keys.js
 create mode 100644 worker/package.json
$ git remote add origin git@github.com:dvillaj/multi-k8s.git
$ git push -u origin master
Counting objects: 50, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (48/48), done.
Writing objects: 100% (50/50), 170.38 KiB | 1.67 MiB/s, done.
Total 50 (delta 10), reused 0 (delta 0)
remote: Resolving deltas: 100% (10/10), done.
To github.com:dvillaj/multi-k8s.git
 * [new branch]      master -> master
Branch 'master' set up to track remote branch 'master' from 'origin'.
$ git remote -v
origin  git@github.com:dvillaj/multi-k8s.git (fetch)
origin  git@github.com:dvillaj/multi-k8s.git (push)
```

## Travis CLI

https://github.com/travis-ci/travis.rb

- cd ~/projects/complexk8s/
- docker run -it -v $(pwd):/app ruby:2.3 sh
- gem install travis
- travis login
- cd /app
- travis encrypt-file service-account.json -r dvillaj/multi-k8s
- rm service-account.json
- exit


```
$ cd ~/projects/complexk8s/
$ docker run -it -v $(pwd):/app ruby:2.3 sh
# gem install travis
Fetching backports-3.16.1.gem
Fetching net-http-persistent-2.9.4.gem
Fetching multipart-post-2.1.1.gem
Fetching faraday-0.17.3.gem
Fetching faraday_middleware-0.14.0.gem
Fetching highline-1.7.10.gem
Fetching launchy-2.4.3.gem
Fetching net-http-pipeline-1.0.1.gem
Fetching multi_json-1.14.1.gem
Fetching addressable-2.4.0.gem
Fetching gh-0.15.1.gem
Fetching ethon-0.12.0.gem
Fetching typhoeus-0.8.0.gem
Fetching pusher-client-0.6.2.gem
Fetching ffi-1.12.2.gem
Fetching websocket-1.2.8.gem
Fetching travis-1.8.10.gem
Successfully installed multipart-post-2.1.1
Successfully installed faraday-0.17.3
Successfully installed faraday_middleware-0.14.0
Successfully installed highline-1.7.10
Successfully installed backports-3.16.1
Successfully installed net-http-pipeline-1.0.1
Successfully installed net-http-persistent-2.9.4
Successfully installed addressable-2.4.0
Successfully installed multi_json-1.14.1
Successfully installed gh-0.15.1
Successfully installed launchy-2.4.3
Building native extensions. This could take a while...
Successfully installed ffi-1.12.2
Successfully installed ethon-0.12.0
Successfully installed typhoeus-0.8.0
Successfully installed websocket-1.2.8
Successfully installed pusher-client-0.6.2
Successfully installed travis-1.8.10
17 gems installed
# travis login
Shell completion not installed. Would you like to install it now? |y| y
We need your GitHub login to identify you.
This information will not be sent to Travis CI, only to api.github.com.
The password will not be displayed.

Try running with --github-token or --auto if you don't want to enter your password anyway.

Username: dvillaj@gmail.com
Password for dvillaj@gmail.com: **************
Successfully logged in as dvillaj!
# cd /app
# travis encrypt-file service-account.json -r dvillaj/multi-k8s
encrypting service-account.json for dvillaj/multi-k8s
storing result as service-account.json.enc
storing secure env variables for decryption

Please add the following to your build script (before_install stage in your .travis.yml, for instance):

    openssl aes-256-cbc -K $encrypted_0c35eebf403c_key -iv $encrypted_0c35eebf403c_iv -in service-account.json.enc -out service-account.json -d

Pro Tip: You can add it automatically by running with --add.

Make sure to add service-account.json.enc to the git repository.
Make sure not to add service-account.json to the git repository.
Commit all changes to your .travis.yml.
# rm service-account.json
# exit
```

## Access Google Cloud from Google

```
gcloud config set project multi-269504
gcloud config set compute/zone europe-west1-b
gcloud container clusters get-credentials multi-cluster
```

## Installing Google Cloud 

- export CLOUDSDK_CORE_DISABLE_PROMPTS=1
- curl https://sdk.cloud.google.com | bash > /dev/null;
- source $HOME/google-cloud-sdk/path.bash.inc
- gcloud components update kubectl

## Access Google Cloud from local

```
source $HOME/google-cloud-sdk/path.bash.inc
gcloud auth activate-service-account --key-file ~/projects/complexk8s/service-account.json
gcloud config set project multi-269504
gcloud config set compute/zone europe-west1-b
gcloud container clusters get-credentials multi-cluster
```


## Creating a secret on Google Cloud

```
$ export CLOUDSDK_CORE_DISABLE_PROMPTS=1
$ curl https://sdk.cloud.google.com | bash > /dev/null;
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   443  100   443    0     0   3434      0 --:--:-- --:--:-- --:--:--  3407
######################################################################## 100.0%
which curl
curl -# -f https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz
######################################################################## 100.0%
mkdir -p /home/vagrant
tar -C /home/vagrant -zxvf /tmp/tmp.FyqtGlElcL/google-cloud-sdk.tar.gz
/home/vagrant/google-cloud-sdk/install.sh


Your current Cloud SDK version is: 282.0.0
Installing components from version: 282.0.0

+-----------------------------------------------------------------------------+
|                     These components will be installed.                     |
+-----------------------------------------------------+------------+----------+
|                         Name                        |  Version   |   Size   |
+-----------------------------------------------------+------------+----------+
| BigQuery Command Line Tool                          |     2.0.54 |  < 1 MiB |
| BigQuery Command Line Tool (Platform Specific)      |     2.0.53 |  < 1 MiB |
| Cloud SDK Core Libraries (Platform Specific)        | 2020.02.14 |  < 1 MiB |
| Cloud Storage Command Line Tool                     |       4.47 |  3.6 MiB |
| Cloud Storage Command Line Tool (Platform Specific) |       4.47 |  < 1 MiB |
| Default set of gcloud commands                      |            |          |
| anthoscli                                           |     0.0.13 | 23.9 MiB |
| anthoscli                                           |            |          |
| gcloud cli dependencies                             | 2018.08.03 |  8.6 MiB |
+-----------------------------------------------------+------------+----------+

For the latest full release notes, please visit:
  https://cloud.google.com/sdk/release_notes

#============================================================#
#= Creating update staging area                             =#
#============================================================#
#= Installing: BigQuery Command Line Tool                   =#
#============================================================#
#= Installing: BigQuery Command Line Tool (Platform Spec... =#
#============================================================#
#= Installing: Cloud SDK Core Libraries (Platform Specific) =#
#============================================================#
#= Installing: Cloud Storage Command Line Tool              =#
#============================================================#
#= Installing: Cloud Storage Command Line Tool (Platform... =#
#============================================================#
#= Installing: Default set of gcloud commands               =#
#============================================================#
#= Installing: anthoscli                                    =#
#============================================================#
#= Installing: anthoscli                                    =#
#============================================================#
#= Installing: gcloud cli dependencies                      =#
#============================================================#
#= Creating backup and activating new installation          =#
#============================================================#

Performing post processing steps...
.......................................................................................................................done.

Update done!

$ source $HOME/google-cloud-sdk/path.bash.inc
$ gcloud components update kubectl


Your current Cloud SDK version is: 282.0.0
Installing components from version: 282.0.0

┌─────────────────────────────────────────────────────────────────────┐
│                 These components will be installed.                 │
├─────────────────────┬────────────────────────┬──────────────────────┤
│         Name        │        Version         │         Size         │
├─────────────────────┼────────────────────────┼──────────────────────┤
│ kubectl             │                1.14.10 │             74.6 MiB │
│ kubectl             │             2020.02.07 │              < 1 MiB │
└─────────────────────┴────────────────────────┴──────────────────────┘

For the latest full release notes, please visit:
  https://cloud.google.com/sdk/release_notes

╔════════════════════════════════════════════════════════════╗
╠═ Creating update staging area                             ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: kubectl                                      ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: kubectl                                      ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Creating backup and activating new installation          ═╣
╚════════════════════════════════════════════════════════════╝

Performing post processing steps...done.

Update done!

$ gcloud auth activate-service-account --key-file ~/projects/complexk8s/service-account.json
Activated service account credentials for: [travis-deployer@multi-269504.iam.gserviceaccount.com]
$ gcloud config set project multi-269504
Updated property [core/project].
WARNING: You do not appear to have access to project [multi-269504] or it does not exist.
$ gcloud config set compute/zone europe-west1-b
Updated property [compute/zone].
$ gcloud container clusters get-credentials multi-cluster
Fetching cluster endpoint and auth data.
kubeconfig entry generated for multi-cluster.
$ kubectl get pods
No resources found.
$ kubectl create secret generic pgpassword --from-literal PGPASSWORD=12345asfdPRO
secret/pgpassword created
$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-4sb65   kubernetes.io/service-account-token   3      2d1h
pgpassword            Opaque                                1      23s
$
```

## Installing Helm

```
Welcome to Cloud Shell! Type "help" to get started.
Your Cloud Platform project in this session is set to multi-269504.
Use “gcloud config set project [PROJECT_ID]” to change to a different project.

dvillaj_docker@cloudshell:~ (multi-269504)$ chmod 700 get_helm.sh
dvillaj_docker@cloudshell:~ (multi-269504)$ ./get_helm.sh
Error: Get http://localhost:8080/api/v1/namespaces/kube-system/pods?labelSelector=app%3Dhelm%2Cname%3Dtiller: dial tcp 127.0.0.1:8080: connect: connection refused
Helm v3.1.1 is available. Changing from version .
Downloading https://get.helm.sh/helm-v3.1.1-linux-amd64.tar.gz
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
dvillaj_docker@cloudshell:~ (multi-269504)$

```

## Create a Service Account and Authorize it

```
$ kubectl get namespaces
NAME              STATUS   AGE
default           Active   3d2h
kube-node-lease   Active   3d2h
kube-public       Active   3d2h
kube-system       Active   3d2h

$ kubectl create serviceaccount --namespace kube-system tiller
serviceaccount/tiller created
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
clusterrolebinding.rbac.authorization.k8s.io/tiller-cluster-rule created

$ kubectl get ClusterRoleBindings
NAME                                                   AGE
cluster-admin                                          3d3h
cluster-autoscaler-updateinfo                          3d3h
event-exporter-rb                                      3d3h
gce:beta:kubelet-certificate-bootstrap                 3d3h
gce:beta:kubelet-certificate-rotation                  3d3h
gce:cloud-provider                                     3d3h
heapster-binding                                       3d3h
kube-apiserver-kubelet-api-admin                       3d3h
kubelet-bootstrap                                      3d3h
kubelet-bootstrap-certificate-bootstrap                3d3h
kubelet-bootstrap-node-bootstrapper                    3d3h
kubelet-cluster-admin                                  3d3h
metrics-server:system:auth-delegator                   3d3h
npd-binding                                            3d3h
stackdriver:fluentd-gcp                                3d3h
stackdriver:metadata-agent                             3d3h
system:aws-cloud-provider                              3d3h
system:basic-user                                      3d3h
system:controller:attachdetach-controller              3d3h
system:controller:certificate-controller               3d3h
system:controller:clusterrole-aggregation-controller   3d3h
system:controller:cronjob-controller                   3d3h
system:controller:daemon-set-controller                3d3h
system:controller:deployment-controller                3d3h
system:controller:disruption-controller                3d3h
system:controller:endpoint-controller                  3d3h
system:controller:expand-controller                    3d3h
system:controller:generic-garbage-collector            3d3h
system:controller:horizontal-pod-autoscaler            3d3h
system:controller:job-controller                       3d3h
system:controller:namespace-controller                 3d3h
system:controller:node-controller                      3d3h
system:controller:persistent-volume-binder             3d3h
system:controller:pod-garbage-collector                3d3h
system:controller:pv-protection-controller             3d3h
system:controller:pvc-protection-controller            3d3h
system:controller:replicaset-controller                3d3h
system:controller:replication-controller               3d3h
system:controller:resourcequota-controller             3d3h
system:controller:route-controller                     3d3h
system:controller:service-account-controller           3d3h
system:controller:service-controller                   3d3h
system:controller:statefulset-controller               3d3h
system:controller:ttl-controller                       3d3h
system:discovery                                       3d3h
system:kube-controller-manager                         3d3h
system:kube-dns                                        3d3h
system:kube-dns-autoscaler                             3d3h
system:kube-scheduler                                  3d3h
system:metrics-server                                  3d3h
system:node                                            3d3h
system:node-proxier                                    3d3h
system:public-info-viewer                              3d3h
system:volume-scheduler                                3d3h
tiller-cluster-rule                                    37s

$ kubectl get ServiceAccount
NAME      SECRETS   AGE
default   1         3d3h

$ kubectl get ServiceAccount --namespace kube-system
NAME                                 SECRETS   AGE
attachdetach-controller              1         3d3h
certificate-controller               1         3d3h
cloud-provider                       1         3d3h
clusterrole-aggregation-controller   1         3d3h
cronjob-controller                   1         3d3h
daemon-set-controller                1         3d3h
default                              1         3d3h
deployment-controller                1         3d3h
disruption-controller                1         3d3h
endpoint-controller                  1         3d3h
event-exporter-sa                    1         3d3h
expand-controller                    1         3d3h
fluentd-gcp                          1         3d3h
fluentd-gcp-scaler                   1         3d3h
generic-garbage-collector            1         3d3h
heapster                             1         3d3h
horizontal-pod-autoscaler            1         3d3h
job-controller                       1         3d3h
kube-dns                             1         3d3h
kube-dns-autoscaler                  1         3d3h
metadata-agent                       1         3d3h
metadata-proxy                       1         3d3h
metrics-server                       1         3d3h
namespace-controller                 1         3d3h
node-controller                      1         3d3h
persistent-volume-binder             1         3d3h
pod-garbage-collector                1         3d3h
prometheus-to-sd                     1         3d3h
pv-protection-controller             1         3d3h
pvc-protection-controller            1         3d3h
replicaset-controller                1         3d3h
replication-controller               1         3d3h
resourcequota-controller             1         3d3h
service-account-controller           1         3d3h
service-controller                   1         3d3h
statefulset-controller               1         3d3h
tiller                               1         2m47s
ttl-controller                       1         3d3h
$
```


## Ingress-Nginx with Helm


```
$ helm install my-nginx stable/nginx-ingress --set rbac.create=true
Error: failed to download "stable/nginx-ingress" (hint: running `helm repo update` may help)

$ helm repo add stable https://kubernetes-charts.storage.googleapis.com/
"stable" has been added to your repositories
$ helm install my-nginx stable/nginx-ingress --set rbac.create=true
NAME: my-nginx
LAST DEPLOYED: Sun Mar  1 08:21:37 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w my-nginx-nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
  
$ kubectl --namespace default get services -o wide -w my-nginx-nginx-ingress-controller
NAME                                TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE    SELECTOR
my-nginx-nginx-ingress-controller   LoadBalancer   10.91.7.173   35.233.101.34   80:32588/TCP,443:31798/TCP   115s   app=nginx-ingress,component=controller,release=my-nginx

```

## 

### Domain Name Setup

- Buy a domain in namecheap.com
- DNS Setting
    - Add A Record:
        @ -> IP ADDRESS (From Google Cloud / Kubernetes Engine / Services & Ingres)
    - Add CName Record:
        www -> fib-generator.xyz.

### Install a Cert Manager with Helm

```
D:\Projects\docker-udemy>ssh -t vagrant@localhost -p 2222
Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.15.0-76-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Fri Mar  6 16:45:17 UTC 2020

  System load:  0.0                Processes:           102
  Usage of /:   10.9% of 61.80GB   Users logged in:     0
  Memory usage: 6%                 IP address for eth0: 10.0.2.15
  Swap usage:   0%

 * Multipass 1.0 is out! Get Ubuntu VMs on demand on your Linux, Windows or
   Mac. Supports cloud-init for fast, local, cloud devops simulation.

     https://multipass.run/

 * Latest Kubernetes 1.18 beta is now available for your laptop, NUC, cloud
   instance or Raspberry Pi, with automatic updates to the final GA release.

     sudo snap install microk8s --channel=1.18/beta --classic

 * Canonical Livepatch is available for installation.
   - Reduce system reboots and improve kernel security. Activate at:
     https://ubuntu.com/livepatch

0 packages can be updated.
0 updates are security updates.



This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Fri Mar  6 16:22:01 2020 from 10.0.2.2
Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.15.0-76-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Fri Mar  6 16:45:17 UTC 2020

  System load:  0.0                Processes:           102
  Usage of /:   10.9% of 61.80GB   Users logged in:     0
  Memory usage: 6%                 IP address for eth0: 10.0.2.15
  Swap usage:   0%

 * Multipass 1.0 is out! Get Ubuntu VMs on demand on your Linux, Windows or
   Mac. Supports cloud-init for fast, local, cloud devops simulation.

     https://multipass.run/

 * Latest Kubernetes 1.18 beta is now available for your laptop, NUC, cloud
   instance or Raspberry Pi, with automatic updates to the final GA release.

     sudo snap install microk8s --channel=1.18/beta --classic

 * Canonical Livepatch is available for installation.
   - Reduce system reboots and improve kernel security. Activate at:
     https://ubuntu.com/livepatch

0 packages can be updated.
0 updates are security updates.



This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Fri Mar  6 16:22:01 2020 from 10.0.2.2

$ source $HOME/google-cloud-sdk/path.bash.inc
$ gcloud auth activate-service-account --key-file ~/projects/complexk8s/service-account.json
Activated service account credentials for: [travis-deployer@multi-269504.iam.gserviceaccount.com]


Updates are available for some Cloud SDK components.  To install them,
please run:
  $ gcloud components update

$ gcloud config set project multi-269504
Updated property [core/project].
WARNING: You do not appear to have access to project [multi-269504] or it does not exist.
$ gcloud config set compute/zone europe-west1-b
Updated property [compute/zone].
$ gcloud container clusters get-credentials multi-cluster
Fetching cluster endpoint and auth data.
kubeconfig entry generated for multi-cluster.
$ kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.13.1/deploy/manifests/00-crds.yaml
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created
$ kubectl create namespace cert-manager
namespace/cert-manager created
$ helm repo add jetstack https://charts.jetstack.io
"jetstack" has been added to your repositories
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
$ helm install \
>   cert-manager jetstack/cert-manager \
>   --namespace cert-manager \
>   --version v0.13.1

NAME: cert-manager
LAST DEPLOYED: Fri Mar  6 16:48:18 2020
NAMESPACE: cert-manager
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
cert-manager has been deployed successfully!

In order to begin issuing certificates, you will need to set up a ClusterIssuer
or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).

More information on the different types of issuers and how to configure them
can be found in our documentation:

https://docs.cert-manager.io/en/latest/reference/issuers.html

For information on how to configure cert-manager to automatically provision
Certificates for Ingress resources, take a look at the `ingress-shim`
documentation:

https://docs.cert-manager.io/en/latest/reference/ingress-shim.html
$
$ kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-6559f74744-qr8tn              1/1     Running   0          15s
cert-manager-cainjector-795c46858f-sgf2x   1/1     Running   0          15s
cert-manager-webhook-5dfc77cd74-gmxdq      0/1     Running   0          15s
$
```