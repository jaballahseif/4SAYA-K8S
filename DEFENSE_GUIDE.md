# 4SAYA-K8S Project Defense Guide
**"The Script" for your presentation.**

---

## 🚀 Phase 1: Deployment (The "Wow" Factor)

**Evaluator:** "Show me how you deploy this."

**You:**
1.  "We use **OpenStack Heat** for Infrastructure-as-Code to provision the VMs."
2.  "We use a **local Python Artifact Server** to host our project code securely."
3.  "The Heat template automatically triggers **Ansible** to configure Kubernetes, Nginx, and Monitoring."

**Action:**
1.  **Start Artifact Server (if not running):**
    ```bash
    # On your laptop/jumpbox (where 4SAYA-K8S.tar.gz is)
    python3 -m http.server 9000
    ```
2.  **Launch Stack:**
    ```bash
    openstack stack create -t heat-template.yml stack-final
    ```

**(Wait 5-7 minutes for full deployment)**.
*While waiting, you can explain:* "The master node is currently installing Docker, Kubernetes, and initializing the cluster. Then it will join the worker nodes and deploy the monitoring stack."

---

## 🔍 Phase 2: Verify Components

**Evaluator:** "Prove the cluster is running."

**Action (SSH into Master):**
```bash
ssh ubuntu@<MASTER_IP>
```

**1. Show Nodes (3pts):**
```bash
kubectl get nodes
```
*   **Expect:** `k8s-master`, `k8s-worker-1`, `k8s-worker-2` all `Ready`.

**2. Show Pods (2pts):**
```bash
kubectl get pods -A
```
*   **Expect:**
    *   `kube-system` pods (coredns, flannel, etc.)
    *   `monitoring` pods (prometheus-0/1, grafana, alertmanager)
    *   `default` pods (nginx-app-xxx, cpu-stress-test)

**You:** "All systems are green. We have a 3-node cluster with HA Prometheus and a sample Nginx app."
_(Note: Point out `prometheus-0` and `prometheus-1` to show High Availability)._

---

## 🌐 Phase 3: Verify Nginx App

**Evaluator:** "Is the application actually accessible?"

**Action:**
1.  **Curl Test:**
    ```bash
    curl http://localhost:30080
    ```
    *   **Expect:** `<title>Welcome to nginx!</title>`

2.  **Browser Test (if possible):**
    `http://<ANY_NODE_IP>:30080`

---

## 🛡️ Phase 4: Self-Healing Demo (Bonus Points)

**Evaluator:** "What happens if a pod crashes?"

**Action:**
1.  **List Nginx Pods:**
    ```bash
    kubectl get pods -l app=nginx -o wide
    ```
2.  **Delete One:**
    ```bash
    kubectl delete pod <POD_NAME>
    ```
3.  **Watch it come back:**
    ```bash
    kubectl get pods -l app=nginx -o wide
    ```
    *   **Expect:** A new pod starts instantly (`Age: 5s`).

**You:** "Kubernetes automatically detected the failure and replaced the pod to maintain our desired state of 3 replicas."

---

## 📊 Phase 5: Monitoring (Prometheus & Grafana)

**Evaluator:** "Show me the monitoring metrics."

**Action:**
1.  **Open Grafana:**
    `http://<ANY_NODE_IP>:32000`
    *   **Login:** `admin` / `admin`
2.  **View Dashboard:**
    *   Search/Go to **"Kubernetes / Compute Resources / Pod"**
    *   Select `Namespace: default`
    *   Select `Pod: nginx-app-xxxx`
    *   **Show:** "Look, here is the CPU and Memory usage for our application."

---

## 🚨 Phase 6: Alerting (The Grand Finale)

**Evaluator:** "Show me an alert firing."

**You:** "The playbook automatically deployed a **Stress Test Pod** that generates high CPU load. This should trigger our `HighPodCPU` alert."

**Action:**
1.  **Verify Stress Pod is Running:**
    ```bash
    kubectl get pod cpu-stress-test
    ```
    *(Should be Running)*

