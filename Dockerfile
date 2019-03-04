FROM newrelic/infrastructure

COPY ./nri-flex-config.yml /etc/newrelic-infra/integrations.d/
COPY ./nri-flex-nix-def.yml /var/db/newrelic-infra/custom-integrations/
COPY ./nri-flex /var/db/newrelic-infra/custom-integrations/
ADD nrjmx /var/db/newrelic-infra/custom-integrations/

# standard configs
# ADD flexConfigs /var/db/newrelic-infra/custom-integrations/flexConfigs

# container discovery configs
# ADD flexContainerDiscovery /var/db/newrelic-infra/custom-integrations/flexContainerDiscovery/
