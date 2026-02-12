#!/bin/bash

# Check if correct number of arguments provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <namespace> <service-name>"
    exit 1
fi

NAMESPACE=$1
SERVICE_NAME=$2

# Create TLS secret
kubectl -n "$NAMESPACE" create secret tls "${SERVICE_NAME}-tls" \
  --cert="${SERVICE_NAME}.local.pem" \
  --key="${SERVICE_NAME}.local-key.pem"