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
- etcd (shows custom sample keys functionality)
- Prometheus (vector, matrix, targets supported)
- RabbitMQ (shows metric parser, and lookup store functionality)
- Eventstore
- Elasticsearch (shows inbuilt URL cache functionality)
- Traefik
- Kong
- lighttpd
- Varnish
- Redis (more metrics, multi instance support, multi db support) (shows metric parser, snake to camel, perc to decimal, replace keys, rename keys & sub parse functionality)
- Zookeeper
- OpsGenie
- VictorOps
- PagerDuty (shows lazy_flatten functionality)
- AlertOps (shows lazy_flatten functionality)
- New Relic Alert Ingestion (get alert data within Insights - provides similar output to nri-alerts-pipe)
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
- Any JSON HTTP API 
- Any Command Line Output

### How to create Flex config(s)?
- Easiest way is to take a look at the examples and their inline comments

### Configuration
- Default configuration looks for Flex config files in /flexConfigs
``` 
- This integration also supports the following two flags  
You could specific a single Flex Config, or another config directory
-config_dir string
        Set directory of config files (default "flexConfigs/")
-config_file string
        Set a specific config file

With these flags, you could also define multiple instances with different configurations of Flex within "nri-flex-config.yml"
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

### Todo
- More doc's on all available features
