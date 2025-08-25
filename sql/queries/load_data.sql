-- ==========================================
-- Script: load_data.sql
-- Objetivo: Cargar los archivos CSV en las tablas del esquema telco_churn
-- Nota: Ajustar la ruta absoluta de los archivos CSV según tu entorno
-- ==========================================

-- Cargar datos de demographics
COPY telco_churn.telco_customer_churn_demographics
FROM '/ruta/dataset/Telco_customer_churn_demographics.xlsx'
DELIMITER ','
CSV HEADER;

-- Cargar datos de location
COPY telco_churn.telco_customer_churn_location
FROM '/ruta/dataset/Telco_customer_churn_location..xlsx'
DELIMITER ','
CSV HEADER;

-- Cargar datos de population
COPY telco_churn.telco_customer_churn_population
FROM '/ruta/dataset/Telco_customer_churn_population.xlsx'
DELIMITER ','
CSV HEADER;

-- Cargar datos de services
COPY telco_churn.telco_customer_churn_services
FROM '/ruta/dataset/Telco_customer_churn_services.xlsx'
DELIMITER ','
CSV HEADER;

-- Cargar datos de status
COPY telco_churn.telco_customer_churn_status
FROM '/ruta/dataset/Telco_customer_churn_status.xlsx'
DELIMITER ','
CSV HEADER;

-- Cargar dataset principal (si corresponde)
COPY telco_churn.telco_customer_churn
FROM '/ruta/dataset/Telco_customer_churn.xlsx'
DELIMITER ','
CSV HEADER;
