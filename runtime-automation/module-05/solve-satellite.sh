#!/bin/sh
echo "Solving module-05" >> /tmp/progress.log

ORG="Acme Org"

# Create a host group
hammer hostgroup create \
  --name "RHEL10" \
  --organization "$ORG" \
  --lifecycle-environment "Library" \
  --content-view "RHEL10" \
  --architecture "x86_64" \
  --operatingsystem "RHEL 10"

echo "Solved module-05" >> /tmp/progress.log
