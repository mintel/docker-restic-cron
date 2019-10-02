#!/bin/bash

echo "You must define an Entrypoint for this image"
echo "Maybe you wanted to run:"
echo "  /usr/local/bin/supercronic -prometheus-listen-address 0.0.0.0:8888 /etc/crontabs/crontab'?"
echo ""
echo "Or maybe you wanted to run:"
echo "  /usr/local/bin/kubelock -name ENDPOINTNAME -namespace NAMESPACE COMMAND"

sleep 3600
