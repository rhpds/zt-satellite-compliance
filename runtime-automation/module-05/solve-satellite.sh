#!/bin/sh
echo "Solving module-05" >> /tmp/progress.log

# Upload default SCAP contents to Satellite
hammer scap-content bulk-upload --type default

# Import the OpenSCAP client Ansible role and variables
hammer ansible roles import --proxy-id 1 --role-names theforeman.foreman_scap_client
hammer ansible variables import --proxy-id 1

# Import the STIG sshd tailoring file
hammer tailoring-file create \
    --name "STIG SSHD Tailoring file" \
    --scap-file /tmp/rhel10-stig-sshd-tailoring.xml \
    --organizations "Acme Org" \
    --locations "Vancouver"

echo "Solved module-05" >> /tmp/progress.log
