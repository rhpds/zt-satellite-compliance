#!/bin/sh
echo "Solving module-02" >> /tmp/progress.log

# Upload default SCAP contents to Satellite
hammer scap-content bulk-upload --type default

echo "Solved module-02" >> /tmp/progress.log
