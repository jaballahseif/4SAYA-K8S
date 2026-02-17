#!/bin/bash
echo "🔥 Starting load generation..."
kubectl run load-generator --image=busybox --restart=Never -- \
  /bin/sh -c "while true; do wget -q -O- http://php-apache; done"
echo "✅ Load started"
echo "👀 Monitor: watch kubectl get hpa"
echo "🛑 Stop: kubectl delete pod load-generator"