2.  **Open Alertmanager:**
    `http://<ANY_NODE_IP>:31000`

3.  **Show the Alert:**
    *   Click on **"Alerts"**.
    *   Look for **`HighPodCPU`** (Severity: `warning`).
    *   *Expand it:* "It says 'Pod cpu-stress-test is using more than 0.1 CPU cores'."

**You:** "The system detected the high load and fired the alert automatically. We configured the threshold to 0.1 CPU for this demonstration."

---

## 📈 Phase 6.5: HPA & Autoscaling (AI Scenario)

**Evaluator:** "Show me the cluster scaling automatically based on load."

**You:** "We implemented a **Horizontal Pod Autoscaler (HPA)** that monitors CPU usage. When load increases, it automatically adds more pods to handle the traffic."

**Action:**
1.  **Verify Metrics Server:**
    ```bash
    kubectl top nodes
    ```
    *(Expect: CPU/Memory usage stats for all nodes)*

2.  **Run the Automated Demo:**
    ```bash
    cd /root
    ./hpa-demo.sh
    ```
    *   This script will:
        *   Deploy a PHP-Apache app.
        *   Generate artificial load.
        *   Watch the HPA scale up the pods in real-time.

3.  **Manual Check (if needed):**
    ```bash
    kubectl get hpa -w
    ```
    *   **Watch:** `REPLICAS` go from `1` -> `4` -> `8` -> `10`.
    *   **Watch:** `TARGET` go from `0%/50%` to `200%/50%`.

**You:** "As you can see, the HPA detected the spike in CPU usage and scaled the replicas up to the maximum limit of 10 to maintain performance."

---

## 🧹 Phase 7: Cleanup (Optional)

**Action:**
```bash
# Stop the stress test
kubectl delete pod cpu-stress-test

# Delete the stack
openstack stack delete stack-final
```

---

## 📝 "Cheat Sheet" for Common Issues

| Issue | Command to Check | Quick Fix |
| :--- | :--- | :--- |
| **Prometheus Pods Pending** | `kubectl get pvc -n monitoring` | Run `kubectl apply -f /tmp/manual-sc.yml` (should be auto now) |
| **Alert Not Firing** | `kubectl top pod cpu-stress-test` | `kubectl delete pod cpu-stress-test` then `kubectl apply -f /tmp/stress-test.yml` |
| **Nginx Not Loading** | `kubectl get svc nginx-service` | Ensure port is 30080 |
| **HPA Not Scaling** | `kubectl describe hpa` | Check if Metrics Server is running & patched |

---

## 🆘 Appendix: Emergency Manual HPA Setup
**ONLY use this if the automated playbook fails during the demo.**

### 1. Install & Patch Metrics Server manually
```bash
# Download
curl -L https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -o metrics-server.yaml

# Apply
kubectl apply -f metrics-server.yaml

# Patch for Lab Environment (Insecure TLS)
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

### 2. Deploy Demo App & HPA manually
*Run these `cat` commands to create the files if they are missing or broken.*

**Create App Manifest:**
```bash
cat <<EOF > php-apache-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
  namespace: default
  labels:
    app: php-apache
    scenario: ai-autoscaling
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  namespace: default
spec:
  selector:
    app: php-apache
  ports:
  - port: 80
  type: ClusterIP
EOF
kubectl apply -f php-apache-app.yaml
```

**Create HPA Manifest:**
```bash
cat <<EOF > hpa-config.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
      policies:
      - type: Percent
        value: 50
        periodSeconds: 15
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 2
        periodSeconds: 15
      selectPolicy: Max
EOF
kubectl apply -f hpa-config.yaml
```

**Run Demo:**
```bash
cp ~/4SAYA-K8S/roles/hpa_autoscaling/files/hpa-demo.sh /root/hpa-demo.sh
chmod +x /root/hpa-demo.sh
/root/hpa-demo.sh
```
