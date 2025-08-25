
# Reporte del Proyecto Telco Churn

### 🔎 Introducción
El **Customer Churn** es un problema crítico en telecomunicaciones.  
Este proyecto busca analizar el dataset de Telco para entender patrones de abandono de clientes.

### 📊 Dataset
- Fuente: IBM / Kaggle  
- Registros: ~7.000 clientes  
- Variables: demográficas, servicios, facturación, churn (sí/no)

### ⚙️ Metodología
1. **Carga y modelado** en PostgreSQL.  
2. **Normalización** del dataset original en múltiples tablas.  
3. **Exploración** con queries SQL y notebooks.  
4. **Definición de KPIs** clave:
   - Tasa de churn
   - Tenure promedio
   - Servicios más asociados al churn

### 📈 Hallazgos iniciales
- Los clientes con contratos mensuales presentan mayor churn.  
- Servicios adicionales (ej. streaming, seguridad online) están correlacionados con menor churn.  
- El tenure promedio de clientes churn es significativamente menor.

### 🚀 Próximos pasos
- Construir vistas con KPIs listos para dashboards.  
- Experimentar con modelos predictivos en Python/ML.  
- Automatizar carga con Docker y scripts reproducibles.
