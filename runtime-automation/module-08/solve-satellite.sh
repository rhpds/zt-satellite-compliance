#!/bin/sh
echo "Solving module-08" >> /tmp/progress.log

# Run Ansible roles on rhel1.lab and rhel2.lab via remote execution
hammer job-invocation create \
  --job-template "Ansible Roles - Ansible Default" \
  --search-query "name = rhel1.lab"

hammer job-invocation create \
  --job-template "Ansible Roles - Ansible Default" \
  --search-query "name = rhel2.lab"

echo "Solved module-08" >> /tmp/progress.log
