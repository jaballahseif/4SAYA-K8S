#!/bin/bash
kubectl delete pod load-generator --ignore-not-found=true
kubectl delete pod load-gen-1 load-gen-2 --ignore-not-found=true
echo "✅ All load generators stopped"
