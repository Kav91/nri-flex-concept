# NRI Flex Concept

- Flex is an agnostic AIO integration running on pixie dust (aka the weekend hacking project)

### Why?
- Flex abstracts the need for end users to write any code to consume custom metrics they may need, other then to define a configuration yml
- Flex can generate New Relic metric samples automatically for almost any payload, useful helper functions exist to tidy up your output neatly
- As updates and upgrades are made, all integration points reap the benefits

### Features & Support
- Linux only currently
- Run any HTTP/S request, read file, shell command, Database Query, or JMX Query.
- Use any existing Prometheus Exporter / Integration
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

#### Integrations (Count: 30+) (+All Prometheus Exporters)
- [Prometheus Exporters](https://prometheus.io/docs/instrumenting/exporters/)
- [Prometheus Rest API(vector, matrix, targets supported)](https://prometheus.io/docs/prometheus/latest/querying/api/)
- Consul
- Vault (shows merge functionality)
- Bamboo
- Teamcity
- CircleCI
- RabbitMQ (shows metric parser, and lookup store functionality)
- Elasticsearch (shows inbuilt URL cache functionality)
- Traefik
- Kong
- Lighttpd
- Eventstore
- etcd (shows custom sample keys functionality)
- Varnish
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

nri-flex-config.yml
---
integration_name: com.kav91.nri-flex
instances:
  - name: nri-flex
    command: metrics
    arguments:
      container_discovery: true ### <- set to true to enable
```

#### Container Discovery
- Requires access to /var/run/docker.sock (same as the New Relic Infrastructure Agent, so it is convenient to bake flex into the newrelic/infrastructure image)
- Add a label that contains the keyword - "flexDiscovery" for the container (if using reverse discovery apply to nri-flex container - explained further under parameters)
- For Kubernetes add it as an environment variable
- To that same label add a flex discovery configuration eg. "t=redis,c=redis,tt=img,tm=contains"
- Complete example                                              flexDiscoveryRedis="t=redis,c=redis,tt=img,tm=contains"
- If your target is consistent with the config file you could even just have flexDiscoveryRedis="t=redis" and it'll work!
- You can have varying configs for one or many container as well just set different names eg. flexDiscoveryRedis1, flexDiscoveryRedis2, flexDiscoveryZookeeper etc.
- Flex Container Discovery Configs are placed within "flexContainerDiscovery/" directory 
- For an example see "flexContainerDiscovery/redis.yml" 
- Use ${auto:host} and ${auto:port} anywhere in your config, this will dynamically be substituted per container discovered
- This makes it possible to have multiple containers re-use the same config with different ip/port configurations

#### Flex Discovery Configuration Parameters
- tt=targetType - are we targetting an img = image or cname = containerName? (default "img")
- t=target - the keyword to target based on the targetType eg. "redis"
- tm=targetMode - contains, prefix or regex to match the target (default "contains")
- c=config - which config file will we use to create the dynamic configs from eg. "redis" .yml (defaults to the "target value")
- p=port - force set a chosen target port
- r=reverse - if set eg. r=true on nri-flex itself, it will perform a reverse lookup to match against containers (this means you don't have to set labels on individal containers)
- ip=ipMode - default private can be set to public
- If config is nil, use the target (t), as the yaml file to look up, eg. if target (t) = redis, lookup the config (c) redis.yml if config not set

### Prometheus Integrations - [Exporters](https://prometheus.io/docs/instrumenting/exporters/)
- Supports all Prometheus exporters
- Flex will attempt to flatten all Prometheus metrics for you to save on events being generated, however you may need to do some minor additional configuration (below) to get your desired output
- With the automatically flattened event, the histogram & summary, count & sum values are retained
- If you would like the full qauntiles and buckets, consider flagging on histogram, and/or summary to true
- Target the /metrics endpoint and set your desired configuration, see further below for options
- To quickly find out what metrics may need to be in their own samples or merged into the main sample, set -force_log and view the /metrics endpoint you are targetting
- Check this basic example flexConfigs/prometheus-redis-exporter.yml && for auto discovery flexContainerDiscovery/prometheusRedisExporter.yml 

```
# Redis Example
# placed in -> flexConfigs/
---
name: prometheusRedisFlex
apis: 
  - name: prometheusRedis
    url: http://localhost:9121/metrics
    prometheus: 
      enable: true
      flattened_event: "prometheusRedisSample" # name of the event_type when metrics are flattened into a single sample
      # unflatten: true ### <- every prometheus metric will be unflattened into their own sample, other functions will not be available
      ############           use with caution as this can create a large amount samples
      ############           it is useful for testing to see the output of metrics you are getting as well
      key_merge: [cmd] # the same metric may exist multiple times, for different things, if we want to flatten them out we can use this parameter
      ############        eg. "redis_commands_duration_seconds_total" Metric exists for multiple commands, there is a "cmd" attribute on each metric to distinguish each command
      ############        so we add "cmd" to the array to flatten it like this eg. "redis_commands_duration_seconds_total.info" = 132 ("info was the command in this case")
      ###########        db could also be added here, so you could just add to the array eg. key_merge: [cmd,db]
      sample_keys:
        prometheusRedisDbSample: db # multiple metrics may exist where they correspond to the same thing like metrics of each particular database
      ############                     eg. redis_db_keys_expiring and redis_db_keys, both have a "db" key to distinguish each database
      ############                     this will let us roll up all the metrics that contain the "db" key into a "prometheusRedisDbSample"
      ############                     we could also use cmd here, if we wanted them in separate samples add for eg. prometheusRedisCmdSample: cmd
    custom_attributes: # apply any custom attributes as you require
      serverName: mySuperServer
    remove_keys:
      - go_ # we can remove the internal exporter go metrics like this
    #snake_to_camel: true
```
```
# Etcd Example
# placed in -> flexConfigs/
---
name: prometheusEtcdFlex
apis: 
  - name: prometheusEtcd
    url: http://localhost:2379/metrics
    prometheus: 
      enable: true
      flattened_event: "prometheusEtcdSample"
      key_merge: [action]
      sample_keys:
        prometheusEtcdServiceSample: grpc_service
```
```
# Etcd Example with Container Discovery
# placed in -> flexContainerDiscovery/
---
name: prometheusEtcdFlex
apis: 
  - name: prometheusEtcd
    url: http://${auto:host}:${auto:port}/metrics
    prometheus: 
      enable: true
      flattened_event: "prometheusEtcdSample"
      key_merge: [action]
      sample_keys:
        prometheusEtcdServiceSample: grpc_service
```

### Testing & Debugging
```
Testing a single config
./nri-flex -config_file "flexConfigs/redis-cmd-raw-example.yml"
./nri-flex-mac -config_file "flexConfigs/redis-cmd-raw-example.yml" # remember to remove the -q0 flag from the command as it's not supported by mac in the example config

Testing all configs in ./flexConfigs (this repo has alot of examples! only keep what you need)
./nri-flex 
./nri-flex-mac

Debugging
./nri-flex -force_log <- will spit out additional info to stdout (do not use in production)

```

### Installation

- Setup your configuration see inside flexConfigs, flexContainerDiscovery & fullConfigExamples for examples
- Flex will run everything by default in the default flexConfigs/ folder (so only keep what you need before deploying)
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


