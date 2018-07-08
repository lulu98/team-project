# Continuous Integration of Robotic Software  
Prerequisites: Ubuntu, enough swap memory
## Introduction
This README collects all the necessary information for our system, important files, commands and a list of steps to reproduce our system. To understand the technical aspects of our system, please refer to the design document.
## Done
- Gitlab registry and gitlab-runner in Docker container  
- Gitlab CI pipeline  
- Gitlab registry  
- Integration of Kubernetes cluster to Gitlab  
- Deployment on cluster alone is working  
## Current activity  
- using kubectl in .gitlab-ci.yml file and accessing cluster not working although setting context for kubectl  
- using kubectl run on gitlab registry not working  
## Future Projects
- monitor robots over GUI

## Important files 
- /etc/docker/daemon.json        	-> lists insecure registries that should be allowed  
- /etc/gitlab/gitlab.rb		   	-> contains all configurations of gitlab (container)  
- docker-compose.yml      		-> docker-compose will spin up essential containers like gitlab, gitlab-runner  
- /etc/gitlab-runner/config.toml	-> contains all configurations of runners  
- .gitlab-ci.yml 			-> defines pipeline runners should execute (tags to decide between different registered runners)  
- Dockerfile				-> defines our application as image  
## Important tools 
- Docker					-> Engine to build the container and therefore our whole system  
- Docker-compose				-> can set up multiple containers in a specified file  
- Docker swarm					-> integrated with docker to set up clusters (easier set up than Kubernetes)
- Kubernetes with kubeadm,kubectl, kubelet	-> defines cluster of robots where application should be deployed  

## Steps to reproduce (maybe translate to installation and setup script):
- Install docker  
https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1  
- Install docker-compose  
https://docs.docker.com/compose/install/  
- create docker-compose.yml file and start containers with docker-compose up (must be in same folder as docker-compose.yml file)  
- type: localhost:9090 and log in to Gitlab for first time  
- follow advice of page to initialize and configure git on local machine  
- register runner  
1. go inside gitlab-runner container with: docker exec -it "name of container" bash  
2. gitlab-runner register and follow advice: use image gitlab:dind for service dind, you can find token in gitlab container under Admin Area -> Runners or Settings -> CI/CD -> Runner settings  
3. if runner not available in gitlab check clone_url, network_mode, volume in .docker-compose.yml and /etc/gitlab-runner/config.toml inside gitlab  
- integrate gitlab registry  
change /etc/gitlab/gitlab.rb file and/or docker-compose up  
## Add ssh authentication
- create key pair  
- add public key under User settings -> ssh keys  
For more information: https://docs.gitlab.com/ee/ssh/ 

## Solution with Docker Swarm
- initialize docker swarm: docker swarm init  
- on master: docker swarm join-token worker -> use this command on worker to join cluster  
- deploy service: docker service create --replicas 1 --name nameOfService nameOfImage command  
- to update service: docker service update nameOfService  
For more information: https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/ and follow links at bottom of page

## Connect to Gitlab
- for more convenience: add in /etc/hosts the line: (static) ip-address name  
- add in /etc/docker/daemon.json the entry for insecure-registry for gitlab registry  
- update docker engine: service docker restart  
- (on master)update gitlab containers: docker-compose up  
-> you can connect to gitlab over browser by typing: nameForIp:port -> register if not master -> master can add people to projects
To use CI/CD push a Dockerfile plus resources and a .gitlab-ci.yml file to gitlab and hope it works

## Solution with Kubernetes
- install Kubernetes with kubeadm, kubectl, kubelet  
https://kubernetes.io/docs/tasks/tools/install-kubeadm/  
- initialize cluster, join workers and make cluster recoverable  
http://stytex.de/blog/2018/01/16/how-to-recover-self-hosted-kubeadm-kubernetes-cluster-after-reboot/  
- if warning that docker version too high, don't care but if error because of swap, turn it off with: sudo swapoff -a -> kubeadm reset -> initialize with kubeadm again  
- connect cluster to gitlab  
https://docs.gitlab.com/ee/user/project/clusters/  
-> The system is now ready  
Issue: no kubectl in docker service, kubectl not able to find DNS-server
