# How the Application Works

Although Interface Endpoints scale more cleanly as the number of services increases, they introduce another scaling problem that makes the previous approach of deploying per-VPC impracticable: there's a small fee for each Endpoint of 1 cent per AZ per hour. For example if you were to deploy Interface Endpoints for all of the supported services (currently over 50) across 3 AZs in say 20 VPCs, the cost would be $(0.01 x 50 x 3 x 20) = $30/hr or over $20,000/month!

# How to Build Dockerized node App

1. clone this project `git clone git@github.com:anz-ecp/nashwan-mustafa.git` <br />
2. cd nashwan-mustafa 
3. build your application in a docker image <br />
  `make dkuild` <br />
  or <br />
  `docker build --build-arg=GIT_SHA=$(git rev-parse --short HEAD) -t nashvan/myanzapp .` <br />
4. Tag Image with release tag then pushing to docker repository
  `make dkpush` <br />
  Or run the following commands:<br />
  `docker tag <user>/myanzapp:latest <user>/myanzapp-anz:<release_tag_version>` <br />
  `docker tag nashvan/myanzapp:latest nashvan/myanzapp:1.0.0` <br />
  `docker push <user>/myanzapp:<release_tag_version>` <br />
  `docker push nashvan/myanzapp:1.0.0` <br />

5. Run docker container, map the port to your desired port: <br />
  `docker run -p 5000:8080 myanzapp` <br />
6. make a requet to your application api /info API endpoint requests via your browser <br />
  `http://localhost:5000/info`<br />
  api request should retrun result as below:<br />
  ![output](./images/1-architecture.png)