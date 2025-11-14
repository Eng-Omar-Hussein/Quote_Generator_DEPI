# Quote Generator Service

A production-ready RESTful API for generating and managing inspirational quotes with built-in profanity filtering, Prometheus metrics, and Grafana visualization.

---

## 👥 Team Members
- **Tasneem Mohsen Mahmoud** – (Docker Compose)
- **Amira Hatem Anwar** – (Grafana)
- **Omar Hussien AbdelRadi** – (Prometheus)
- **Ahmed Mohamed Abdallah Ahmed Bakry** – (Docker & Documentation)
- **Malak Yasser Mohamed Ali** – (Kubernetes)

**Instructor:** Ahmed Gamil

---

## 📌 Project Idea

A simple **webservice** that:
- Generates and retrieves **random inspirational quotes**.
- Allows adding new quotes to a local **SQLite database**.
- **Filters out quotes** containing swear or inappropriate words using a profanity filter.
- Exposes **custom Prometheus metrics** for monitoring.
- Uses **Grafana dashboards** for visualization.

The entire stack is **containerized** and runs locally using **Docker Compose**.

---

## ✨ Features

### Core Features
- ✅ RESTful API with Express.js
- ✅ SQLite database with automatic seeding
- ✅ Real-time profanity filtering using `bad-words` library
- ✅ Prometheus metrics integration
- ✅ Grafana dashboards for visualization
- ✅ Docker containerization with multi-stage builds
- ✅ Docker Compose orchestration
- ✅ Health checks and graceful shutdown
- ✅ Non-root container user for security
- ✅ Data persistence with Docker volumes
- ✅ Modern React frontend with responsive design

---

## 🗂️ Project Plan

### **Week 1 – Build & Containerize**
- Develop the webservice with API endpoints:
  - `GET /quote` → Returns a random inspirational quote.
  - `POST /quote` → Accepts a new quote (text + author).
  - `GET /quotes` → Lists all quotes.
  - `DELETE /quote/:id` → Deletes a specific quote.
- Store quotes in SQLite database with views tracking.
- Implement profanity filter for content moderation.
- Write Dockerfile with multi-stage build.
- Initial docker-compose.yml to run the service.

### **Week 2 – Instrument with Prometheus Metrics**
- Add custom metrics:
  - Counter: number of quotes served (`quotes_served_total`).
  - Counter: number of quotes added (`quotes_added_total`).
  - Counter: profanity attempts blocked (`profanity_blocked_total`).
  - Histogram: request latency (`http_request_duration_seconds`).
  - Gauge: total quotes in database.
- Configure prometheus.yml for metrics scraping.
- Integrate Prometheus into docker-compose.yml.
- Add `/metrics` endpoint for Prometheus scraping.

### **Week 3 – Visualization with Grafana**
- Add Grafana to docker-compose.yml.
- Connect Grafana to Prometheus data source.
- Create a comprehensive dashboard:
  - Quotes served & added rates over time.
  - Total quotes in database (single stat).
  - Profanity blocking rate.
  - Request latency (95th percentile).
  - HTTP status code distribution.
- Design frontend React application for quote display and management.

### **Week 4 – Alerting & Persistence**
- Configure Grafana alerts:
  - High request latency (> 500ms).
  - Profanity blocking spike (> 10% of requests).
  - Service downtime detection.
- Add Docker volumes for SQLite, Prometheus, and Grafana data.
- Verify data persistence after container restart.
- Implement Kubernetes deployment manifests (optional).
- Final testing + comprehensive documentation.

---

## 🎯 Roles & Responsibilities

| Team Member | Role | Responsibilities |
|-------------|------|------------------|
| **Tasneem Mohsen** | Docker Compose | Service orchestration, container configuration |
| **Amira Hatem** | Grafana | Dashboard creation, visualization setup |
| **Omar Hussien** | Prometheus | Metrics collection, monitoring configuration |
| **Ahmed Bakry** | Docker & Documentation | Containerization, comprehensive documentation |
| **Malak Yasser** | Kubernetes | K8s deployment, scaling configuration |

---

## 🗄️ Database Design

The project uses **SQLite** as a lightweight embedded database.

### Table: `quotes`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER PRIMARY KEY | Auto-incrementing unique identifier |
| `text` | TEXT NOT NULL | Content of the quote (max 1000 chars) |
| `author` | TEXT NOT NULL | Person who said the quote (max 100 chars) |
| `views` | INTEGER DEFAULT 0 | Number of times the quote was retrieved |
| `created_at` | DATETIME | Timestamp (CURRENT_TIMESTAMP) |

**Data Validation:**
- All quotes are validated to exclude profanity and inappropriate words before storage
- Database file is persisted using Docker volumes at `/app/data/quotes.db`

