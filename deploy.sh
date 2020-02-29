docker build -t stephengrider/multi-client:latest -t stephengrider/multi-client:$GIT_SHA -f ./client/Dockerfile ./client
docker build -t stephengrider/multi-server:latest -t stephengrider/multi-server:$GIT_SHA -f ./server/Dockerfile ./server
docker build -t stephengrider/multi-worker:latest -t stephengrider/multi-worker:$GIT_SHA -f ./worker/Dockerfile ./worker

docker push stephengrider/multi-client:latest
docker push stephengrider/multi-server:latest
docker push stephengrider/multi-worker:latest

docker push stephengrider/multi-client:$GIT_SHA
docker push stephengrider/multi-server:$GIT_SHA
docker push stephengrider/multi-worker:$GIT_SHA

kubectl apply -f k8s
kubectl set image deployments/client-deployment client=stephengrider/multi-client:$GIT_SHA
kubectl set image deployments/server-deployment server=stephengrider/multi-server:$GIT_SHA
kubectl set image deployments/worker-deployment worker=stephengrider/multi-worker:$GIT_SHA