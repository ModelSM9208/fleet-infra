#!/bin/bash
set -e

# -------------------------------
# Usage:
#   ./push-to-registry.sh <docker-image> <k8s-deployment> [namespace]
# Example:
#   ./push-to-registry.sh pihole/pihole:latest pihole default
# -------------------------------

IMAGE="$1"
DEPLOYMENT="$2"
NAMESPACE="${3:-default}"

if [[ -z "$IMAGE" || -z "$DEPLOYMENT" ]]; then
  echo "Usage: $0 <docker-image> <k8s-deployment> [namespace]"
  exit 1
fi

# Tag the image for local registry
REGISTRY_IMAGE="registry.local/${IMAGE}"
echo "Tagging $IMAGE → $REGISTRY_IMAGE"
docker tag "$IMAGE" "$REGISTRY_IMAGE"

# Push to local registry
echo "Pushing $REGISTRY_IMAGE..."
docker push "$REGISTRY_IMAGE"

# Restart Kubernetes deployment to pick up new image
if kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" &>/dev/null; then
  echo "Restarting deployment $DEPLOYMENT in namespace $NAMESPACE..."
  kubectl rollout restart deployment "$DEPLOYMENT" -n "$NAMESPACE"
else
  echo "Warning: Deployment $DEPLOYMENT not found in namespace $NAMESPACE"
fi

echo "✅ Done. $DEPLOYMENT should now be using $REGISTRY_IMAGE"
