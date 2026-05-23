# 🔧 Content Distribution Platform Infrastructure: 5K DAU on a €3.30 VPS

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
| **Server Specs** | **1 vCPU / 2GB RAM** Dedicated VPS |
| **Infrastructure Cost** | **€3.30 / month** (Offshore Provider) |
| **Live Traffic** | **4,000 - 5,000 Daily Active Users** (>7,000 daily visits) |
| **SEO Performance** | **62K Impressions / 12K Clicks** (Average month on Search Console) |
| **Financial Output** | **~$350 USD MRR** (Monthly Recurring Revenue) |
| **Storage Solution** | Images offloaded to **Imgur** + **Cloudflare CDN/Proxy** |

---

### 🚨 The DB Bottleneck & Structural Challenges
The platform hosts over **2,000+ posts** packed with complex **ACF (Advanced Custom Fields)** metadata. User behavior is aggressive: they frequently open one category, search then middle-click to open 10–20 tabs simultaneously, and trigger a massive wave of **AJAX queries for dynamic filtering**. Standard shared hosting crashed within the first week of launch.

**My thought:** The database queries are a total mess and unoptimized. At peak traffic, a single page can take from 30 seconds to over a minute to respond. **But if users don't complain, website still prints money on a €3.30 VPS, then i will not touch the code or spend money on better resource.** 🤌

### 💸 The Financial Trap: The Licensing Roadblock
Why not just using a better hardware like 2vCPU 4GB or 8GB RAM to increase performance? 
Let's talk about the webserver or the main issue
My website runs **LiteSpeed WebServer Enterprise** under the *Starter License*, benefit from excellent performance and LS Cache. Yes it's free to use, but comes with limit for hardware configuration, allow up to to 1 vCPU and 2GB RAM and 1 domain only.
So:

* Upgrading the hardware mean you need to upgrade to a paid LiteSpeed License, about **$10/month** or more. 
* Spending an extra $10/month on a $350 MRR project just to speed up background queries is an inefficient business decision. 
And overall, upgrading License or Hardward will not bring more traffic or increase revenue.

### 🛡️ System Evolution & Survival Timeline
The platform has been running stably for over a year through 3 major lifecycle stages:
* **v1.0 (The Origin):** Started as a simple static site built with **Hugo** on **GitHub Pages**. As content exploded, Hugo became impossible to scale for a complex content database.

* **v2.0 (The Migration):** Executed a data migration of **1,000+ posts** to WordPress. To maintain design consistency for regular users, I spent a month writing a custom theme cloning the old Hugo layout. Check the workflow: 🫴 [Hugo to WordPress Migration](https://github.com/aleixnguyen-vn/hugo-to-wordpress-migration)
* **v3.0 (The Present):** Rewrote the theme frontend to remove redundant AJAX/ACF queries and lower server load. 

During this journey, the infrastructure survived competitor sabotage, heavy DDoS attacks, a domain-loss crisis, and a complete VPS wipeout. The local stack (**LiteSpeed Enterprise + LiteSpeed Cache + LS-PHP + Redis Object Cache + Cloudflare Edge**) kept the database from hitting OOM.

However, because the hardware is stuck at the 2GB RAM limit due as said above, I needed a 100% free, open-source solution that can scale horizontally without licensing fees. 

**This is why I built version 3.5 (This Repository) - migrating the entire architecture to Native NGINX FastCGI Cache on Docker.**

---

## 🏗️ 2. System Design & Architecture Blueprint

### 2.1 Hardware Resource Hardening (2GB RAM Limit)
* **MariaDB Container:** Hard-capped at `1GB RAM` via Docker Compose deployment limits to maximize SQL buffer pool while protecting the host.
* **PHP-FPM Dynamic Pool:** Capped at `pm.max_children = 4`. Each active worker consumes ~150MB under load, safely maxing out the PHP pool at 600MB.
* **Leak Recycler (`pm.max_requests = 500`):** Automatically recycles PHP workers after 500 requests to clear runtime memory leaks.
* **Timeout Window (`max_execution_time = 3600s`):** Configured to prevent crashes during heavy migration and database sync phases, ensuring the PHP-FPM process doesn't drop during long query executions.
* **Redis Object Cache:** Deployed as an in-memory data store wrapper for the database layer to offload persistent, redundant SQL query hits from WordPress core natively.

### 2.2 Security, Network Isolation & Layered Caching
* **Public Zone (`wp_frontend`):** Only the NGINX container is connected here, exposing public ports `80/443`.
* **NGINX FastCGI Microcaching:** Configured directly at the NGINX edge layer to cache dynamic PHP pages into RAM for 1-5 minutes, intercepting high-volume traffic and malicious query floods before they ever trigger PHP-FPM or MySQL execution.
* **Isolated Zone (`wp_backend` / `internal: true`):** MariaDB, Redis, and PHP-FPM containers communicate exclusively inside this private internal network, completely invisible to the public internet to block automated port scans.

### 2.3 Deployment & Data Migration
1. **Infrastructure Scaffolding:** GitHub Actions only deploys the clean infrastructure framework using official `wordpress:fpm` images.
2. **Secrets Management:** Environment variables are injected into runtime memory via a secure `.env` file.
3. **Data Restoration:** The actual heavy production data (Database, Themes, Plugins) is restored seamlessly using the **UpdraftPlus** engine directly from the WP Admin dashboard.


---

## 📊 3. Performance Metrics & Proof of Evidence

