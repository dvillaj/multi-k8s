echo "Using SHA of $GIT_SHA ..."

docker build -t dvillaj/multi-client:latest -t dvillaj/multi-client:$GIT_SHA -f ./client/Dockerfile ./client
docker build -t dvillaj/multi-server:latest -t dvillaj/multi-server:$GIT_SHA -f ./server/Dockerfile ./server
docker build -t dvillaj/multi-worker:latest -t dvillaj/multi-worker:$GIT_SHA -f ./worker/Dockerfile ./worker

docker push dvillaj/multi-client:latest
docker push dvillaj/multi-server:latest
docker push dvillaj/multi-worker:latest

docker push dvillaj/multi-client:$GIT_SHA
docker push dvillaj/multi-server:$GIT_SHA
docker push dvillaj/multi-worker:$GIT_SHA

echo "Applying changes in Kubernetes ..."

kubectl apply -f k8s
kubectl set image deployments/client-deployment client=dvillaj/multi-client:$GIT_SHA
kubectl set image deployments/server-deployment server=dvillaj/multi-server:$GIT_SHA
kubectl set image deployments/worker-deployment worker=dvillaj/multi-worker:$GIT_SHA