#!/bin/bash
watch -n 2 "echo '🤖 HPA Status:' && kubectl get hpa && echo '' && echo '📦 Pods:' && kubectl get pods -l app=php-apache"
