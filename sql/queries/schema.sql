-- =========================================================
-- CREACIÓN DEL ESQUEMA Y USUARIO
-- =========================================================
-- DROP SCHEMA IF EXISTS telco_churn CASCADE;

CREATE SCHEMA telco_churn AUTHORIZATION innovacion_2025;

SET search_path TO telco_churn;

-- =========================================================
-- TABLA: telco_customer_churn
-- =========================================================
CREATE TABLE telco_customer_churn (
    "Customer_ID" varchar(50) NOT NULL,
    "Count" int4 NULL,
    "Country" varchar(50) NULL,
    "State" varchar(50) NULL,
    "City" varchar(50) NULL,
    "Zip Code" int4 NULL,
    "Lat Long" varchar(50) NULL,
    "Latitude" varchar(50) NULL,
    "Longitude" varchar(50) NULL,
    "Gender" varchar(50) NULL,
    "Senior Citizen" varchar(50) NULL,
    "Partner" varchar(50) NULL,
    "Dependents" varchar(50) NULL,
    "Tenure Months" int4 NULL,
    "Phone Service" varchar(50) NULL,
    "Multiple Lines" varchar(50) NULL,
    "Internet Service" varchar(50) NULL,
    "Online Security" varchar(50) NULL,
    "Online Backup" varchar(50) NULL,
    "Device Protection" varchar(50) NULL,
    "Tech Support" varchar(50) NULL,
    "Streaming TV" varchar(50) NULL,
    "Streaming Movies" varchar(50) NULL,
    "Contract" varchar(50) NULL,
    "Paperless Billing" varchar(50) NULL,
    "Payment Method" varchar(50) NULL,
    "Monthly Charges" numeric NULL,
    "Total Charges" numeric NULL,
    "Churn Label" varchar(50) NULL,
    "Churn Value" int4 NULL,
    "Churn Score" int4 NULL,
    "CLTV" int4 NULL,
    "Churn Reason" varchar(50) NULL,
    CONSTRAINT telco_customer_churn_pkey PRIMARY KEY ("Customer_ID")
);

ALTER TABLE telco_customer_churn OWNER TO innovacion_2025;
GRANT ALL ON TABLE telco_customer_churn TO innovacion_2025;


-- =========================================================
-- TABLA: telco_customer_churn_population
-- =========================================================
CREATE TABLE telco_customer_churn_population (
    "ID" int4 NULL,
    "Zip_Code" int4 NOT NULL,
    "Population" float4 NULL,
    CONSTRAINT telco_customer_churn_population_pkey PRIMARY KEY ("Zip_Code")
);

ALTER TABLE telco_customer_churn_population OWNER TO innovacion_2025;
GRANT ALL ON TABLE telco_customer_churn_population TO innovacion_2025;


-- =========================================================
-- TABLA: telco_customer_churn_services
-- =========================================================
CREATE TABLE telco_customer_churn_services (
    "Customer_ID" varchar(50) NOT NULL,
    "Count" int4 NULL,
    "Quarter" varchar(50) NULL,
    "Referred a Friend" varchar(50) NULL,
    "Number of Referrals" int4 NULL,
    "Tenure in Months" int4 NULL,
    "Offer" varchar(50) NULL,
    "Phone Service" varchar(50) NULL,
    "Avg Monthly Long Distance Charges" varchar(50) NULL,
    "Multiple Lines" varchar(50) NULL,
    "Internet Service" varchar(50) NULL,
    "Internet Type" varchar(50) NULL,
    "Avg Monthly GB Download" int4 NULL,
    "Online Security" varchar(50) NULL,
    "Online Backup" varchar(50) NULL,
    "Device Protection Plan" varchar(50) NULL,
    "Premium Tech Support" varchar(50) NULL,
    "Streaming TV" varchar(50) NULL,
    "Streaming Movies" varchar(50) NULL,
    "Streaming Music" varchar(50) NULL,
    "Unlimited Data" varchar(50) NULL,
    "Contract" varchar(50) NULL,
    "Paperless Billing" varchar(50) NULL,
    "Payment Method" varchar(50) NULL,
    "Monthly Charge" float8 NULL,
    "Total Charges" numeric NULL,
    "Total Refunds" numeric NULL,
    "Total Extra Data Charges" int4 NULL,
    "Total Long Distance Charges" varchar(50) NULL,
    "Total Revenue" numeric NULL,
    CONSTRAINT telco_customer_churn_services_pkey PRIMARY KEY ("Customer_ID")
);

