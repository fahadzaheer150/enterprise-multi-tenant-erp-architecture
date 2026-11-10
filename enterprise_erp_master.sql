-- ==========================================
-- U.S. ENTERPRISE ERP & MULTI-TENANT SaaS SCHEMA
-- ==========================================

CREATE DATABASE IF NOT EXISTS enterprise_erp_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE enterprise_erp_db;

-- Core Tables
CREATE TABLE Organizations (
    org_id INT AUTO_INCREMENT PRIMARY KEY,
    legal_company_name VARCHAR(150) NOT NULL,
    ein_tax_id VARCHAR(20) UNIQUE NOT NULL,
    subscription_tier ENUM('Standard', 'Professional', 'Enterprise') DEFAULT 'Enterprise',
    billing_currency VARCHAR(3) DEFAULT 'USD',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    work_email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    mfa_enabled BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (org_id) REFERENCES Organizations(org_id) ON DELETE CASCADE
);

CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    access_level_code INT NOT NULL,
    description TEXT
);

CREATE TABLE User_Roles (
    user_id INT,
    role_id INT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON DELETE CASCADE
);

CREATE TABLE Warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT NOT NULL,
    facility_code VARCHAR(20) UNIQUE NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL,
    state_province VARCHAR(50) NOT NULL,
    zip_postal_code VARCHAR(10) NOT NULL,
    FOREIGN KEY (org_id) REFERENCES Organizations(org_id) ON DELETE CASCADE
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    org_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    safety_stock_threshold INT DEFAULT 20,
    FOREIGN KEY (org_id) REFERENCES Organizations(org_id) ON DELETE CASCADE
);

CREATE TABLE Warehouse_Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    stock_quantity INT DEFAULT 0,
    last_restock_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE Audit_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action_type ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'AUTH_FAILURE') NOT NULL,
    table_affected VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45) DEFAULT '127.0.0.1',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Seed Data (U.S. Corporate Scale)
INSERT INTO Organizations (legal_company_name, ein_tax_id, subscription_tier, billing_currency, is_active) VALUES
('Apex Global Logistics Inc.', '12-3456789', 'Enterprise', 'USD', TRUE),
('Cascade Retail Group LLC', '98-7654321', 'Professional', 'USD', TRUE),
('Vanguard Supply Chain Corp', '45-6789123', 'Enterprise', 'USD', TRUE),
('Titanium Logistics & Freight Corp', '34-5678901', 'Enterprise', 'USD', TRUE),
('BlueRidge Manufacturing Group', '67-8901234', 'Enterprise', 'USD', TRUE),
('Quantum Tech Solutions LLC', '89-0123456', 'Professional', 'USD', TRUE),
('Summit International Trade Inc', '54-3210987', 'Enterprise', 'USD', TRUE);

INSERT INTO Roles (role_name, access_level_code, description) VALUES
('System Super Administrator', 100, 'Full root-level control across tenant infrastructure'),
('Enterprise Logistics Manager', 50, 'Manages regional fulfillment centers, inventory, and stock flow'),
('Compliance & Security Auditor', 10, 'Read-only access to system audit trails, logs, and security reports');

INSERT INTO Users (org_id, first_name, last_name, work_email, password_hash, mfa_enabled, is_active) VALUES
(1, 'Jonathan', 'Miller', 'jmiller@apexlogistics.io', 'hash_sec_01', TRUE, TRUE),
(1, 'Sarah', 'Connor', 'sconnor@apexlogistics.io', 'hash_sec_02', TRUE, TRUE),
(2, 'Michael', 'Chang', 'mchang@cascaderetail.com', 'hash_sec_03', TRUE, TRUE),
(3, 'Elena', 'Vance', 'evance@vanguardsc.com', 'hash_sec_04', TRUE, TRUE),
(4, 'David', 'Sterling', 'dsterling@titaniumlogistics.com', 'hash_sec_05', TRUE, TRUE),
(5, 'Jessica', 'Pearson', 'jpearson@blueridge.com', 'hash_sec_06', TRUE, TRUE),
(6, 'Brian', 'Litt', 'blitt@quantumtech.io', 'hash_sec_07', TRUE, TRUE),
(7, 'Harvey', 'Specter', 'hspecter@summittrade.com', 'hash_sec_08', TRUE, TRUE);

INSERT INTO User_Roles (user_id, role_id) VALUES
(1, 1), (2, 2), (3, 1), (4, 3), (5, 2), (6, 3), (7, 1), (8, 1);

