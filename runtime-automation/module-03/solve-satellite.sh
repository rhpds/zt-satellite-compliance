#!/bin/sh
echo "Solving module-03" >> /tmp/progress.log

ORG="Acme Org"

# Create activation key for RHEL10 content view
hammer activation-key create \
  --name "RHEL10" \
  --organization "$ORG" \
  --lifecycle-environment "Library" \
  --content-view "RHEL10"

hammer activation-key content-override \
    --name "RHEL10" \
    --content-label satellite-client-6-for-rhel-10-x86_64-rpms \
    --override-name enabled \
    --value 1 \
    --organization "Acme Org"

echo "Solved module-03" >> /tmp/progress.log
