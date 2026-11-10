# Enterprise-Grade Multi-Tenant ERP & SaaS Architecture

An enterprise-tier, production-ready database architecture built for U.S. corporate multi-tenant compliance, secure Identity & Access Management (IAM), multi-location logistics, and SOC 2 audit logging.

## 🏢 System Architecture & Modules
- **Multi-Tenant Core (Organizations)**: Manages U.S. corporate entities, EIN tax IDs, and subscription tiers (`Standard`, `Professional`, `Enterprise`).
- **IAM & RBAC Security Layer**: Implements strict Role-Based Access Control (`Super Admin`, `Logistics Manager`, `Auditor`), access level grading, and MFA enforcement flags.
- **Supply Chain & Multi-Warehouse Logistics**: Tracks regional fulfillment centers across U.S. states with distinct facility codes (`SFO-DC-01`, `JFK-DC-02`, etc.) and multi-location inventory allocation.
- **SOC 2 & Compliance Auditing (`Audit_Logs`)**: Captures granular administrative activities, table modifications, and IP tracking for enterprise security audits.

## 📊 Advanced Enterprise SQL Highlights
1. **RBAC Permission Auditing**: Complex multi-table joins mapping tenant organizations to granular user access levels.
2. **Multi-Location Inventory Valuation**: Aggregates stock levels and computes total asset valuation in USD per regional fulfillment hub.
3. **Compliance Logging**: Time-series audit tracking with fallback handling for terminated users.

---
*Developed by Muhammad Fahad Zaheer.*
