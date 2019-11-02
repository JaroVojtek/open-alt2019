# Run simple python/react application in docker containers

## Steps-to-follow
* Run ligtweight PostgreSQL database as docker container
* Build backend docker image from Dockerfile
* Run backend microservice in docker container 
* Build frontend docker image from Dockerfile
* Run frontend microservice in docker container


## Prerequisity

* PostgreSQL database running in docker container from previous section `1_README_local.md`
## Build backend docker image from Dockerfile

Switch to project dir
```
cd open-alt2019/easy-python-app/backend/
```
Build backend docker image from Dockerfile
```
sudo docker build -t backend-microservice:0.0.1 .
```
Check newly build backend microservice docker image
```
sudo docker images
```
## Run backend microservice in docker container 
Export public IP address of you host. For example

```
export MY_IP_ADDR=$(ip a | grep 'inet ' | awk '{{ print $2 }}' | egrep -v '^(127|172)\.' | cut -f1 -d/ | head -n1)
```


```
sudo docker run \
-p 8000:8000 \
--rm \
--name backend-microservice \
-d \
-e PSQL_DB_USER='micro' \
-e PSQL_DB_NAME='microservice' \
-e PSQL_DB_ADDRESS=$MY_IP_ADDR \
-e PSQL_DB_PASS='password' \
-e PSQL_DB_PORT='5432' \
-d backend-microservice:0.0.1
```
Verify functionality of backend microservice running in docker container
```
docker ps
docker inspect <CONTAINER_ID> | grep -i ipaddress
netstat -tunlp | grep -i 8000
wget -O - http://<CONTAINER_IP>:8000/api/isalive
```

## Build frontend docker image from Dockerfile
Switch to project dir
```
cd <LOCAL_PATH>/open-alt209/easy-python-app/frontend/
```
Update get requests in `App.js` file in `frontend/src/` dir to reflect `backend-microservice` running on localhost:8000

Build backend docker image from Dockerfile
```
docker build -t frontend-microservice:0.0.1 .
```
Check newly build backend microservice docker image
```
docker images
```

## Run frontend microservice in docker container 

```
docker run -p 5000:80 \
--rm --name frontend-microservice \
-d frontend-microservice:0.0.1
```