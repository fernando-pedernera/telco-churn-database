
# Modelo Relacional

Este documento describe el **diseño de la base de datos** para el análisis de churn.

### 🎯 Objetivos del modelo
- Representar clientes y sus características demográficas.
- Modelar servicios contratados (telefonía, internet, TV, etc.).
- Seguir el estatus de churn (abandono o retención).
- Permitir cálculos de KPIs (ej. churn rate, promedio de tenure).

### 📐 Tablas principales
1. **Customers**: datos básicos de los clientes (ID, género, edad, estado civil).  
2. **Demographics**: variables demográficas (población, segmento, ingresos).  
3. **Location**: datos geográficos (estado, ciudad, código postal).  
4. **Services**: servicios contratados (internet, streaming, seguridad).  
5. **Status**: estado de la relación (activo, churn, meses de permanencia).  
6. **Population**: nivel agregado de población para análisis regional.

### 🔗 Relaciones
- Un **cliente** se relaciona con:
  - Una **ubicación**.
  - Un **conjunto de servicios**.
  - Un **estatus de churn**.
- **Demographics** y **Population** enriquecen el análisis agregando contexto.

### 🖼️ ERD
![ERD](./er_diagram.png)
