# NRI Flex Concept

- Flex is an agnostic AIO integration running on pixie dust (aka the weekend hacking project)

### Why?
- Flex abstracts the need for end users to write any code to consume custom metrics they may need, other then to define a configuration yml
- Flex can generate New Relic metric samples automatically for almost any payload, useful helper functions exist to tidy up your output neatly
- As updates and upgrades are made, all integration points reap the benefits

### Features & Support
- Linux only currently
- Run any HTTP/S request, read file, shell command, Database Query, or JMX Query.
- Consume any JSON, JMX, or RAW command output from the above (Java 7+ is required for JMX to work)
- Attempt to cleverly flatten to samples
- Detect and flatten dimensional data from Prometheus style payloads (vector, matrix, targets supported)
- Merge different samples and outputs together
- Key Remover & Replacer
- Metric Parser for RATE & DELTA support (has capability to auto set rates and deltas)
- Define multiple APIs / commands or mix
- event_type autoset or override
- Define custom attributes (more granular control, compared to NR infra agent)
- Command allows horizontal split (useful for table style data) (use only once per command set)
- snake_case to CamelCase conversion
- Percentage to Decimal conversion
- ToLower conversion
- SubParse functionality (see redis config for an example)
- LookUp Store - save attributes from previously generated samples to use in requests later (see rabbit example)
- LazyFlatten - for arrays
- Inbuilt data caching - useful for reusing existing data and processing samples at different points

#### Order of Data Finalization
- Strip Keys - Happens before attribute modifiction and auto smart flattening, useful to get rid of unneeded data and arrays
- Remove Keys
- ToLower Case
- Convert Space
- snake_case to camelCase
- Replace Keys // uses regex to find keys to replace
- Rename Key // contains replace
- Keep Keys // keeps only keys you want to keep, and removes the rest

#### Integrations (Count: 30+)
- Consul
- Vault (shows merge functionality)
- Bamboo
- Teamcity
- CircleCI
- RabbitMQ (shows metric parser, and lookup store functionality)
- Elasticsearch (shows inbuilt URL cache functionality)
- Traefik
- Kong
- etcd (shows custom sample keys functionality)
- Varnish
- Prometheus (vector, matrix, targets supported)
- Redis (more metrics, multi instance support, multi db support) (shows snake to camel, perc to decimal, replace keys, rename keys & sub parse functionality)
- Zookeeper
- OpsGenie
- VictorOps
- PagerDuty (shows lazy_flatten functionality)
- AlertOps (shows lazy_flatten functionality)
- New Relic Alert Ingestion (provides similar output to nri-alerts-pipe)
- New Relic App Status Health Ingestion (appSample to present your app health, language, and aggregated summary)
- http/s testing & request performance via curl
- Postgres Custom Querying
- MySQL Custom Querying
- MariaDB Custom Querying
- Percona Server, Google CloudSQL or Sphinx (2.2.3+) Custom Querying
- MS SQL Server Custom Querying
- JMX via nrjmx // (nrjmx is targetted to work with Java 7+, see cassandra and tomcat examples)
- cassandra - via jmx
- tomcat - via jmx
- bind9
- df display disk & inode info (shows horizontal split functionality)
- PHP-FPM (Contributor: goldenplec)

### How to create Flex config(s)?
- Easiest way is to take a look at the examples and their inline comments

### Standard Configuration
- Default configuration looks for Flex config files in /flexConfigs
- Run ./nri-flex -help for more info
``` 
- This integration also supports the following two flags  
You could specific a single Flex Config, or another config directory
-config_dir string
        Set directory of config files (default "flexConfigs/")
-config_file string
        Set a specific config file

With these flags, you could also define multiple instances with different configurations of Flex within "nri-flex-config.yml" 
```

### Flex Auto Container Discovery 
- Flex has the capability to auto discovery containers in your surrounding environment, and dynamically monitor them regardless of changing IP addresses and ports
- See flexContainerDiscovery/ for examples

#### Configuration
```
  -container_discovery
        Enable container auto discovery
  -container_discovery_dir string
        Set directory of auto discovery config files (default "flexContainerDiscovery/")
  -docker_api_version string
        Force Docker client API version
```