ALTER TABLE telco_customer_churn_services OWNER TO innovacion_2025;
GRANT ALL ON TABLE telco_customer_churn_services TO innovacion_2025;


-- =========================================================
-- TABLA: telco_customer_churn_location
-- =========================================================
CREATE TABLE telco_customer_churn_location (
    "Customer_ID" varchar(50) NOT NULL,
    "Count" int4 NULL,
    "Country" varchar(50) NULL,
    "State" varchar(50) NULL,
    "City" varchar(50) NULL,
    "Zip_Code" int4 NULL,
    "Lat Long" varchar(50) NULL,
    "Latitude" float8 NULL,
    "Longitude" float8 NULL,
    CONSTRAINT telco_customer_churn_location_pkey PRIMARY KEY ("Customer_ID"),
    CONSTRAINT fk_location_population FOREIGN KEY ("Zip_Code") 
        REFERENCES telco_customer_churn_population("Zip_Code")
);

ALTER TABLE telco_customer_churn_location OWNER TO innovacion_2025;
GRANT ALL ON TABLE telco_customer_churn_location TO innovacion_2025;


-- =========================================================
-- TABLA: telco_customer_churn_demographics
-- =========================================================
CREATE TABLE telco_customer_churn_demographics (
    "Customer_ID" varchar(50) NOT NULL,
    "Count" int4 NULL,
    "Gender" varchar(50) NULL,
    "Age" int4 NULL,
    "Under 30" varchar(50) NULL,
    "Senior Citizen" varchar(50) NULL,
    "Married" varchar(50) NULL,
    "Dependents" varchar(50) NULL,
    "Number of Dependents" int4 NULL,
    CONSTRAINT telco_customer_churn_demographics_pkey PRIMARY KEY ("Customer_ID"),
    CONSTRAINT fk_demographics_location FOREIGN KEY ("Customer_ID") 
        REFERENCES telco_customer_churn_location("Customer_ID")
);

ALTER TABLE telco_customer_churn_demographics OWNER TO innovacion_2025;
GRANT ALL ON TABLE telco_customer_churn_demographics TO innovacion_2025;


-- =========================================================
-- TABLA: telco_customer_churn_status
-- =========================================================
CREATE TABLE telco_customer_churn_status (
    "Customer_ID" varchar(50) NOT NULL,
    "Count" int4 NULL,
    "Quarter" varchar(50) NULL,
    "Satisfaction Score" int4 NULL,
    "Customer Status" varchar(50) NULL,
    "Churn Label" varchar(50) NULL,
    "Churn Value" int4 NULL,
    "Churn Score" int4 NULL,
    "CLTV" int4 NULL,
    "Churn Category" varchar(50) NULL,
    "Churn Reason" varchar(50) NULL,
    CONSTRAINT telco_customer_churn_status_pkey PRIMARY KEY ("Customer_ID"),
    CONSTRAINT fk_status_churn FOREIGN KEY ("Customer_ID") 
        REFERENCES telco_customer_churn("Customer_ID"),
    CONSTRAINT fk_status_demographics FOREIGN KEY ("Customer_ID") 
        REFERENCES telco_customer_churn_demographics("Customer_ID"),
    CONSTRAINT fk_status_services FOREIGN KEY ("Customer_ID") 
        REFERENCES telco_customer_churn_services("Customer_ID")
);

ALTER TABLE telco_customer_churn_status OWNER TO innovacion_2025;
GRANT ALL ON TABLE telco_customer_churn_status TO innovacion_2025;



