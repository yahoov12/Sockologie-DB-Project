# 🧦 Sockologie - Database Design & Business Intelligence Project

Welcome to the **Sockologie Database Project**! This repository showcases a comprehensive, end-to-end database engineering process for the e-commerce site [Sockologie.com](https://sockologie.com/). 

The project covers the entire lifecycle of data management: from initial business analysis and conceptual modeling to SQL implementation and live BI visualization.

---

## 🚀 Project Overview

The goal of this project was to design and implement a robust relational database that supports the core business processes of an online sock retailer, including inventory management, user search behavior, and order processing.

### 🛠️ Tools & Technologies Used
* **Database Engine:** MS SQL Server (T-SQL)
* **Data Generation:** Microsoft Excel (Advanced functions for correlated dummy data)
* **Modeling:** ERD Tools (for conceptual validation)
* **Analytics:** Power BI (Visualization of KPIs)

---

## 📈 The End-to-End Process (Step-by-Step)

### Phase 1: Business Analysis & Requirements 🔍
* Analyzed the **Sockologie** website to identify core entities and business flows.
* Defined the primary process: From a user's search intent to the final purchase and order management.

### Phase 2: Conceptual Design (ERD) 📐
* Created a detailed **Entity-Relationship Diagram (ERD)**.
* **Refinement Process:** Compared our model with ChatGPT's suggestions and performed iterative improvements.
* **Key Fixes:** Addressed complex relations between Searches, Orders, and Specific Items (e.g., handling multiple designs for the same sock in a single order).

### Phase 3: Logical & Physical Design 💾
* Converted the ERD into a **Relational Schema** (Tables, Primary Keys, Foreign Keys).
* Implemented **Data Integrity** using `CHECK` constraints and lookup tables.
* **Schema Highlights:** * `Socks`: Inventory and pricing.
    * `Sock_Searches`: Tracking user behavior.
    * `Orders` & `SockInOrder`: Managing transactions and quantities.

### Phase 4: Data Seeding & Simulation 🧪
* Generated thousands of rows of dummy data using **Excel**.
* **Advanced Techniques:** Used linear transformations and correlation formulas to simulate realistic shopping trends, seasonal demands (e.g., Christmas/Halloween peaks), and customer behavior.

### Phase 5: Advanced SQL Implementation ⚡
* Developed complex queries using **CTEs** (Common Table Expressions) for deep analysis.
* Implemented a **`MERGE` mechanism** to synchronize a sales summary table (`SockCategorySalesSummary`) automatically.
* Created **Stored Procedures** for business logic, such as an automated bonus system for loyal customers.

### Phase 6:Power BI Live Dashboard 📊
* Connected the SQL database to a **Live Dashboard**.
* Visualized key business metrics (KPIs) such as:
    * Top-selling sock categories.
    * Conversion rates from search to purchase.
    * Revenue trends over time.

---

## 📂 Repository Structure

* `/Documentation`: Initial analysis and ERD comparison reports.
* `/Design`: High-resolution ERD and Logical Schema diagrams.
* `/Scripts`: 
    * `Schema_Setup.sql`: DDL scripts for tables and constraints.
    * `Data_Load.sql`: DML scripts for inserting the simulated data.
    * `Procedures_Queries.sql`: Advanced logic, Merge, and Analysis queries.
* `/BI_Dashboard`: of the live analytics dashboard.

---

## 👥 The Team
* **Member 1** - Yahav Nave
* **Member 2** - Yuval Yehezkel
* **Member 3** - Naama Dumen

---
*This project was completed as part of the "Database Systems" course at Ben-Gurion University of the Negev.*
