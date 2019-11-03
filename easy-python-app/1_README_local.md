
```
+---------------+   +-------------------------+   +--------------------------+   +-------------+
|               |   |                         |   |                          |   |             |
|               |   |                         |   |                          |   |             |
|  Postgres DB  +---+  Backend microservice   +---+   Frontend microservice  +-->--  Web       |
|               +--->      Python Flask       +--->           React          |   |   Browser   |
|               |   |                         |   |                          |   |             |
+---------------+   +-------------------------+   +--------------------------+   +-------------+
```
# Run simple python/react application locally

Prerequisities:
* `docker`
* `psql` client   
* `npm` 
* `Python 3`
* `git`

## Steps-to-follow
* Run ligtweight PostgreSQL database as docker container
* Run backend microservice locally
* Run frontend microservice locally 

## Prerequisity installation : Docker

```
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
Starting docker service
```
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
```

## Run PostgreSQL 

* Prerequisity:  `docker, psql`

```
sudo docker run --net=host --rm \
--name micro-postgres \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=admin-pass \
-d postgres:alpine
```
Check if PostgreSQL started and is listening on port 5432 on localhost
```
sudo docker ps
sudo netstat -tunlp | grep 5432
```
Connect to PostgreSQL from your laptop
```
psql --host=localhost --port=5432 -U postgres
```
Create database, user and grant privileges
```
CREATE DATABASE  microservice;
CREATE USER micro WITH ENCRYPTED PASSWORD 'password'; 
GRANT ALL PRIVILEGES ON DATABASE microservice TO micro;
ALTER DATABASE microservice OWNER TO micro;
```
Disconnect from database
```
$ \q
```
Connect to microservice database with user micro
```
psql --host=localhost --port=5432 -U micro -d microservice
```

## Run Backend microservice

* Prerequisity:  `Python 3, git`

Clone workshop repository
```
git clone https://github.com/JaroVojtek/open-alt2019.git
```

Switch to project dir
```
cd open-alt209/easy-python-app/backend/
```
Export environmental var
```
export PSQL_DB_USER='micro'
export PSQL_DB_NAME='microservice'
export PSQL_DB_ADDRESS='127.0.0.1'
export PSQL_DB_PASS='password'
export PSQL_DB_PORT='5432'
```
Create python virtualenv
```
python3 -m venv venv_micro
```

Activate virtualenv 
```
source venv_micro/bin/activate
```

Install requirements from requirements.txt
```
pip install -r requirements.txt
```

Start Flask 
```
export FLASK_APP=app
flask run --host=0.0.0.0 --port=8000
```

## Run Frontend microservice

* Prerequisity: `npm`

Switch to project dir
```
cd <LOCAL_PATH>/open-alt209/easy-python-app/frontend/
```
Update get requests in `App.js` file in `frontend/src/` dir to make raquests to backend running on localhost:8000

Build and start React Frontend microservice
```
npm install
npm start
```

Verify in browser
```
localhost:3000
```