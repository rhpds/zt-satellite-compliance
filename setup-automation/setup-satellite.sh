#!/bin/bash

# Unregister Satellite server from itself.
subscription-manager unregister

# Delete Satellite from its inventory.
hammer host delete --name satellite.lab

# Delete the Activation Key created for the Satellite server.
hammer activation-key delete --name "Satellite Server" --organization "Acme Org"

# Get the latest CVE map from Red Hat and copy it to the Foreman directory so that it can be used by the Foreman CVE plugin to determine which CVEs are applicable to the registered hosts.
curl -o cvemap.xml https://security.access.redhat.com/data/meta/v1/cvemap.xml
cp cvemap.xml /var/lib/foreman/

# Download the tailoring file.
wget -O /tmp/rhel10-stig-sshd-tailoring.xml https://raw.githubusercontent.com/rhpds/zt-satellite-compliance/main/rhel10-stig-sshd-tailoring.xml
