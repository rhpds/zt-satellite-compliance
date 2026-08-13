#!/bin/sh
echo "Solving module-04" >> /tmp/progress.log

ORG="Acme Org"

# Create host group with content source, lifecycle environment, content view, and OpenSCAP capsule
hammer hostgroup create \
  --name "RHEL10" \
  --organization "$ORG" \
  --content-source "satellite.lab" \
  --lifecycle-environment "Library" \
  --content-view "RHEL10" \
  --openscap-proxy "satellite.lab"

# Assign the foreman_scap_client Ansible role
hammer hostgroup ansible-roles assign \
  --hostgroup "RHEL10" \
  --ansible-roles "theforeman.foreman_scap_client"

# Set the activation key
hammer hostgroup set-parameter \
  --hostgroup "RHEL10" \
  --name "kt_activation_keys" \
  --parameter-type "string" \
  --value "RHEL10"

echo "Solved module-04" >> /tmp/progress.log
