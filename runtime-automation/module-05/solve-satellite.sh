#!/bin/sh
echo "Solving module-05" >> /tmp/progress.log

# Upload default SCAP contents to Satellite
hammer scap-content bulk-upload --type default

echo "Solved module-05" >> /tmp/progress.log
