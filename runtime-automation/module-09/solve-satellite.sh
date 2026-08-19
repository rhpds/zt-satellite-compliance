#!/bin/sh
echo "Solving module-09" >> /tmp/progress.log

HOST="rhel1.lab"
RULE_ID="xccdf_org.ssgproject.content_rule_sshd_disable_empty_passwords"

# Give the client a moment to finish syncing SCAP content/tailoring files from
# the proxy after registration and the Ansible role run (module-07/module-08).
# foreman_scap_client writes whatever the proxy returns straight to
# /var/lib/openscap/content/<digest>.xml without validating it's well-formed
# XML, so if the scan runs before content has propagated the client caches a
# bad response and every scan after that fails with "Start tag expected".
sleep 30

# Run an OpenSCAP scan on rhel1.lab, retrying once if the content wasn't
# ready yet on the first attempt.
ATTEMPT=1
MAX_ATTEMPTS=2
while [ "$ATTEMPT" -le "$MAX_ATTEMPTS" ]; do
    OUTPUT=$(hammer job-invocation create \
      --job-template "Run OpenSCAP scans - Ansible Default" \
      --search-query "name = $HOST" 2>&1)
    echo "$OUTPUT" >> /tmp/progress.log

    if ! echo "$OUTPUT" | grep -qi "Start tag expected\|Scan failed\|oscap_source.c"; then
        break
    fi

    echo "Detected stale/corrupt SCAP content on $HOST, clearing cache and retrying" >> /tmp/progress.log
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$HOST" \
        "rm -f /var/lib/openscap/content/*.xml /var/lib/openscap/tailoring/*.xml" 2>/dev/null

    ATTEMPT=$((ATTEMPT + 1))
    sleep 30
done

echo "Solved module-09" >> /tmp/progress.log
