#!/bin/sh
echo "Solving module-02" >> /tmp/progress.log

ORG="Acme Org"

# Create the RHEL10 content view
hammer content-view create \
  --name "RHEL10" \
  --organization "$ORG"

# Add BaseOS repository
hammer content-view add-repository \
  --name "RHEL10" \
  --organization "$ORG" \
  --product "Red Hat Enterprise Linux for x86_64" \
  --repository "Red Hat Enterprise Linux 10 for x86_64 - BaseOS RPMs 10"

# Add AppStream repository
hammer content-view add-repository \
  --name "RHEL10" \
  --organization "$ORG" \
  --product "Red Hat Enterprise Linux for x86_64" \
  --repository "Red Hat Enterprise Linux 10 for x86_64 - AppStream RPMs 10"

# Add Satellite Client 6 repository
hammer content-view add-repository \
  --name "RHEL10" \
  --organization "$ORG" \
  --product "Red Hat Enterprise Linux for x86_64" \
  --repository "Red Hat Satellite Client 6 for RHEL 10 x86_64 RPMs"

# Publish the content view
hammer content-view publish \
  --name "RHEL10" \
  --organization "$ORG"

echo "Solved module-02" >> /tmp/progress.log
