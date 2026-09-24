# 📊 Hybrid Cloud & On-Premises Observability Platform

This repository contains the deployment configurations and architecture documentation for a centralized monitoring stack. It bridges public cloud infrastructure (Contabo VPS) with an on-premises homelab environment (Synology NAS, Kubernetes, OpenWRT, HP Managed Switch) using a secure WireGuard overlay network.

The project demonstrates production-grade observability, hybrid networking, and Infrastructure as Code (IaC) practices.

## 🏗️ Architecture Overview

The monitoring core is hosted externally on a Contabo VPS, ensuring the observability plane remains decoupled from the infrastructure it monitors. To secure telemetry data across the public internet, a WireGuard tunnel connects the VPS directly to the local network. 

Prometheus scrapes metrics across this private tunnel, pulling from both native HTTP exporters (compute/storage) and an SNMP translation layer (legacy network hardware).

### Topology
* **Monitoring Core (Contabo VPS):** Prometheus, Alertmanager, Grafana, Caddy (Reverse Proxy).
* **Network Hardware (Homelab):** OpenWRT Firewall, HP 2530 Managed Switch (monitored via `snmp_exporter`).
* **Storage & Compute (Homelab):** Synology NAS and Kubernetes Cluster (monitored via `node_exporter` and `kube-state-metrics`).

## 🛠️ Technology Stack

* **Metrics Engine:** Prometheus
* **Visualization:** Grafana
* **Exporters:** `node_exporter` (Linux/Synology), `snmp_exporter` (Network Hardware), `kube-state-metrics` (K8s)
* **Networking & Security:** WireGuard (Site-to-Site VPN), Caddy (Automated TLS / Reverse Proxy)
* **Provisioning & Orchestration:** Ansible, Docker Compose

## ✨ Key Features & Engineering Highlights

### 1. Secure Hybrid Networking (WireGuard)
Rather than exposing internal device metrics to the public internet, a WireGuard mesh (`10.10.0.0/24`) encrypts all traffic between the external VPS and the internal homelab. Prometheus is configured to target internal `10.10.0.x` IP addresses exclusively.

### 2. Multi-Protocol Telemetry Ingestion
The stack seamlessly integrates modern cloud-native metric scraping with legacy hardware polling:
* **Agent-Based:** `node_exporter` runs natively on the Synology NAS (via Docker host-networking) and Kubernetes nodes to provide deep CPU, memory, and I/O metrics.
* **Agentless (SNMP):** An intermediate `snmp_exporter` container polls the OpenWRT router and HP Managed Switch via UDP 161, converting legacy SNMP MIBs into PromQL-queryable time-series data.

### 3. Public "Recruiter Mode" Dashboards (RBAC)
To allow prospective employers and technical evaluators to view live infrastructure telemetry without compromising administrative access:
* **Caddy** acts as an ingress gateway, automatically provisioning Let's Encrypt SSL certificates.
* **Grafana RBAC** is configured to allow anonymous users strictly into a read-only `Viewer` role. Visitors can explore dashboards, view active alerts, and inspect PromQL queries, but cannot alter configurations or data sources.

### 4. Proactive Alerting
Alertmanager is configured with customized PromQL rules to detect and notify on critical infrastructure events, such as:
* Synology NAS volume capacity exceeding 85%.
* HP Switch port link state drops.
* Kubernetes Pods entering `CrashLoopBackOff`.
* High CPU/Memory saturation on the OpenWRT edge firewall.

## 🚀 Deployment

The entire stack is containerized and deployed via Ansible to ensure immutability. 

1. **Bootstrap Infrastructure:** Run `ansible-playbook setup-wireguard.yml` to establish the encrypted tunnel between the VPS and homelab.
2. **Deploy Exporters:** Run `ansible-playbook deploy-exporters.yml` to distribute `node_exporter` and `snmp_exporter` across local endpoints.
3. **Launch Monitoring Core:** Execute `docker-compose up -d` on the VPS to spin up Prometheus, Grafana, and Caddy with provisioning files pre-loaded.

*(Note: Sensitive variables, credentials, and specific external IP addresses have been scrubbed or encrypted via Ansible Vault for this public repository.)*
