# 🔧 Content Distribution Platform Infrastructure: ~5K Sessions on a €5.8 VPS

![Infrastructure Grade](https://img.shields.io/badge/Grade-Production--Ready-brightgreen?style=for-the-badge&logo=kubernetes&logoColor=white)
![Redis Cache](https://img.shields.io/badge/Cache-Redis-red?style=for-the-badge&logo=redis)
![SSL](https://img.shields.io/badge/SSL-Certbot_Sidecar-blue?style=for-the-badge&logo=letsencrypt)
![CI/CD](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

**🪵 So... What's Up With This Repo?**

This repository contains the production-ready infrastructure blueprint (**NGINX, Redis, PHP-FPM, Docker, and GitHub Actions CI/CD**) that powers my live commercial website today. 

It is the direct architectural upgrade of my previous lab project: [WordPress on Docker: 5,000 Client Benchmark on 1GB RAM VPS (v2.0)](https://github.com/aleixnguyen-vn/docker-wordpress-performance). While version 2.0 was a cool lab experiment using Caddy, it suffered from a classic junior trap: **Overengineering**. After a year of running actual production traffic and optimizing infrastructure costs out of my own pocket, I rebuilt the entire stack for maximum resource efficiency.


## ⚡ 1. Live Production Context & Technical Constraints

This infrastructure holds together a live, high-traffic, database-heavy community catalog platform serving the global simracing community for **Assetto Corsa** (and yes, I am a Sim-Racer too 🦅). 

### 📊 Production & Financial Metrics


| Metric | Live Value |
| :--- | :--- |
| **Platform** | WordPress (Custom Theme / AI-Assisted Development) |
| **Server Specs** | **2 vCPU / 4GB RAM** Dedicated VPS (Upgraded) |
| **Infrastructure Cost** | **€5.78 / month** |
| **Live Traffic** | **4,000 - 5,000 Daily Sessions** (>7,000 daily visits) |
| **SEO Performance** | **62K Impressions / 12K Clicks** (Average month on Search Console) |
| **Financial Output** | **~$350 USD MRR** (Monthly Recurring Revenue) |
| **Storage Solution** | Images offloaded to **Imgur** + **Cloudflare CDN/Proxy** |

---

### 🚨 The DB Bottleneck & Structural Challenges

The website is a community catalog platform with over **2,000+ posts** in the database. All important post metadata is stored using **ACF (Advanced Custom Fields)**. Because it's a catalog, user behavior is brutal: they frequently open one category, search, and then middle-click to open 10–20 tabs simultaneously, triggering an insane amount of **AJAX queries for dynamic filtering and searching**. 

The database was under constant heavy fire. Standard shared hosting died instantly after deployment, which is why the architecture was migrated straight to a dedicated VPS from the beginning (1 year ago).

To be honest: **The database queries are unoptimized.** Historically, when the site was running on LiteSpeed Enterprise, this application-layer problem was bypassed. Under LiteSpeed's native core caching module, even with unoptimized code, the server remained functional. The operational principle back then was simple: if the system remains profitable and users do not complain, application code refactoring is unnecessary. 🤌

---

### 💸 The Financial Trap: The Licensing Roadblock

Why not just upgrade the VPS hardware configuration under the old webserver setup to fix the slow queries? Because of the **LiteSpeed License Limit**.

The website ran **LiteSpeed WebServer Enterprise** with a *Free Starter License*—an excellent web server for local caching, but one that strictly limits hardware configuration to 1 vCPU, 2GB RAM, and 1 domain only. 

This created a severe operational bottleneck:
* **The License Trap:** Staying with LiteSpeed and upgrading the host hardware forced a mandatory shift to a paid proprietary license tier costing **$10/month** or more. Spending an extra $10/month on a software license for a $350 MRR project yields no extra traffic or revenue growth.
* **The Hardware Trap:** Simply keeping the old 1 vCPU / 2GB RAM resource boundary while switching to open-source NGINX was also impossible. Testing proved that while a 1C/2GB container stack works fine in an isolated staging environment, a single-core CPU hits an excessive processing queue under real production traffic. 

**The Solution:**
To break free from this license lock and hardware limitation, migrating to this 100% free, open-source Dockerized NGINX stack was the only logical path. By removing the proprietary software licensing bottleneck entirely, the infrastructure budget was reallocated to upgrade the raw computing hardware to **2 vCPU / 4GB RAM (€5.78/month total)**. Spending an extra €2.49/month on raw hardware specs is infinitely more efficient than paying for web server licenses, giving the production infrastructure genuine multi-threaded capacity to process real-world concurrent query floods smoothly.

### 🛡️ System Evolution & Survival Timeline

The platform has been running stably for over a year through 3 major lifecycle stages:
* **v1.0 (The Origin):** Started as a simple static site built with **Hugo** on **GitHub Pages**. As content exploded, Hugo became impossible to scale for a complex content database.
* **v2.0 (The Migration):** Executed a data migration of **1,000+ posts** to WordPress. To maintain design consistency for regular users, a custom theme cloning the old Hugo layout was built with heavy AI assistance. Check the workflow: 🫴 [Hugo to WordPress Migration](https://github.com/aleixnguyen-vn/hugo-to-wordpress-migration/)
* **v3.0 (The Present):** Rewrote the theme frontend to remove redundant AJAX/ACF queries and lower server load. 

During this journey, the infrastructure survived competitor sabotage, heavy DDoS attacks, a domain-loss crisis, and a complete VPS wipeout. The local stack (**LiteSpeed Enterprise + LiteSpeed Cache + LS-PHP + Redis Object Cache + Cloudflare Edge**) kept the database from hitting OOM faults.

However, because the hardware was stuck at the 2GB RAM limit due to the license limit, an open-source solution that can scale horizontally without licensing fees became necessary.

## 🏗️ 2. System Design & Architecture Blueprint

### 💡 The Reality of Caching in Containers: Staging vs. Real-World Production

During initial testing on the `staging` branch, the infrastructure performed perfectly with **NGINX FastCGI Cache** because synthetic benchmarks (like k6 load tests) only hit pre-cached static pages on an isolated server. However, once deployed to the production environment with real users, this low-level caching policy exposed severe configuration conflicts. 

Forcing a low-level cache inside isolated Docker container boundaries broke core application logic, triggering configuration conflicts across session management, cookie authentication, directory/file permission mismatches, and fatal white-screen errors. Even after 2 to 3 hours of troubleshooting custom NGINX bypass rules and container volume mounts, it became clear that implementing a low-level cache directly at the proxy layer was an inefficient engineering path for this specific containerized architecture.

Therefore, a more conventional and battle-tested solution was deployed — **WP Super Cache**. 

By combining **WP Super Cache** with the existing **Redis Object Cache** and **Cloudflare Edge caching**, this operational pivot completely resolved the NGINX container conflicts and required zero licensing fees while still delivering excellent, equivalent web performance. It is simple, highly stable, and allows the infrastructure to focus strictly on resource efficiency.
### 2.1 Hardware Resource Hardening (4GB RAM Upgrade)
* **MariaDB Container:** Allocated with appropriate buffer space while protecting host stability.
* **PHP-FPM Dynamic Pool:** Scaled up to `pm.max_children = 20`. Each active worker consumes ~80MB–100MB RAM under load, safely utilizing the extra RAM.
* **Leak Recycler (`pm.max_requests = 1000`):** Automatically recycles PHP workers to clear runtime memory leaks.
* **OPcache Activation:** Enabled `opcache.memory_consumption = 128` to keep precompiled PHP bytecode in memory, massively offloading CPU stress during dynamic script execution.
* **Redis Object Cache:** Deployed as an in-memory data store wrapper for the database layer to offload persistent, redundant SQL query hits from WordPress core natively.

### 2.2 Security & Network Isolation
* **Public Zone (`wp_frontend`):** Only the NGINX container is connected here, exposing public ports `80/443`.
* **Isolated Zone (`wp_backend` / `internal: true`):** MariaDB, Redis, and PHP-FPM containers communicate exclusively inside this private internal network, completely invisible to the public internet to block automated port scans.

### 2.3 Deployment & Data Migration
1. **Infrastructure Scaffolding:** GitHub Actions only deploys the clean infrastructure framework using official `wordpress:fpm` images.
2. **Secrets Management:** Environment variables are injected into runtime memory via a secure `.env` file.
3. **Data Restoration:** The actual heavy production data (Database, Themes, Plugins) is restored seamlessly using the **UpdraftPlus** engine directly from the WP Admin dashboard.


---

## 📊 3. Performance Metrics & Analytics Data

As mentioned, this is a live website currently operating and serving the global simracing community every day. Instead of executing synthetic stress tests (like k6 or Loader.io) for the main branch, below are the actual production datasets collected during daily operations via Cloudflare Analytics and Google Search Console (GSC).

*(Note: Production domain names and sensitive secrets in the screenshots have been blurred/anonymized to ensure security compliance).*

### 🔹 3.1 Cloudflare Edge Analytics (30-Day Cumulative Dataset)
* **Total Throughput:** **8.19M Requests** successfully processed within a 30-day window (including both user traffic and automated bot/crawler requests).
* **Edge Offloading Efficiency:** Maintained a **50.88% Cache Hit Rate** at the Cloudflare layer, filtering half of the dynamic connection load and automated scanner spikes before they reached the origin proxy container.
* **Monthly Volume:** Sustained **303.24K Total Visits** and **87.45 GB of served bandwidth** over the past month, driven primarily by desktop traffic.
* **Infrastructure Allocation Note:** This raw edge dataset explains why the legacy configuration (1 vCPU / 2GB RAM running LiteSpeed) operated stably under load. Cloudflare effectively absorbed 50% of the raw connection overhead and bad bot scans at the edge, preventing resource starvation on the low-spec origin host.
* **User Demographics:** Top traffic distribution is led by tier-1 regions: **United States (932.3K requests), France (692.5K requests), and Germany (457.5K requests)**.

![Cloudflare Live Traffic Analytics](images/cloudflare-analytics-dash.png)
*Cloudflare analytics dashboard showing 30-day cumulative requests, bandwidth, and regional traffic distribution.*

### 🔹 3.2 Google Search Console Performance (Month-over-Month Growth Dataset)
* **Organic Traffic Growth:** Increased from **10.8K to 11.8K Clicks** (+9.2% MoM growth) over the last 28 days compared to the previous period.
* **Search Impressions Expansion:** Expanded from **50.7K to 60.5K Impressions** (+19.3% MoM growth), proving the infrastructure's capability to seamlessly handle increased Googlebot crawling and indexing activities without response degradation.
* **Target Reach:** High engagement from European and Western search queries, verifying the architecture's stability under rising organic user acquisition waves.

![Google Search Console Traffic](images/gsc-live-stats.png)
*Google Search Console metrics showing active indexing and organic traffic growth compared to last month.*

### 💻 3.3 Live Production Telemetry & Hardware Verification

To verify that the system configuration, infrastructure costs, and resource optimization metrics are entirely authentic, below is the real-time telemetry data collected directly from the active production environment.

#### Host OS Resource Optimization (btop Real-time View)
Captured under standard active traffic operations, the upgraded **2 vCPU / 4GB RAM** environment runs cleanly under the AMD EPYC architecture. 
* **Memory Headroom:** Total server RAM consumption stabilizes strictly at **~1.23 GiB out of 3.82 GiB** (32% usage), leaving substantial headroom for peak concurrency traffic.
* **Process Tracking:** Multi-threaded concurrency is handled efficiently across the active **PHP-FPM dynamic pool processes**, backed by memory-isolated Redis and MariaDB instances.

![Production Server btop Real-time Telemetry](images/btop-prod-under-normal-traffic.png)
*Live terminal telemetry dashboard showing CPU wave distribution and optimized memory utilization.*

### 💻 3.4 Legacy Infrastructure & Specification Verification

As mentioned in the architecture lifecycle, the previous production environment operated on a strict resource boundary before the hardware upgrade. 

* **Hardware Specs:** 1 vCPU (AMD EPYC-Rome 2.4GHz) / 2048 MB RAM / 40 GB Storage.
* **Financial Overhead:** **€3.29 / Month** (Recurring Subscription).

![Legacy Server Hardware Configuration](images/old-infastructure-configuration.png)
*Provider dashboard showing the legacy €3.29/month subscription and hardware resource boundary.*

![Legacy Server Resource Under Real Traffic](images/old-server-btop-real-traffic.png)
*Live terminal telemetry from the legacy server instance handling active database query loads.*