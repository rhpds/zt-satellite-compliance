#!/bin/sh
echo "Solving module-05" >> /tmp/progress.log

ORG="Acme Org"

# Get the Satellite capsule ID for OpenSCAP proxy
CAPSULE_ID=$(hammer --no-headers capsule list --search "name = satellite.lab" --fields id | tr -d ' ')

# Create host group with content source, lifecycle environment, content view, and OpenSCAP capsule
hammer hostgroup create \
  --name "RHEL10" \
  --organization "$ORG" \
  --content-source "satellite.lab" \
  --lifecycle-environment "Library" \
  --content-view "RHEL10" \
  --openscap-proxy-id "$CAPSULE_ID"

# Assign the foreman_scap_client Ansible role
hammer hostgroup ansible-roles assign \
  --name "RHEL10" \
  --ansible-roles "theforeman.foreman_scap_client"

# Set the activation key
hammer hostgroup set-parameter \
  --hostgroup "RHEL10" \
  --name "kt_activation_keys" \
  --parameter-type "string" \
  --value "RHEL10"

echo "Solved module-05" >> /tmp/progress.log
