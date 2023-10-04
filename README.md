# Kubernetes local environment

### Requirements
[ASDF](https://asdf-vm.com/)  
[Docker/Docker Desktop](https://www.docker.com/get-started/)  


### Project setup
```sh
make setup
```

Add the required hosts to your hostfile:
```sh
sudo vim /etc/hosts
# Add
127.0.0.1 kafka.local flink.local zookeepre.local redis.local schema-registry.local
```
### Links
[ArtifactHUB](https://artifacthub.io)

### Debugging
DNS
```sh
kubectl exec -i -t dnsutils -- nslookup kubernetes.default
```
