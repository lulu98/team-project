# team-project  
## Done
- Gitlab registry and gitlab-runner in Docker container  
- Gitlab CI pipeline  
- Gitlab registry  
- Integration of Minikube cluster to Gitlab  
## Current activity  
Implementing CI/CD pipeline with Kubernetes and Gitlab registry.  
1. Because minikube just one node cluster use kubeadm.  
Problem is that kubeadm init needs older docker version. Make sure that safely install new docker version without deleting all volumes and stuff.  
2. Use code from katacoda to create Kubernetes cluster and connect another node to cluster with kubeadm join ... .  
3. Write pod-definition.yml file and replica set controller for turtlebot simulations.  
4. Worker can pull from gitlab registry.  
5. Write script: build image, push to Gitlab registry, trigger master in deployment stage, robots of cluster pull image.  
## Future Projects
1. Replace minikube and VM with real Kubernetes installation.  
2. Transform local simulation of system to real physical machines.  
3. Monitor robots on GUI.
