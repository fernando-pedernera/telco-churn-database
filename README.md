# Telco Churn DB 📊

Repositorio para el modelado, carga y análisis del dataset de **Customer Churn en Telco** 

## 🚀 Instalación y uso

### 1. Crear base de datos

En PostgreSQL:

```sql
CREATE DATABASE telco_churn;
```

### 2. Ejecutar el esquema

```bash
psql -U <usuario> -d telco_churn -f sql/schema.sql
```

### 3. Cargar datos

```bash
psql -U <usuario> -d telco_churn -f sql/insert_data.sql
```

### 4. Ejecutar consultas

Ejemplo:

```bash
psql -U <usuario> -d telco_churn -f sql/queries/churn_rate.sql
```

## 📊 Dataset

- Fuente: IBM Sample Data  
- Contiene información de clientes, servicios contratados y si abandonaron o no la empresa.

## 🛠️ Tecnología

- PostgreSQL  

## 📄 Licencia

Este proyecto está bajo licencia MIT.
