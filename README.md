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
127.0.0.1 airbyte.local ddb.local
```

### Links
[ArtifactHUB](https://artifacthub.io)

### Debugging
DNS
```sh
kubectl exec -i -t dnsutils -- nslookup kubernetes.default
```

### OSX Apple silicon
Some images are unavailable for Apple silicon chips and must be pulled manually.

```sh
docker pull --platform linux/amd64 pactfoundation/pact-broker:2.112.0-pactbroker2.107.1
```
