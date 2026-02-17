#!/bin/bash
OUTPUT_FILE="data.json"
echo "🚀 Starting Dashboard Backend..."

while true; do
  # Get Data
  HPA_JSON=$(kubectl get hpa php-apache-hpa -o json 2>/dev/null || echo "{}")
  NODE_JSON=$(kubectl get nodes -o json 2>/dev/null || echo "{}")
  POD_JSON=$(kubectl get pods -l app=php-apache -o json 2>/dev/null || echo "{}")

  # Write JSON (Using simple echo to avoid syntax errors)
  echo "{\"hpa\": $HPA_JSON, \"nodes\": $NODE_JSON, \"pods\": $POD_JSON, \"lastUpdated\": \"$(date)\"}" > $OUTPUT_FILE

  echo "✅ Updated data.json at $(date)"
  sleep 2
done
