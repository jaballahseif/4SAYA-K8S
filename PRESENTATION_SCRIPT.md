# 4SAYA-K8S Project Defense - 7 Member Team Script
**Total Time: ~15 Minutes**

---

## 🎭 Roles & Responsibilities

| # | Role Name | Focus Area | Member Name |
|---|-----------|------------|-------------|
| **1** | **Team Lead / Architect** | Intro, Architecture, Project Goals | *[Member 1]* |
| **2** | **Infrastructure Engineer** | OpenStack Heat, Networking, Storage | *[Member 2]* |
| **3** | **Automation Engineer** | Ansible Playbooks, Inventory, Roles | *[Member 3]* |
| **4** | **Cluster Administrator** | Kubernetes Nodes, CNI, Components | *[Member 4]* |
| **5** | **DevOps Engineer** | Application Deployment, Nginx, Services | *[Member 5]* |
| **6** | **Site Reliability Engineer (SRE)** | Monitoring, Grafana, Dashboards | *[Member 6]* |
| **7** | **AI & Scalability Expert** | Alerting, Self-Healing, Autoscaling (HPA) | *[Member 7]* |

---

## 🎤 The Script

### Part 1: Introduction & Infrastructure (Members 1 & 2)

**[Member 1 - Team Lead]:**
"Good morning via everyone. We are Team 4SAYA. Our project is to design and automate a production-grade Kubernetes cluster on OpenStack."
"We moved beyond simple manual installation. We built a **Fully Automated Infrastructure-as-Code pipeline** that provisions hardware, configures the OS, installs Kubernetes, and deploys a full monitoring stack with zero human intervention."
"I will now hand it over to [Member 2] to explain our Infrastructure layer."

**[Member 2 - Infrastructure Engineer]:**
"Thank you. Our foundation is built on **OpenStack Heat**. We created a template that defines our entire data center in code."
"Please observe our 'stack-create' command."
*(Action: Point to the terminal/Heat dashboard)*
"This template provisions:
1.  **Networking**: A private 10.0.x.x subnet with a router to the external world.
2.  **Storage**: Cinder volumes attached to each node for persistent data.
3.  **Compute**: 1 Master node and 2 Worker nodes (Ubuntu 24.04).
"Crucially, we use `user_data` scripts to inject SSH keys and trigger the automation immediately upon boot."

---

### Part 2: Automation & Cluster Setup (Members 3 & 4)

**[Member 3 - Automation Engineer]:**
"Once the VMs are up, **Ansible** takes over. We don't SSH into servers manually."
"We structured our automation into modular **Roles**:
*   `common`: Installs Docker/Containerd on all nodes.
*   `master`: Initializes the Control Plane (`kubeadm init`).
*   `worker`: Joins the nodes to the cluster (`kubeadm join`)."
"This ensures our deployment is reproducible. If we destroy the cluster now, we can rebuild it exactly the same way in 10 minutes."

**[Member 4 - Cluster Administrator]:**
"Let's look at the resulting cluster."
*(Action: Run `kubectl get nodes`)*
"You can see we have 3 nodes in a `Ready` state. We chose **Flannel** as our CNI (Container Network Interface) to handle pod networking."
*(Action: Run `kubectl get pods -A`)*
"All core components—`kube-apiserver`, `etcd`, `coredns`—are healthy. We also configured `kube-proxy` to handle service traffic effectively across the worker nodes."

---

### Part 3: Applications & DevOps (Member 5)

**[Member 5 - DevOps Engineer]:**
"A cluster is useless without applications. I was responsible for the Deployment pipeline."
"We deployed a highly available **Nginx Web Server** with 3 replicas."
*(Action: Run `kubectl get pods -l app=nginx`)*
"You can see one pod running on each node for redundancy. We exposed this internally via a **Service** on NodePort 30080."
*(Action: Run `curl http://localhost:30080`)*
"The application is accessible. This proves our networking and service discovery are functioning correctly."

---

### Part 4: Monitoring & Observability (Member 6)

**[Member 6 - SRE]:**
"Running blind is dangerous. I implemented the **Prometheus & Grafana** monitoring stack."
"We used the `kube-prometheus-stack` to deploy:
1.  **Prometheus HA**: Two replicas for high availability logic.
2.  **Node Exporters**: To scrape metrics from every VM.
3.  **Grafana**: For visualization."
*(Action: Open Grafana Dashboard)*
"Here you can see real-time metrics: CPU usage, Memory consumption, and Network I/O for every single pod and node in the cluster. We have full visibility."

---

### Part 5: The Grand Finale - AI & Healing (Member 7)

**[Member 7 - AI & Scalability Expert]:**
"Finally, we added intelligence to the cluster. It's not just running; it's **self-healing and adaptive**."

**Scenario A: Self-Healing**
"If I delete a pod..." *(Action: Delete an nginx pod)*
"...Kubernetes instantly detects the state mismatch and spins up a new replacement. Zero downtime."

**Scenario B: AI Autoscaling (HPA)**
"We implemented a Horizontal Pod Autoscaler. It watches metric trends."
*(Action: Run `hpa-demo.sh`)*
"As you can see, when we artificially increase load, the cluster **automatically expands** from 1 pod to 10 pods to handle the traffic. Once the load drops, it scales back down to save resources."

**[Member 1 - Team Lead]:**
"To conclude: We have delivered a resilient, monitored, and automated Kubernetes platform that meets all requirements. We are ready for your questions. Thank you."
