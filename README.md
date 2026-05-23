# 🚀 [PRODUCTION CASE STUDY] WordPress Content Distribution - Serving 4K DAU on 2GB RAM VPS

![Infrastructure Grade](https://img.shields.io/badge/Grade-Production--Ready-brightgreen?style=for-the-badge&logo=kubernetes&logoColor=white)
![Redis Cache](https://img.shields.io/badge/Cache-Redis-red?style=for-the-badge&logo=redis)
![SSL](https://img.shields.io/badge/SSL-Certbot_Sidecar-blue?style=for-the-badge&logo=letsencrypt)
![CI/CD](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

**🪵 So... What's Up With This Repo?**

This project is the direct production upgrade of my previous lab repository: [WordPress on Docker: 5,000 Client Benchmark on 1GB RAM VPS (v2.0)](https://github.com/aleixnguyen-vn/docker-wordpress-performance).

When I first learned Docker a year ago, I built version 2.0 using Caddy and Redis to hit 5K CCU. It was a cool lab experiment, but it suffered from a classic junior trap: **Overengineering**. 

After nearly a year of surviving in the trenches of real-world production, handling actual traffic, and paying infrastructure bills out of my own pocket, I came back to rebuild it properly. 

This repository contains the exact infrastructure blueprint (**NGINX, Redis, PHP-FPM, Docker, and GitHub Actions CI/CD**) that powers my live commercial website today. No overengineered garbage—just pure, optimized architectural efficiency.


## ⚡ 1. The Live Production Nightmare

Before talking about Docker or NGINX, you need to understand the absolute madness of the live production website that this infrastructure is holding together and why I must migrate. 

This isn't a clean, optimized stack. It's a high-traffic, database-heavy platform built to serve the racing community from all over the world — Assetto Corsa. Of course, I'm a Sim-Racer too 🦅.

About a year ago, out of my pure passion for Motorsport and Assetto Corsa, I thought: why not build a website just to share this passion with people from all over the world? But I am a pragmatic man—if I spend my time digging, curating, and aggregating quality content for the community, the website must pay for its own hosting, domains, and bring me some pocket money. 

The technical evolution of this platform was absolute chaos:
* **The Origin (v1.0):** It started as a simple static site built with **Hugo Static Website** and hosted on **GitHub Pages**. But as content exploded, I realized Hugo was never designed to scale and manage a complex content database. 
* **The Migration & AI Theme 1.0 (v2.0):** I had to quickly execute a data migration of **1,000+ posts** over to WordPress. To maintain design consistency and avoid confusing my regular users, I spent over a month designing and writing a custom theme from scratch that cloned the old Hugo layout (built with heavy AI assistance). Check how I did it: 🫴 [Hugo to WordPress Migration](https://github.com/aleixnguyen-vn/hugo-to-wordpress-migration)
* **The Refactor (v3.0):** I soon realized my initial theme architecture was garbage—it heavily overloaded the server with bloated AJAX calls and unoptimized ACF (Advanced Custom Fields) queries. I immediately executed a UI/UX code refactor, stripping down unnecessary queries and building a much more pragmatic, performance-focused frontend (again, with AI assistance).

Along the way, I had to survive brutal grayzone environments, including **direct sabotage from competitors, heavy DDoS attacks, a massive domain-loss crisis, and even having a VPS box completely wiped out**. But I adapted, built disaster recovery workflows, and stabilized the infrastructure.

Fast forward to today, after 1 year of continuous war and evolution, the production version (v3.0) has stabilized on a tiny €3.30 offshore box. It runs smoothly day in and day out, printing roughly **$350 USD MRR**. In a developing economy like Vietnam, this is a beautiful passive income stream that covers all my server bills and leaves me with a very comfortable amount of spending cash. 


### 📊 The Infrastructure & Financial ROI


| Metric | Live Production Value |
| :--- | :--- |
| **Platform** | WordPress (Custom Theme Built From Scratch with AI Assistance) |
| **Server Specs** | **1 vCPU / 2GB RAM** Dedicated VPS |
| **Infrastructure Cost** | **€3.30 / month** (Offshore Provider) |
| **Live Traffic** | **4,000 - 5,000 DAU** (>7,000 daily visits) |
| **SEO Performance** | **62K Impressions / 12K Clicks** (Last 28 days on Google Search Console) |
| **Financial Output** | **~$350 USD MRR** (Monthly Recurring Revenue) |
| **Storage Solution** | Images offloaded to **Imgur**, proxied via **Cloudflare CDN** |

---

### 🚨 The Technical Bottleneck: DB Under Heavy Fire

The website is a community catalog platform with over **2,000+ posts** in the database. I heavily used **ACF (Advanced Custom Fields)** to store data. Because it's a catalog, user behavior is brutal: they open multiple categories at once, spam middle-click to browse dozens of items, and trigger an insane amount of **AJAX queries for dynamic filtering and searching**. 

The database was under constant heavy fire. Standard shared hosting died instantly after deployment, which is why I jumped straight to a dedicated VPS from the beginning (1 year ago).

To be honest: **The database queries are a total mess.** Sometimes an un-cached heavy search query takes 30 seconds to over a minute to respond. **But I don't care, and neither do the users.** The content is highly valuable (proven by GSC data), users are willing to wait, and I am a DevOps/Infra guy, not a software engineer or FE/BE developer. My job is to keep the infrastructure alive with the lowest cost and printing money. 

**My approach is simple: If it still makes money, you don't touch the code.** 🤌

---

### 💸 The Financial Trap: Scaling Hardware is a Bad Deal

Why didn't I just upgrade the VPS to 4GB or 8GB RAM to fix the slow queries? Because of the **LiteSpeed License Limit**.

I am currently using **LiteSpeed WebServer Enterprise** with a *Free Starter License*. Yes, it's free, but it comes with some serious downsides: it only works with a 1 domain / 1 vCPU / 2GB RAM configuration. 
* If I upgrade the server hardware to a higher spec, I am forced to pay **$10/month** for a higher LiteSpeed license tier. 
* Spending an extra $10/month on a $350 MRR project just to make a few slow background queries faster is a **terrible business decision**. Upgrading the server hardware or Webserver License will NOT increase my traffic or revenue.

### 🛡️ How It Survived For 1+ Year (v2.0 to v3.0 Evolution)

The site has been running smoothly like this for over a year through 2 major UI/UX upgrade stages. The database never crashes or hits OOM (Out Of Memory) thanks to a heavily tuned stack: **LiteSpeed WebServer Enterprise + LiteSpeed Cache + LS-PHP + Redis Object Cache**, combined with **Cloudflare edge caching**. 

But since I am hard-stuck at the 2GB RAM limit due to the LiteSpeed Free Starter License, I realized I needed a long-term solution that is 100% open-source, free, and can scale horizontally without licensing fees. 

**And that is exactly why I built version 3.5 (This Repository) — Migrating the entire architecture to Native Nginx FastCGI Cache on Docker.**


