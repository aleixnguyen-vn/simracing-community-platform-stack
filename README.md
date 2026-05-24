# 🔧 Content Distribution Platform Infrastructure: ~5K Sessions on a €5.8 VPS

![Infrastructure Grade](https://img.shields.io/badge/Grade-Production--Ready-brightgreen?style=for-the-badge&logo=kubernetes&logoColor=white)
![Redis Cache](https://img.shields.io/badge/Cache-Redis-red?style=for-the-badge&logo=redis)
![SSL](https://img.shields.io/badge/SSL-Certbot_Sidecar-blue?style=for-the-badge&logo=letsencrypt)
![CI/CD](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

**🪵 So... What's Up With This Repo?**

This repository contains the production-ready infrastructure blueprint (**NGINX, Redis, PHP-FPM, Docker, and GitHub Actions CI/CD**) that powers my live commercial website today. 

It is the direct architectural upgrade of my previous lab project: [WordPress on Docker: 5,000 Client Benchmark on 1GB RAM VPS (v2.0)](https://github.com). While version 2.0 was a cool lab experiment using Caddy, it suffered from a classic junior trap: **Overengineering**. After a year of running actual production traffic and optimizing infrastructure costs out of my own pocket, I rebuilt the entire stack for maximum resource efficiency.


## ⚡ 1. Live Production Context & Technical Constraints

This infrastructure holds together a live, high-traffic, database-heavy community catalog platform serving the global simracing community for **Assetto Corsa** (and yes, I am a Sim-Racer too 🦅). 

### 📊 Production & Financial Metrics


| Metric | Live Value |
| :--- | :--- |
| **Platform** | WordPress (Custom Theme / AI-Assisted Development) |
| **Server Specs** | **2 vCPU / 4GB RAM** Dedicated VPS (Upgraded) |
| **Infrastructure Cost** | **€5.70 / month** (Offshore Provider) |
| **Live Traffic** | **4,000 - 5,000 Daily Sessions** (>7,000 daily visits) |
| **SEO Performance** | **62K Impressions / 12K Clicks** (Average month on Search Console) |
| **Financial Output** | **~$350 USD MRR** (Monthly Recurring Revenue) |
| **Storage Solution** | Images offloaded to **Imgur** + **Cloudflare CDN/Proxy** |

---

### 🚨 The DB Bottleneck & Structural Challenges

The website is a community catalog platform with over **2,000+ posts** in the database. I heavily used **ACF (Advanced Custom Fields)** to store data. Because it's a catalog, user behavior is brutal: they frequently open one category, search, then middle-click to open 10–20 tabs simultaneously, and trigger an insane amount of **AJAX queries for dynamic filtering and searching**. 

The database was under constant heavy fire. Standard shared hosting died instantly after deployment, that is why I jumped straight to a dedicated VPS from the beginning (1 year ago).

> To be honest: **The database queries are a total mess and unoptimized.** 
But this configuration on 1C/2G VPS still runs perfectly in an ideal environment (like the staging environment) where k6 load tests only hit the pre-cached static homepage. 
But when it comes to real production traffic, NGINX is not natively integrated into the server core like LiteSpeed Enterprise. Under unpredictable user behavior where over 150+ active users browse the catalog and trigger continuous dynamic database queries, open-source NGINX on a single-core machine struggles, causing page load times to spike up to 30 seconds. 

**But if users don't complain, website still prints money, then I will not touch the code.** 🤌

---

### 💸 The Financial Trap: The Licensing Roadblock

Why didn't I just upgrade the VPS hardware configuration under the old webserver setup to fix the slow queries? Because of the **LiteSpeed License Limit**.

My website runs **LiteSpeed WebServer Enterprise** with *Starter License* - the best WebServer for WordPress. And yes, it's free to use, but comes with a strict limit for hardware configuration, allowing up to 1 vCPU and 2GB RAM and 1 domain only.
So:

* Upgrading the hardware configuration means you need to upgrade your LiteSpeed License, which costs about **$10/month** or more. 
* Spending an extra $10/month on a $350 MRR project just to make a few slow background queries faster is a terrible business decision. Spend extra 10$ for license will not bring more traffic or increase revenue.

**My Solution:**
By migrating to this 100% free, open-source Dockerized NGINX stack, I completely bypassed the software licensing bottleneck. Instead of paying for software licenses, I reallocated **an extra €2.40/month to upgrade the raw hardware to 2 vCPU / 4GB RAM (€5.78/month total)**. Spending a few extra Euros on raw computing specs is more efficient than paying for web server licenses, giving the production infrastructure genuine multi-threaded capacity to handle real-world concurrent query floods smoothly while keeping the project highly profitable.

### 🛡️ System Evolution & Survival Timeline

The platform has been running stably for over a year through 3 major lifecycle stages:
* **v1.0 (The Origin):** Started as a simple static site built with **Hugo** on **GitHub Pages**. As content exploded, Hugo became impossible to scale for a complex content database.
* **v2.0 (The Migration):** Executed a data migration of **1,000+ posts** to WordPress. To maintain design consistency for regular users, I spent a month writing a custom theme cloning the old Hugo layout. Check the workflow: 🫴 [Hugo to WordPress Migration](https://github.com)
* **v3.0 (The Present):** Rewrote the theme frontend to remove redundant AJAX/ACF queries and lower server load. 

During this journey, the infrastructure survived competitor sabotage, heavy DDoS attacks, a domain-loss crisis, and a complete VPS wipeout. The local stack (**LiteSpeed Enterprise + LiteSpeed Cache + LS-PHP + Redis Object Cache + Cloudflare Edge**) kept the database from hitting OOM.

However, because the hardware is stuck at the 2GB RAM limit due as said above, I needed a 100% free, open-source solution that can scale horizontally without licensing fees. 

**This is why I built version 3.5 (This Repository) - migrating the entire architecture to Native NGINX FastCGI Cache on Docker.**

---

## 🏗️ 2. System Design & Architecture Blueprint

### 💡 The Reality of Caching in Containers: Staging vs. Real-World Production

During initial testing on the `staging` branch, this setup performed perfectly with **NGINX FastCGI Cache** because synthetic benchmarks (like k6 load tests) only hit pre-cached static pages on an isolated server. However, once deployed to the production environment with active users, this low-level caching policy exposed severe configuration conflicts. 

Forcing a low-level cache inside isolated Docker container boundaries broke core application logic, triggering a nightmare of session drops, cookie authentication conflicts, directory/file permission mismatches, and fatal white-screen errors. I spent around 2 to 3 hours troubleshooting custom NGINX bypass rules and container volume mounts, but it became clear that implementing a low-level cache directly at the proxy layer was an inefficient engineering path for this specific containerized architecture.

Therefore, I chose a more conventional and battle-tested solution - **WP Super Cache**. 

By combining **WP Super Cache** with our existing **Redis Object Cache** and **Cloudflare Edge caching**, this operational pivot completely removed the NGINX container conflicts and required zero licensing fees while still delivering excellent, equivalent web performance. It is simple, highly stable, and allows the infrastructure to focus strictly on resource efficiency.

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


## 📊 3. Performance Metrics & Proof of Evidence

