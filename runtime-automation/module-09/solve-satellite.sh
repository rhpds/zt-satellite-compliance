#!/bin/sh
echo "Solving module-09" >> /tmp/progress.log

HOST="rhel1.lab"
RULE_ID="xccdf_org.ssgproject.content_rule_sshd_disable_empty_passwords"

# Run an OpenSCAP scan on rhel1.lab
hammer job-invocation create \
  --job-template "Run OpenSCAP scans - Ansible Default" \
  --search-query "name = $HOST"
