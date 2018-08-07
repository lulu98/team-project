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
- using docker swarm for deployment in Gitlab  
## Current activity  
- fix update delay of container deployment, if image changes  
- how to connect to Gitlab instance from remote place -> currently using router to use same ip all the time  
- deploying actual images using ROS software  
## Future Projects
- monitor robots over GUI
- using kubectl in .gitlab-ci.yml file and accessing cluster not working although setting context for kubectl  
- using kubectl run on gitlab registry not working  
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
- nmcli, use ip after inet4 -> this is ip that router gives to pc  
- map this ip to some artificial name (in our case master), later we want to access gitlab instance over this ip but dont want to type ip all the time into the browser, also on other machines in cluster  
- create docker-compose.yml file and start containers with docker-compose up (must be in same folder as docker-compose.yml file)  
- type: master:7070 in browser and log in to Gitlab for first time  
- follow advice of page to initialize and configure git on local machine  
- register runner  
1. go inside gitlab-runner container with: docker exec -it "name of container" bash  
2. gitlab-runner register and follow advice: use image gitlab:dind for service dind, you can find token in gitlab container under Admin Area -> Runners or Settings -> CI/CD -> Runner settings  
3. if runner not available in gitlab check clone_url, network_mode, volume in .docker-compose.yml and /etc/gitlab-runner/config.toml inside gitlab
root@8a6bdc06e08b:/# gitlab-runner register
Running in system-mode.                            
                                                   
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):  
http://gitlab:7070  
Please enter the gitlab-ci token for this runner:  
iGeFrZz7UrncT4oQDEg6  
Please enter the gitlab-ci description for this runner:  
[8a6bdc06e08b]: my-runner  
Please enter the gitlab-ci tags for this runner (comma separated):  
my-runner  
Registering runner... succeeded                     runner=iGeFrZz7  
Please enter the executor: docker-ssh, ssh, docker, shell, virtualbox, docker+machine, docker-ssh+machine, kubernetes, parallels:  
docker  
Please enter the default Docker image (e.g. ruby:2.1):  
gitlab/dind  
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!  
- find out network: docker network ls and search for network whose first part is called like the folder where docker-compose file is sitting, make docker network inspect this_network and look if gitlab and gitlab-runner container is in there  
- change configuration for runner to work in ci pipeline  
clone_url: clone_url = "http://gitlab:7070", network: network_mode = "tutorial_default", volume: volumes = ["/cache","/var/run/docker.sock:/var/run/docker.sock"]  
- integrate gitlab registry  
change /etc/gitlab/gitlab.rb file and/or docker-compose up  
add insecure registries in /etc/docker/daemon.json, also on other machines of cluster
- push .gitlab-ci.yml, Dockerfile, other files used in Dockerfile and check pipeline out, when successful then check registry out  
## Add ssh authentication
- create ssh key pair: https://docs.gitlab.com/ee/ssh/README.html  
- add public key under User settings -> ssh keys  
For more information: https://docs.gitlab.com/ee/ssh/ 

## Solution with Docker Swarm
- initialize docker swarm: docker swarm init  
- on master: docker swarm join-token worker -> use this command on worker to join cluster (you can copy this command in readme in gitlab, so that other people on team can join the cluster)  
- if not working, maybe firewall issue: https://www.digitalocean.com/community/tutorials/how-to-configure-the-linux-firewall-for-docker-swarm-on-ubuntu-16-04  
- deploy service: docker service create --replicas 1 --name nameOfService nameOfImage command  
- to update service: docker service update nameOfService  
For more information: https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/ and follow links at bottom of page

## Connect to Gitlab
- for more convenience: add in /etc/hosts the line: (static) ip-address name  
- add in /etc/docker/daemon.json the entry for insecure-registry for gitlab registry  
- update docker engine: service docker restart  
- (on master)update gitlab containers: docker-compose up  
-> you can connect to gitlab over browser by typing: nameForIp:port -> register if not master -> master can add people to projects
- master: got to project -> Settings -> Members
To use CI/CD push a Dockerfile plus resources and a .gitlab-ci.yml file to gitlab and hope it works
## On worker nodes
- map ip of manager to artificial name  
- set insecure registry
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
