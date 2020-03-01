 # Google Cloud

 ## Create the proyect

 - Billing
 - Compute -> Kubernetes Engine
    - Create cluster
        - Name
        - Machine Type: 1 CPU, 3.75 Gb
 - IAM & Admin -> Service Account
    - Create Service Account
        - name: travis-deployer
        - role: Kubernetes Engine Admin
        - Create JSON Key

 - Add Postgres secret

 ```
 kubectl create secret generic pgpassword --from-literal PGPASSWORD=12345asfdPRO
 ```

 - Deploy Ingress into the cluster
 
   https://kubernetes.github.io/ingress-nginx/deploy/

    - Install Helm from Script (https://helm.sh/docs/intro/install/)
    
    Google Cloud Terminal
        Configure Editor -> Terminal Preferences -> Copy Settings -> Copy and Paste with Crtl + Shift + C/V
    Copy and paste from `Install Helm from Script` section


    - Deploy Ingress into the cluster
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install my-nginx stable/nginx-ingress --set rbac.create=true
```

    - Check the result in Workloads (Deployments)
    - Goto Services and copy the URL for LoadBalancer Service (The Access Point of the application)

- Google Cloud Platform -> Network Services -> 

## Clean up

https://www.udemy.com/docker-and-kubernetes-the-complete-guide/learn/v4/t/lecture/11684242?start=0