---

## 📈 KPIs (Key Performance Indicators)

Metrics for project success:

### 1. Quote Generation Count
**Description:** Counts the total number of quotes successfully generated and served to users.  
**Metric:** `quotes_served_total`

### 2. Filtered Quotes Count
**Description:** Tracks how many quotes were rejected due to containing inappropriate or profane content.  
**Metric:** `profanity_blocked_total`

### Additional Metrics
- **Response Time:** Average API response time (< 100ms target)
- **System Uptime:** Service availability (> 99.9% target)
- **User Adoption Rate:** Number of active API consumers

---

## 🎯 Stakeholder Analysis

| Stakeholder | Role | Interest / Motivation | Influence |
|-------------|------|----------------------|-----------|
| **Project Manager** | Oversees project, manages timelines & risks | Timely delivery and stability | High |
| **Backend Developer** | Implements API, database, filtering logic | Clean, scalable, maintainable code | High |
| **Frontend Developer** | Integrates API endpoints | Stable API endpoints and clear docs | Medium |
| **End Users** | Consumers via apps, websites, bots | High-quality appropriate quotes | High |
| **Content Moderation Team** | Reviews/flags inappropriate content | Content complies with brand policies | Medium |
| **Marketing Team** | Uses API for promotional campaigns | High uptime and reliable variety | Medium |
| **DevOps Engineer** | Maintains deployment and database | Smooth deployment, scalability, uptime | High |

---

## 📊 Monitoring with Prometheus & Grafana

### Prometheus Metrics Exposed

- `quotes_served_total` - Total random quotes served
- `quotes_added_total` - Total quotes added
- `profanity_blocked_total` - Profanity attempts blocked
- `http_requests_total` - Total HTTP requests by endpoint and status
- `http_request_duration_seconds` - Request duration histogram
- System metrics (CPU, memory, event loop lag)

### Grafana Dashboards

Pre-configured dashboard showing:
- Quotes served over time
- Request rates and patterns
- Profanity blocking trends
- System resource usage
- Error rates and response times

**Access Grafana:** http://localhost:3001 (admin/admin)

---

## 🛠️ Tech Stack

### Backend
- **Node.js 18+** - JavaScript runtime
- **Express.js 4.x** - Web framework
- **SQLite3** - Embedded database
- **bad-words** - Profanity filter library
- **prom-client** - Prometheus metrics

### Frontend
- **React 18** - UI framework

### DevOps
- **Docker** - Containerization
- **Docker Compose** - Orchestration
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Kubernetes** - Production orchestration (optional)

---

## 📁 Project Structure

```
URL_Shortener_DEPI/
├── src/
│   ├── server.js              # Express server & initialization
│   ├── db.js                  # SQLite database operations
│   ├── routes.js              # API route handlers
│   └── profanityFilter.js     # Profanity detection
├── frontend/                   # React frontend application
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── pages/             # Page components
│   │   └── services/          # API client
│   ├── Dockerfile             # Frontend container
│   └── nginx.conf             # Nginx configuration
├── k8s/                       # Kubernetes manifests
├── data/                       # SQLite database (auto-created)
├── package.json               # Dependencies
├── Dockerfile                 # Backend Docker image
├── docker-compose.yml         # Basic service
├── docker-compose.monitoring.yml  # Full monitoring stack
├── prometheus.yml             # Prometheus configuration
└── README.md                  # This file
```

---

## 🔒 Security Features

1. **Input Validation**
   - Required field validation
   - Type checking
   - Length limits (text: 1000 chars, author: 100 chars)

2. **Profanity Filtering**
   - Automatic content filtering
   - Blocks inappropriate text and author names
   - Tracks blocked attempts in metrics

3. **Container Security**
   - Non-root user (nodejs:1001)
   - Minimal base image (Alpine Linux)
   - No unnecessary packages


---

## 🔗 Project Files

You can find the full project files here:  
[Google Drive Link](https://drive.google.com/drive/folders/1TkUkzulu4E4aL7a4uCEE_7vL0e1z4Iy_?usp=sharing)

---

## 📝 License

This project is licensed under the **GPL-3.0 License**.

---

## 🎉 Success Criteria

Your service is working correctly if:
1. ✅ `docker-compose up` starts without errors
2. ✅ Health check returns 200 OK
3. ✅ Can retrieve random quotes
4. ✅ Can add new quotes
5. ✅ Profanity filter blocks inappropriate content
6. ✅ Statistics show accurate counts
7. ✅ Metrics endpoint returns Prometheus format
8. ✅ Data persists after container restart
9. ✅ Frontend loads and displays quotes
10. ✅ Monitoring dashboards show data

---



**Need help?** Check the documentation or contact the team members listed above.