# 📊 Hybrid Cloud & On-Premises Observability Platform

This repository contains the Infrastructure as Code (IaC), deployment configurations, and architecture documentation for a centralized, multi-cloud monitoring stack. It bridges public cloud infrastructure (Contabo VPS and AWS) with an on-premises homelab environment (Synology NAS, Kubernetes, OpenWRT Firewall) using a secure WireGuard overlay network.

The project demonstrates observability, hybrid networking, automated cloud provisioning, and configuration management.

## 🏗️ Architecture Overview

The monitoring core is hosted externally on a Contabo VPS, ensuring the observability plane remains decoupled from the infrastructure it monitors. To secure telemetry data across the public internet, a WireGuard hub-and-spoke network (10.10.0.0/24)—with the Contabo VPS acting as the hub—connects the Contabo VPS directly to the local on-premises network and provisioned AWS cloud environments. 

Prometheus scrapes metrics exclusively across this private encrypted tunnel, completely hiding telemetry endpoints from the public internet.

### Topology
* **Monitoring Core (Contabo VPS):** Prometheus, Alertmanager, Grafana, Caddy (Reverse Proxy).
* **Cloud Compute (AWS):** EC2 instances (Ubuntu 24.04) provisioned via Terraform, running containerized web workloads and `node_exporter`.
* **On-Premises Storage & Compute (Homelab):** Synology NAS and Kubernetes Cluster (monitored via `node_exporter` and `kube-state-metrics`).
* **On-Premises Network Edge (Homelab):** OpenWRT Firewall and WiFi-connected devices (monitored via `snmp_exporter`).

## 🛠️ Technology Stack

* **Infrastructure as Code (IaC):** Terraform (AWS Provider, S3 Remote State Backend with `use_lockfile` state locking for Terraform 1.10+)
* **Configuration Management:** Ansible (Generated Static Inventory, Jinja2 Templating, OS Hardening including SSH key-only login, UFW default-deny, unattended-upgrades, and fail2ban)
* **Metrics Engine:** Prometheus
* **Visualization:** Grafana
* **Exporters:** `node_exporter` (Linux/Synology/AWS), `snmp_exporter` (OpenWRT), `kube-state-metrics` (K8s)
* **Networking & Security:** WireGuard (Multi-Cloud Hub-and-Spoke VPN), Caddy (Automated TLS / Reverse Proxy)
* **Containerization:** Docker Compose

## ✨ Key Features & Engineering Highlights

### 1. Automated IaC Lifecycle & Handoff
AWS cloud infrastructure (VPC, Subnets, Security Groups, EC2) is provisioned via Terraform with strict input validation and least-privilege security groups. Terraform utilizes the `hashicorp/local` provider to generate an Ansible static inventory file containing live AWS public/private IP addresses, enabling a direct handoff from infrastructure provisioning to OS configuration.

### 2. Secure Multi-Cloud Hybrid Networking (WireGuard)
Rather than exposing internal device metrics or cloud node telemetry to the public internet, a WireGuard hub-and-spoke topology encrypts all traffic between the external Contabo VPS hub, the AWS EC2 workloads, and the internal homelab. Security groups and firewalls are strictly configured to allow Prometheus scrapes (Port 9100) only via internal `10.10.0.x` IP addresses. Prometheus (9090) and Alertmanager (9093) are intentionally not reachable through the Caddy reverse proxy; only Grafana is exposed publicly.

### 3. Multi-Protocol Telemetry Ingestion
The stack integrates modern cloud-native metric scraping with legacy hardware polling:
* **Agent-Based:** `node_exporter` runs natively on the Synology NAS, Kubernetes nodes, and AWS EC2 instances to provide deep CPU, memory, and I/O metrics.
* **Agentless (SNMP):** An intermediate `snmp_exporter` container polls the OpenWRT edge firewall via UDP 161, converting legacy SNMP MIBs into PromQL-queryable time-series data.

### 4. Public "Recruiter Mode" Dashboards
Selected dashboards are published as Grafana externally shared dashboards. They run only their saved queries, with no login and no access to Explore, data sources, or the rest of the instance. Anonymous org access is disabled. I originally used anonymous Viewer access and found it exposed every data source query, not just the dashboards, so I migrated to shared dashboards and upgraded to Grafana 13.

### 5. Proactive Alerting
Alertmanager is configured with customized PromQL rules to detect and notify on critical infrastructure events, such as:
* Synology NAS volume capacity exceeding 85%.
* Kubernetes Pods entering CrashLoopBackOff.
* High CPU/Memory saturation on the OpenWRT edge firewall or AWS EC2 instances.

### 6. Strict Secrets Management
No `.tfstate`, `.tfvars`, WireGuard private keys, or `.env` files are committed to the repository or exist in its history. Sensitive credentials and keys are encrypted and stored using Ansible Vault.

## 🚀 Deployment

The environment is built for reproducibility using Terraform and Ansible to ensure rapid disaster recovery.

1. **Provision Cloud Infrastructure (Terraform):**
   Execute `terraform apply` in the `terraform/environments/dev` directory to build the AWS VPC, security groups, and EC2 compute instances. This automatically populates the Ansible inventory.
2. **Apply Baseline OS & Network Configuration (Ansible):**
   Run `ansible-playbook configure-host.yml` to harden the Ubuntu OS, install dependencies, and configure the Docker daemon on the cloud nodes.
3. **Establish the Hybrid Network (WireGuard):**
   Run `ansible-playbook setup-wireguard.yml` to inject templated WireGuard configurations and connect the AWS nodes securely to the Contabo observability plane.
4. **Deploy Workloads & Exporters:**
   Run `ansible-playbook deploy-workload.yml` to distribute containerized applications and `node_exporter` across the endpoints.
5. **Launch Monitoring Core:**
   Execute `docker-compose up -d` on the Contabo VPS to spin up Prometheus, Grafana, and Caddy with provisioning files pre-loaded.