INSERT INTO Warehouses (org_id, facility_code, warehouse_name, state_province, zip_postal_code) VALUES
(1, 'SFO-DC-01', 'San Francisco Primary Distribution Hub', 'California', '94105'),
(1, 'JFK-DC-02', 'New York Air Cargo Terminal', 'New York', '11430'),
(2, 'DFW-DC-01', 'Dallas Regional Fulfillment Center', 'Texas', '75201'),
(3, 'ORD-DC-01', 'Chicago Logistics Gateway', 'Illinois', '60666'),
(4, 'LAX-DC-03', 'Los Angeles Seaport Distribution Hub', 'California', '90001'),
(5, 'SEA-DC-02', 'Seattle Freight Consolidation Center', 'Washington', '98101'),
(6, 'ATL-DC-01', 'Atlanta Southern Logistics Gateway', 'Georgia', '30303'),
(7, 'MIA-DC-01', 'Miami International Cargo Depot', 'Florida', '33101');

INSERT INTO Products (org_id, product_name, sku, unit_price, safety_stock_threshold) VALUES
(1, 'Industrial Grade Automated Robotic Arm', 'ROBO-ARM-X9', 24500.00, 5),
(1, 'Heavy Duty Hydraulic Pallet Jack', 'PLT-JACK-500', 850.00, 15),
(2, 'Commercial POS Touchscreen Terminal', 'POS-TERM-PRO', 1200.00, 10),
(3, 'Enterprise Server Rack Cabinet 42U', 'RACK-SRV-42U', 3200.00, 8),
(4, 'Heavy Duty Forklift Battery 48V', 'BATT-FL-48V', 5200.00, 10),
(5, 'Automated Conveyor Belt Module (10m)', 'CNV-MOD-10M', 14500.00, 4),
(6, 'Industrial Laser Barcode Scanner Pro', 'SCAN-LSR-PRO', 450.00, 25),
(7, 'Commercial Freight Container Lock (GPS Enabled)', 'GPS-LCK-01', 350.00, 30);

INSERT INTO Warehouse_Inventory (warehouse_id, product_id, stock_quantity) VALUES
(1, 1, 12), (1, 2, 45), (2, 2, 30), (3, 3, 25), (4, 4, 18),
(5, 5, 85), (6, 6, 12), (7, 7, 110), (8, 4, 300), (5, 1, 15);

INSERT INTO Audit_Logs (user_id, action_type, table_affected, ip_address) VALUES
(1, 'INSERT', 'Products', '192.168.1.50'),
(2, 'UPDATE', 'Warehouse_Inventory', '192.168.1.52'),
(3, 'INSERT', 'Warehouses', '172.16.0.14'),
(4, 'SELECT', 'Audit_Logs', '10.0.0.8'),
(5, 'UPDATE', 'Warehouse_Inventory', '192.168.2.10'),
(6, 'SELECT', 'Audit_Logs', '192.168.2.15'),
(7, 'INSERT', 'Products', '10.20.40.5'),
(8, 'INSERT', 'Warehouses', '172.16.50.8');

-- Enterprise Queries
SELECT u.user_id, CONCAT(u.first_name, ' ', u.last_name) AS full_name, u.work_email, o.legal_company_name, r.role_name, r.access_level_code, u.mfa_enabled FROM Users u JOIN Organizations o ON u.org_id = o.org_id JOIN User_Roles ur ON u.user_id = ur.user_id JOIN Roles r ON ur.role_id = r.role_id ORDER BY o.legal_company_name, r.access_level_code DESC;

SELECT o.legal_company_name, w.facility_code, w.warehouse_name, w.state_province, COUNT(wi.product_id) AS distinct_product_lines, SUM(wi.stock_quantity) AS total_units_in_stock, SUM(wi.stock_quantity * p.unit_price) AS total_inventory_valuation_usd FROM Warehouses w JOIN Organizations o ON w.org_id = o.org_id JOIN Warehouse_Inventory wi ON w.warehouse_id = wi.warehouse_id JOIN Products p ON wi.product_id = p.product_id GROUP BY o.legal_company_name, w.facility_code, w.warehouse_name, w.state_province ORDER BY total_inventory_valuation_usd DESC;

SELECT al.log_id, COALESCE(CONCAT(u.first_name, ' ', u.last_name), 'System / Terminated User') AS performed_by, al.action_type, al.table_affected, al.ip_address, al.timestamp FROM Audit_Logs al LEFT JOIN Users u ON al.user_id = u.user_id ORDER BY al.timestamp DESC;