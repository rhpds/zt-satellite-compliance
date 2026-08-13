#!/bin/sh
echo "Solving module-03" >> /tmp/progress.log

ORG="Acme Org"

# Create activation key for RHEL10 content view
hammer activation-key create \
  --name "RHEL10" \
  --organization "$ORG" \
  --lifecycle-environment "Library" \
  --content-view "RHEL10"

echo "Solved module-03" >> /tmp/progress.log
