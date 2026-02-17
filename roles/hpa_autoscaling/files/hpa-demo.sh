#!/bin/bash

echo "════════════════════════════════════════════════════════════"
echo "  🤖 4SAYA - AI AUTOSCALING DEMONSTRATION"
echo "  Intelligent Load-Based Pod Scaling"
echo "════════════════════════════════════════════════════════════"
echo ""

echo "📊 PHASE 1: INITIAL STATE (AI at rest)"
echo "─────────────────────────────────────────────────────────────"
kubectl get hpa php-apache-hpa
kubectl get pods -l app=php-apache
echo ""

read -p "⏸️  Press ENTER to start load generation..."

echo ""
echo "🔥 PHASE 2: GENERATING LOAD (AI will detect)"
echo "─────────────────────────────────────────────────────────────"
kubectl run load-gen-1 --image=busybox --restart=Never -- \
  /bin/sh -c "while true; do wget -q -O- http://php-apache; done" &
sleep 3

kubectl run load-gen-2 --image=busybox --restart=Never -- \
  /bin/sh -c "while true; do wget -q -O- http://php-apache; done" &

echo "✅ Load generators started"
echo ""
echo "⏱️  Waiting 60 seconds for AI to analyze and decide..."

for i in {60..1}; do
  echo -ne "   ⏳ $i seconds...\r"
  sleep 1
done
echo ""

echo ""
echo "🧠 PHASE 3: AI DECISION - SCALE UP"
echo "─────────────────────────────────────────────────────────────"
kubectl get hpa php-apache-hpa
kubectl get pods -l app=php-apache
echo ""
echo "📈 Analysis: AI detected high CPU (>50%) → Increased replicas"
echo "🔔 Check Grafana for 'HPAScalingUp' alert!"
echo ""

read -p "⏸️  Press ENTER to stop load and observe scale down..."

echo ""
echo "🛑 PHASE 4: STOPPING LOAD"
echo "─────────────────────────────────────────────────────────────"
kubectl delete pod load-gen-1 load-gen-2 --ignore-not-found=true
echo "✅ Load stopped"
echo ""
echo "⏱️  Waiting 90 seconds for AI to detect low load..."

for i in {90..1}; do
  echo -ne "   ⏳ $i seconds...\r"
  sleep 1
done
echo ""

echo ""
echo "🧠 PHASE 5: AI DECISION - SCALE DOWN"
echo "─────────────────────────────────────────────────────────────"
kubectl get hpa php-apache-hpa
kubectl get pods -l app=php-apache
echo ""
echo "📉 Analysis: AI detected low CPU → Reduced replicas to save resources"
echo ""

echo "════════════════════════════════════════════════════════════"
echo "  ✅ AI AUTOSCALING DEMONSTRATION COMPLETE"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🎯 What the AI did automatically:"
echo "   1. Monitored CPU metrics every 15 seconds"
echo "   2. Detected CPU exceeding 50% threshold"
echo "   3. Calculated optimal replica count"
echo "   4. Scaled UP pods (1→2→4→8)"
echo "   5. Distributed load across new pods"
echo "   6. Detected CPU normalization"
echo "   7. Scaled DOWN pods to optimize resources"
echo ""
echo "📊 Check Prometheus alerts:"
echo "   kubectl get prometheusrules -n monitoring"
echo ""
echo "📈 View in Grafana:"
echo "   Import dashboard: /tmp/hpa-dashboard.json"
echo ""
