#!/bin/sh
echo "Solving module-06" >> /tmp/progress.log

ORG="Acme Org"

# Get the tailoring file profile ID (numeric, required by --tailoring-file-profile-id)
TAILORING_PROFILE_ID=$(hammer tailoring-file info --name "STIG SSHD Tailoring file" 2>/dev/null | awk '/Tailoring file profiles:/,0' | grep "Id:" | sed 's/.*Id:[[:space:]]*//' | head -1)

# Create the compliance policy
hammer policy create \
  --name "DISA STIG no empty passwords ssh" \
  --deploy-by "ansible" \
  --scap-content-id 1 \
  --scap-content-profile-id 15 \
  --tailoring-file "STIG SSHD Tailoring file" \
  --tailoring-file-profile-id "$TAILORING_PROFILE_ID" \
  --period "weekly" \
  --weekday "sunday" \
  --hostgroups "RHEL10" \
  --organizations "$ORG" \
  --locations "Vancouver"

echo "Solved module-06" >> /tmp/progress.log
