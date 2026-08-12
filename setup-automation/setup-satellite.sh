#!/bin/bash

# Unregister Satellite server from itself.
subscription-manager unregister

# Delete Satellite from its inventory.
hammer host delete --name satellite.lab

# Delete the Activation Key created for the Satellite server.
hammer activation-key delete --name "Satellite Server" --organization "Acme Org"

# Create an Activation Key for RHEL 10 content, which will be used by the RHEL 10 client system to register to Satellite and receive the RHEL 10 content.
hammer activation-key create --name "RHEL10" --organization "Acme Org" --lifecycle-environment "Library" --content-view "Default Organization View"

# Create a host registration script.
SAT_HOST_REGISTRATION_SCRIPT=$(hammer host-registration generate-command \
  --organization "Acme Org" \
  --location "Vancouver" \
  --activation-keys "RHEL10" \
  --insecure true \
  --force true \
  --setup-insights true \
  --setup-remote-execution true)

ssh root@rhel1.lab bash -c "$SAT_HOST_REGISTRATION_SCRIPT"

# Trigger vulnerability - install packages with known CVEs
# openssl-3.5.1-4.el10_1 is vulnerable to RHSA-2026:1472 (CVE-2025-11187, CVE-2025-15467, CVE-2025-15468, CVE-2026-22795, CVE-2026-22796)
# libvpx-1.14.1-4.el10 is vulnerable to RHSA-2026:4629 (CVE-2026-2447 - heap buffer overflow)
ssh root@rhel1.lab "dnf install -y openssl-3.5.1-4.el10_1 openssl-libs-3.5.1-4.el10_1 --allowerasing 2>/dev/null || true"
ssh root@rhel1.lab "dnf install -y libvpx-1.14.1-4.el10 --allowerasing 2>/dev/null || true"

# Trigger vulnerability - downgrade packages with known CVEs
ssh root@rhel1.lab "dnf downgrade -y gnutls 2>/dev/null || true"
ssh root@rhel1.lab "dnf install -y tar-1.35-8.el10_1 --allowerasing 2>/dev/null || dnf downgrade -y tar 2>/dev/null || true"

# Get the latest CVE map from Red Hat and copy it to the Foreman directory so that it can be used by the Foreman CVE plugin to determine which CVEs are applicable to the registered hosts.
curl -o cvemap.xml https://security.access.redhat.com/data/meta/v1/cvemap.xml
cp cvemap.xml /var/lib/foreman/

# Refresh Red Hat Lightspeed
ssh root@rhel1.lab "insights-client"
