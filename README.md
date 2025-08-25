# Telco Churn DB 📊#

Repositorio para el modelado, carga y análisis del dataset de **Customer Churn en Telco** 

El conjunto de datos de abandono de clientes de Telco contiene información sobre una empresa de telecomunicaciones ficticia que brindó servicios de teléfono fijo e Internet a 7043 clientes en California durante el tercer trimestre. Indica qué clientes han abandonado, permanecido o se han registrado en el servicio. Se incluyen múltiples datos demográficos importantes para cada cliente, así como un Puntaje de Satisfacción, Puntaje de Abandono (Churn Score) y un índice de Valor de Vida del Cliente (CLTV).

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
- Link de la fuente original: [GitHub - Telco Customer Churn Data](https://github.com/Pranjali-d/Telco_Customer_Churn_Analysis/tree/9eeb025dcf7277d10d55efc02dc40253b91927dd/Data%20Source)  
- Contiene información de clientes, servicios contratados y si abandonaron o no la empresa.  

## 🛠️ Tecnología

- PostgreSQL  

## 📄 Licencia

Este proyecto está bajo licencia MIT.
