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