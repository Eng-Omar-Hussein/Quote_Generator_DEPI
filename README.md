# Monitoring a Containerized URL Shortener Webservice

## 👥 Team Members
- Tasneem Mohsen – (Backend & API)
- Amira Hatem –   (Backend & API)
- Omar Huissein – (Dockarization)
- Ahmed Bakry – (Grafana & Documentation)
- Malak Yasser  – (prometheus)

---

## 📌 Project Idea
A simple **URL shortener webservice** that:
- Shortens long URLs into short codes.
- Redirects short codes to their original URLs.
- Exposes **custom Prometheus metrics** for monitoring.
- Uses **Grafana dashboards** for visualization.

The project is fully containerized and runs locally using **Docker Compose**.

---

## 🗂️ Project Plan

### **Week 1 – Build & Containerize**
- Develop the webservice with two endpoints:
  - `POST /shorten` → Accepts a long URL and returns a short code.
  - `GET /<short_code>` → Redirects to the original URL.
- Store mappings in SQLite.
- Write Dockerfile.
- Initial docker-compose.yml to run the service.

### **Week 2 – Instrument with Prometheus Metrics**
- Add custom metrics:
  - Counter: number of URLs shortened.
  - Counter: number of successful redirects.
  - Counter: failed lookups (404).
  - Histogram: request latency.
- prometheus.yml configuration.
- Integrate Prometheus into docker-compose.yml.

### **Week 3 – Visualization with Grafana**
- Add Grafana to docker-compose.yml.
- Connect Grafana to Prometheus.
- Create a dashboard:
  - URL creation & redirect rates over time.
  - Total shortened links (single stat).
  - 95th percentile latency.
  - 404 error rate.

### **Week 4 – Alerting & Persistence**
- Configure Grafana alerts (e.g., high latency, 404 spikes).
- Add Docker volumes for SQLite, Prometheus, Grafana.
- Verify data persistence after restart.
- Final testing + documentation.

---
