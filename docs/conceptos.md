### 🧠 Conceptos Clave (con ejemplo práctico)

- **Índices:** Estructuras que la base de datos crea sobre columnas para **acceder rápidamente a los registros** sin tener que leer toda la tabla.  
  - Funcionan como el índice de un libro: apuntan a las filas que cumplen ciertas condiciones.  
  - Se pueden crear sobre columnas de texto, numéricas o fechas.  
  - Mejoran el rendimiento de consultas (`WHERE`, `JOIN`, `ORDER BY`), pero consumen espacio y pueden afectar la velocidad de inserciones o actualizaciones.  
  - **Ejemplo práctico en este proyecto:**  
    ```sql
    -- Creamos un índice sobre la columna Contract
    CREATE INDEX idx_contract 
    ON telco_customer_churn_services("Contract");

    -- Medimos el rendimiento de una consulta usando el índice
    EXPLAIN ANALYZE
    SELECT *
    FROM telco_customer_churn_services
    WHERE "Contract" = 'Month-to-Month';
    ```
    - Aquí creamos un índice para acelerar la búsqueda de clientes con contratos mensuales.  
    - `EXPLAIN ANALYZE` permite **verificar cuánto mejora la consulta** usando el índice.

### 🔎 Ejemplo visual de un índice

#### Tabla original (sin índice)

| Fila | Contract       |
|------|----------------|
| 1    | Month-to-Month |
| 2    | One year       |
| 3    | Month-to-Month |
| 4    | Two year       |
| 5    | Month-to-Month |

#### Índice `idx_contract` (mapa creado por PostgreSQL)

| Valor de Contract | Filas donde aparece |
|-------------------|----------------------|
| Month-to-Month    | [1, 3, 5]           |
| One year          | [2]                 |
| Two year          | [4]                 |

---


- **ID / Primary Key:** Columna que identifica de manera única cada fila de la tabla.  
  - Ejemplo: `Customer_ID`.  
  - Garantiza unicidad y sirve para referencias en joins.

- **Transacciones (COMMIT / ROLLBACK):** Permiten ejecutar varias operaciones como un bloque.  
  - `COMMIT` confirma los cambios de manera definitiva.  
  - `ROLLBACK` revierte los cambios si ocurre algún error o queremos deshacerlos.  
  - Útiles para pruebas, limpieza de datos y aseguramiento de integridad.