#### Flex Auto Container Discovery
- Requires access to /var/run/docker.sock (same as the New Relic Infrastructure Agent, so it is convenient to bake flex into the newrelic/infrastructure image)
- Add a label or annotation that contains the keyword - "flexDiscovery"
- To that same label or annotation add a flex discovery configuration eg. "t=redis,c=redis,tt=img,tm=contains"
- Complete example                                              flexDiscoveryRedis="t=redis,c=redis,tt=img,tm=contains"
- K8s example as they don't support "=" or "," characters       flexDiscoveryRedis:"t_redis.c_redis.tt_img.tm_contains"
- You could have varying configs on one container as well like flexDiscoveryRedis1, flexDiscoveryZookeeper etc.
- Flex Container Discovery Configs are placed within "flexContainerDiscovery/" directory 
- For an example see "flexContainerDiscovery/redis.yml" 
- Use ${auto:host} and ${auto:port} anywhere in your config, this will dynamically be substituted per container discovered
- This makes it possible to have multiple containers re-use the same config with different ip/port configurations

#### Flex Discovery Configuration Parameters
- tt=targetType - are we targetting an img = image or cname = containerName? (default "img")
- t=target - the keyword to target based on the targetType eg. "redis"
- tm=targetMode - contains, prefix or regex to match the target (default "contains")
- c=config - which config file will we use to create the dynamic configs from eg. "redis" .yml (default to "target")
- p=port - force set a chosen target port
- r=reverse - if set eg. reverse=true on nri-flex itself, it will perform a reverse lookup to match against containers (this means you don't have to set labels on individal containers)
- ip=ipMode - default private can be set to public
- If config is nil, use the target (t), as the yaml file to look up, eg. if target (t) = redis, lookup the config (c) redis.yml if config not set

### Installation
- Setup your configuration
- Run install_linux.sh or build the docker image

### Docker
- Set your configs, modify Dockerfile if need be
- Build & Run Image

```
BUILD
docker build -t nri-flex .

RUN - standard
docker run -d --name nri-flex --network=host --cap-add=SYS_PTRACE -v "/:/host:ro" -v "/var/run/docker.sock:/var/run/docker.sock" -e NRIA_LICENSE_KEY="yourInfraLicenseKey" nri-flex:latest

RUN - with container discovery reverse lookup (ensure -container_discovery is set to true nri-flex-config.yml)
docker run -d --name nri-flex --network=host --cap-add=SYS_PTRACE -l flexDiscoveryRedis="t=redis,c=redis,tt=img,tm=contains,r=true"  -v "/:/host:ro" -v "/var/run/docker.sock:/var/run/docker.sock" -e NRIA_LICENSE_KEY="yourInfraLicenseKey" nri-flex:latest
```

### Testing
```
Testing a single config
./nri-flex -config_file "flexConfigs/redis-cmd-raw-example.yml"
./nri-flex-mac -config_file "flexConfigs/redis-cmd-raw-example.yml"

Testing all configs in ./flexConfigs
./nri-flex 
./nri-flex-mac
```

### Installation

- Setup your configuration see inside flexConfigs for examples
- Flex will run everything by default in the default flexConfigs/ folder (so keep what you want before deploy)
- Review the commented out portions in the install_linux.sh and/or Dockerfile depending on your config setup
- Run install_linux.sh or build the docker image
- Alternatively use the install_linux.sh as a guide for setting up

### Docker
- Set your configs, modify Dockerfile if need be
- Build & Run Image

```
BUILD
docker build -t nri-flex .

RUN - standard
docker run -d --name nri-flex --network=host --cap-add=SYS_PTRACE -v "/:/host:ro" -v "/var/run/docker.sock:/var/run/docker.sock" -e NRIA_LICENSE_KEY="yourInfraLicenseKey" nri-flex:latest

RUN - with container discovery reverse lookup (ensure -container_discovery is set to true nri-flex-config.yml)
docker run -d --name nri-flex --network=host --cap-add=SYS_PTRACE -l flexDiscoveryRedis="t=redis,c=redis,tt=img,tm=contains,r=true"  -v "/:/host:ro" -v "/var/run/docker.sock:/var/run/docker.sock" -e NRIA_LICENSE_KEY="yourInfraLicenseKey" nri-flex:latest

Example: Run Redis with a flex discovery label
docker run -it -p 9696:6379 --label flexDiscoveryRedis="t=redis,c=redis,tt=img,tm=contains" --name redis-svr -d redis
```

## Todo
- More doc's on all available features


