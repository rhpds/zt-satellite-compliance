#!/bin/sh
echo "Solving module-07" >> /tmp/progress.log

# Generate host registration command using the RHEL10 host group
SAT_HOST_REGISTRATION_SCRIPT=$(hammer host-registration generate-command \
  --hostgroup "RHEL10" \
  --insecure true \
  --force true \
  --setup-insights true \
  --setup-remote-execution true)

# Register rhel1 to Satellite
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@rhel1.lab bash -c "$SAT_HOST_REGISTRATION_SCRIPT"

echo "Solved module-07" >> /tmp/progress.log
