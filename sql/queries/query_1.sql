/* Nivel Junior: Fundamentos y Consultas Básicas*/

/*Consulta de datos demográficos básicos

Muestra el número de clientes por género y estado civil

Filtra solo para clientes mayores de 30 años

Ordena por cantidad descendente*/
	
select count("Customer_ID") as total_clientes, 
	   tabla_filtrada."Gender", 
	   tabla_filtrada."Married"
from(
select *from telco_customer_churn_demographics
where "Age" > 30) as tabla_filtrada
group by tabla_filtrada."Gender", tabla_filtrada."Married"
order by total_clientes desc 



/*Análisis de servicios contratados

Calcula el porcentaje de clientes con servicio de internet vs solo telefonía

Agrupa por tipo de servicio de internet (DSL, Fibra Óptica)

Muestra el gasto mensual promedio para cada grupo*/


select COUNT(distinct cc."Customer_ID") as total_clientes,
	   cc."Internet Type",
	   COUNT(distinct cc."Customer_ID") / select * ,
	   SUM(cc."Monthly Charge")
from telco_customer_churn_services cc 
group by cc."Internet Type"



/*Análisis de servicios contratados

Calcula el porcentaje de clientes con servicio de internet vs solo telefonía

Agrupa por tipo de servicio de internet (DSL, Fibra Óptica)

Muestra el gasto mensual promedio para cada grupo*/

select COUNT(distinct cc."Customer_ID") as total_clientes,
cc."Internet Type",
COUNT(distinct cc."Customer_ID") filter (where cc."Internet Service"  = 'Yes') * 100.0 / COUNT(distinct cc."Customer_ID") as por_internet,
COUNT(distinct cc."Customer_ID") filter (where cc."Phone Service"  = 'Yes') * 100.0 / COUNT(distinct cc."Customer_ID") as por_phone
from telco_customer_churn_services cc
group by cc."Internet Type" 




/*Distribución geográfica de clientes

Identifica las 5 ciudades con más clientes

Para cada ciudad, muestra la población total (usa JOIN con la tabla Population)

Calcula la penetración de mercado (clientes/población)*/

select cl."City", count(distinct cl."Customer_ID") as total, sum(cp."Population" ) as poblacion,
	   count(distinct cl."Customer_ID")/ sum(cp."Population" ) as penetracion_mercado
from telco_customer_churn_location cl
join telco_customer_churn_population cp on cl."Zip_Code" = cp."Zip_Code"
group by cl."City" 
order by total desc
limit 5


/*Churn básico por segmentos

Calcula la tasa de churn (clientes que se fueron) por tipo de contrato

Muestra también el promedio de meses de antigüedad para cada grupo*/

select cs."Customer Status", COUNT(distinct cs."Customer_ID") as total_cientes, cc."Contract" 
from telco_customer_churn_status cs
join telco_customer_churn cc on cc."Customer_ID" = cs."Customer_ID"
group by cs."Customer Status", cc."Contract" 




select COUNT(distinct cs."Customer_ID") filter (where cs."Customer Status" = 'Churned') as total_cientes, 
round (COUNT(distinct cs."Customer_ID") *100.0 / (select count(*) from telco_customer_churn_status cs),2) as churn_rate,
cc."Contract", round (avg(cc."Tenure Months"),2) as prom_permanencia_mens
from telco_customer_churn_status cs
join telco_customer_churn cc on cc."Customer_ID" = cs."Customer_ID"
where cs."Customer Status" = 'Churned'
group by cs."Customer Status", cc."Contract" 


/*Métodos de pago preferidos*/

/*Analiza qué métodos de pago son más comunes entre clientes con facturación electrónica

Compara con los que usan facturación tradicional*/



select cc."Payment Method", 
       COUNT(distinct cc."Customer_ID") filter (where cc."Paperless Billing" = 'No') as factura_electronica,
       COUNT(distinct cc."Customer_ID") filter (where cc."Paperless Billing" = 'Yes') as factura_tradicional
from telco_customer_churn cc 
group by cc."Payment Method"
order by factura_electronica desc


/*Nivel Semi-Senior: Consultas Intermedias y Análisis Multidimensional*/

/*Análisis de cohortes por antigüedad

Agrupa clientes en cohortes trimestrales según su fecha de ingreso

Calcula la retención a los 3, 6 y 12 meses para cada cohorte

Usa funciones de ventana para calcular porcentajes*/



CREATE TEMP VIEW cohortes_simplificado AS
SELECT 
  "Customer_ID",
  "Tenure Months" AS tenure_months,
  "Churn Value" AS churn_value,
  DATE_TRUNC('quarter', '2023-09-30'::date - ("Tenure Months" || ' months')::interval) AS join_cohort
FROM telco_customer_churn ;


create temp view cohort_retention as
select join_cohort, 
	   count(*) total_cohort,
	   count(*) filter (where tenure_months >= 3 and churn_value = 0) as retention_3m,
	   count(*) filter (where tenure_months >= 6 and churn_value = 0) as retention_6m,
	   count(*) filter (where tenure_months >=12 and churn_value = 0) as retencion_12m
from cohortes_simplificado 
GROUP BY join_cohort
order by join_cohort


select 
	join_cohort,
	total_cohort,
	retention_3m,
	round(retention_3m * 100.0 / total_cohort, 2) as retention_3m_pct,
	round(AVG(retention_3m *100.0 /total_cohort) over(),2) as avg_retention_3m_cpt_global,
	
    retention_6m,
    round(retention_6m *100.0 /total_cohort, 2) as retention_6m_cpt,
    round(avg(retention_6m * 100.0 / total_cohort) over (), 2) as avg_retention_6m_cpt_global,
    
    retencion_12m,
    round( retencion_12m * 100.0 /total_cohort,2) as retention_12m_pct,
    round(avg(retencion_12m * 100.0 /total_cohort) over(), 2 ) as avg_retention_12m_pct_global
    
    from cohort_retention
    ORDER BY join_cohort;
    
    
 

    /* Segmentación RFM (Recency, Frequency, Monetary)

Crea segmentos RFM basados en:

Recency: meses desde última interacción

Frequency: servicios contratados

Monetary: CLTV (Customer Lifetime Value)

Identifica qué segmentos tienen mayor tasa de churn*/
    

-- 1. Calcular componentes básicos por cliente
CREATE MATERIALIZED VIEW servicios_mat AS
SELECT cs."Customer_ID", 
       SUM(
            (cs."Phone Service" = 'yes')::int +  
            (cs."Multiple Lines"= 'Yes')::int * 2 + 
            (cs."Internet Service"='Yes')::int *3 + 
            (cs."Online Security" != 'No')::int * 2
       ) AS score_servicios
FROM telco_customer_churn_services cs
GROUP BY cs."Customer_ID";






-- 2. Calcular métricas RFM
CREATE MATERIALIZED VIEW metricas_rfm as
select cc."Customer_ID", cc."Tenure Months", cs."CLTV", cs."Churn Value", 
		DATE_TRUNC('quarter', CURRENT_DATE - (cc."Tenure Months"  || ' months')::interval) AS recency_date, sm.score_servicios, 
		(cs."CLTV"* 0.7 + coalesce(ccs."Monthly Charge"::decimal, 0) * 0.3) as customer_value 
from telco_customer_churn cc
join telco_customer_churn_status cs on cc."Customer_ID" = cs."Customer_ID"
join telco_customer_churn_services ccs on cc."Customer_ID" = ccs."Customer_ID"
join servicios_mat sm on cc."Customer_ID" = sm."Customer_ID"
where cs."Customer Status" in ('Stayed','Churned')


-- 3. Asignar puntuaciones RFM
CREATE MATERIALIZED VIEW puntuaciones_rfm as
select fm."Customer_ID", 
		    ntile(5) over (order by fm.recency_date desc) as R, 
			ntile(5) over (order by fm.score_servicios) as F, 
			ntile(5) over (order by fm.customer_value) as M, 
			fm."Churn Value",fm."Tenure Months",fm."CLTV"
from metricas_rfm fm


-- 4. Resultados finales agrupados por segmento

select 
	case
		when (R + F + M) >= 13 then 'Campeones'
		when (R + F + M) >= 10 then 'Leales'
		when (R + F + M) >= 7 then 'Potenciales'
		when (R + F + M) >= 4 then 'En riesgo' 
		else 'Dormidos'	
	end as segmento_rfm,
	count(*) as clientes, 
	(round (100.0 * sum(pr."Churn Value") / count(*), 1)) as tasa_abandono, 
	round(avg(R + F + M), 1) as score_promedio, round(avg(pr."CLTV"), 0) as cltv_promedio
	from puntuaciones_rfm pr 
	group by segmento_rfm 
	order by tasa_abandono desc;



/*3. **Análisis de razones de churn con subconsultas**
    - Identifica las 3 principales razones de churn por categoría
    - Para cada razón, muestra el CLTV promedio perdido
    - Usa una subconsulta para comparar con el CLTV promedio de clientes activo*/


with top_razones as (
select count(cc."Customer_ID") as total, cc."Churn Reason", round(avg (cc."CLTV"),2 ) as prom_perdido
from telco_customer_churn cc
where cc."Churn Label" = 'Yes'
group by cc."Churn Reason"
order by total desc
limit 3
),
CLTV_prom as (
select tp."Churn Reason", tp.prom_perdido ,
(select round(AVG(cc."CLTV"),2)
from telco_customer_churn cc
where cc."Churn Value" = 0) as prom_activo
from top_razones tp
)
select cl."Churn Reason" , cl.prom_perdido, cl.prom_activo, (cl.prom_perdido - cl.prom_activo) as diferencia
from CLTV_prom cl


/*4. **Impacto de ofertas en retención**
    - Analiza si los clientes que aceptaron ofertas tienen menor probabilidad de churn
    - Compara por tipo de oferta y antigüedad del cliente
    - Usa JOINs entre múltiples tablas*/


with data_base as (
select tccs."Customer_ID", tcc."Churn Label", tccs."Offer", tccs."Tenure in Months"
from telco_customer_churn_services tccs 
join telco_customer_churn tcc on tccs."Customer_ID" = tcc."Customer_ID"
order by tccs."Tenure in Months" desc
),
agrupar as (
select db."Offer",
	   case 
       	when db."Tenure in Months" between 0 and 12 then '0-12 meses'
       	when db."Tenure in Months" between 13 and 24 then '13-24 meses'
       	when db."Tenure in Months" between 25 and 36 then '25-36 meses'
       	when db."Tenure in Months" > 36 then 'más de 36 meses'
       end as rango_antiguedad, 
       count(*) as cantidad_clientes			      
from data_base db
group by db."Offer", rango_antiguedad 
)
select * 
from agrupar
order by agrupar."Offer", rango_antiguedad ;



/*Análisis de correlación entre servicios

Identifica qué combinaciones de servicios (ej: streaming + seguridad online) tienen menor tasa de churn

Usa CTEs para calcular las combinaciones más comunes*/

-- CTE: todas las combinaciones posibles de servicios y su cantidad total
with combinaciones_totales as (
  select
    (case when cr."Online Security" = 'Yes' then 'S,' else '' end) ||
    (case when cr."Online Backup" = 'Yes' then 'B,' else '' end) ||
    (case when cr."Device Protection Plan" = 'Yes' then 'D,' else '' end) ||
    (case when cr."Premium Tech Support" = 'Yes' then 'T,' else '' end) ||
    (case when cr."Streaming TV" = 'Yes' then 'TV,' else '' end) ||
    (case when cr."Streaming Movies" = 'Yes' then 'M,' else '' end) ||
    (case when cr."Streaming Music" = 'Yes' then 'MU,' else '' end) ||
    (case when cr."Unlimited Data"= 'Yes' then 'U,' else '' end)
    as combo_servicios,
    count(*) as cantidad_total
  from telco_customer_churn_services cr
  group by cr."Online Security", 
           cr."Online Backup",
           cr."Device Protection Plan", 
           cr."Premium Tech Support", 
           cr."Streaming TV", 
           cr."Streaming Movies", 
           cr."Streaming Music", 
           cr."Unlimited Data"
),
--
combinaciones_churn as (
  select
    (case when cr."Online Security" = 'Yes' then 'S,' else '' end) ||
    (case when cr."Online Backup" = 'Yes' then 'B,' else '' end) ||
    (case when cr."Device Protection Plan" = 'Yes' then 'D,' else '' end) ||
    (case when cr."Premium Tech Support" = 'Yes' then 'T,' else '' end) ||
    (case when cr."Streaming TV" = 'Yes' then 'TV,' else '' end) ||
    (case when cr."Streaming Movies" = 'Yes' then 'M,' else '' end) ||
    (case when cr."Streaming Music" = 'Yes' then 'MU,' else '' end) ||
    (case when cr."Unlimited Data" = 'Yes' then 'U,' else '' end)
    as combo_servicios,
    count(*) as cantidad_churn
  from telco_customer_churn_services cr
  join telco_customer_churn_status cs 
    on cr."Customer_ID" = cs."Customer_ID"
  where cs."Churn Label" = 'Yes'
  group by cr."Online Security", 
           cr."Online Backup",
           cr."Device Protection Plan", 
           cr."Premium Tech Support", 
           cr."Streaming TV", 
           cr."Streaming Movies", 
           cr."Streaming Music", 
           cr."Unlimited Data"
)
select 
  ct.combo_servicios,
  ct.cantidad_total,
  coalesce(cc.cantidad_churn, 0) as cantidad_churn,
  round(
    coalesce(cc.cantidad_churn, 0) * 100.0 / ct.cantidad_total,
    2
  ) as porcentaje_churn
from combinaciones_totales ct
left join combinaciones_churn cc 
  on ct.combo_servicios = cc.combo_servicios
order by porcentaje_churn desc;



/*Nivel Senior: Consultas Avanzadas y Optimización
Objetivo: Dominar consultas complejas, optimización y análisis predictivo básico*/

/*Modelo de propensión al churn (básico)

Crea una consulta que asigne una probabilidad de churn basada en:

Puntaje de churn

Antigüedad

Número de servicios

Historial de pagos

Usa múltiples CTEs y cálculos condicionales*/


with normalizar as (
  	 select tccs."Customer_ID", (tccs."Churn Score"::decimal / 100) as churn_score_normalized
  	 from telco_customer_churn_status tccs 
),
categorizar as (
	 select tccs."Customer_ID", 
	 case
	 	when tccs."Tenure in Months" > 24 then 'riesgo bajo'
	 	when tccs."Tenure in Months" between 12 and 24 then 'riesgo medio'
	 	when tccs."Tenure in Months" < 12 then 'riesgo alto'
	 end as riesgo_antiguedad
	 from telco_customer_churn_services tccs 	
),
servicios_activos as (
	 select tccs2."Customer_ID" as clientes,
	        (
	 		    case when tccs2."Internet Service" = 'Yes' then 1 else 0 end +
	 		    case when tccs2."Phone Service" = 'Yes' then 1 else 0 end +
	 		    case when tccs2."Multiple Lines" = 'Yes' then 1 else 0 end +
	 		    case when tccs2."Device Protection Plan" = 'Yes' then 1 else 0 end +
	 			case when tccs2."Online Backup" = 'Yes' then 1 else 0 end +
	 			case when tccs2."Online Security" = 'Yes' then 1 else 0 end +
	 			case when tccs2."Premium Tech Support" = 'Yes' then 1 else 0 end +
	 			case when tccs2."Streaming Movies" = 'Yes' then 1 else 0 end +
	 			case when tccs2."Streaming Music" = 'Yes' then 1 else 0 end +
	 			case when tccs2."Streaming TV" = 'Yes' then 1 else 0 end +
	 			case when tccs2."Unlimited Data"= 'Yes' then 1 else 0 end )
	 		    as total_servicios
	 from telco_customer_churn_services tccs2
	 group by clientes 
),
histo_pagos as(
select tccs3."Customer_ID", 
	   tccs3."Total Charges",
       tccs3."Total Refunds", 
       tccs3."Total Revenue",
       (tccs3."Total Revenue"::decimal - tccs3."Total Refunds"::decimal)/tccs3."Total Charges"::decimal as proporcion
from telco_customer_churn_services tccs3
)
SELECT 
  n."Customer_ID",
  ROUND(n.churn_score_normalized, 3) AS churn_score_normalized,
  c.riesgo_antiguedad,
  h."Total Charges",
  h."Total Refunds",
  h."Total Revenue",
  ROUND(h.proporcion, 3) AS proporcion,
  -- Riesgo valor con alias para reutilizar
  CASE
    WHEN c.riesgo_antiguedad = 'riesgo bajo' THEN 0.2
    WHEN c.riesgo_antiguedad = 'riesgo medio' THEN 0.5
    ELSE 0.8
  END AS riesgo_valor,
  ROUND(s.total_servicios / 11.8, 3) AS servicios_normalizados,
  -- Calculo de churn final usando riesgo_valor en subconsulta anidada para evitar repetir el CASE
  ROUND(
    0.4 * n.churn_score_normalized + 
    0.3 * CASE
            WHEN c.riesgo_antiguedad = 'riesgo bajo' THEN 0.2
            WHEN c.riesgo_antiguedad = 'riesgo medio' THEN 0.5
            ELSE 0.8
          END +
    0.2 * (1 - (s.total_servicios / 11.8)) + 
    0.1 * (1 - h.proporcion)
  , 3) AS probabilidad_churn_final
FROM normalizar n
LEFT JOIN servicios_activos s ON n."Customer_ID" = s.clientes
LEFT JOIN histo_pagos h ON n."Customer_ID" = h."Customer_ID"
LEFT JOIN categorizar c ON n."Customer_ID" = c."Customer_ID"



/*Análisis de supervivencia (tiempo hasta churn)

Calcula la probabilidad acumulada de permanencia por mes

Usa funciones de ventana para calcular tasas de supervivencia

Compara entre diferentes segmentos de clientes*/



with eventos_cliente as (
select tccs."Customer_ID" , 
DATE_TRUNC('quarter', '2023-09-30'::date - (tcc."Tenure Months"  || ' months')::interval) as fecha_inicio, 
case 
	when tcc."Churn Label" = 'Yes'then DATE_TRUNC('quarter', '2023-09-30'::date) else null end as fecha_churn, 
	tcc."Churn Value" as hizo_churn,
	case
		when tcc."Contract" ='Month-to-month' and tcc."Tenure Months" < 12 then 'riesgo alto' 
		when tcc."Contract" ='Month-to-month' and tcc."Tenure Months" >= 12 then 'riesgo alto'
		when tcc."Contract" = 'One year' and tcc."Tenure Months" <= 12 then 'riesgo medio'
		when tcc."Contract" = 'One year' and tcc."Tenure Months" > 12 then 'riesgo medio'
		when tcc."Contract" = 'Two year' and tcc."Tenure Months" <= 24 then 'riesgo bajo'
		when tcc."Contract" = 'Two year' and tcc."Tenure Months" > 24 then 'riesgo bajo'
		else 'no clasificado'
	end as segmetacion_clientes,
	tcc."Tenure Months" 
from telco_customer_churn_status tccs
join telco_customer_churn tcc on tccs."Customer_ID" = tcc."Customer_ID"
),
meses as (
select generate_series(1,72) as mes
),
tabla_expandida as (
select ev."Customer_ID", m.mes, 
			case 
			  when ev."hizo_churn" = 0 and ev."Tenure Months" = m.mes then 1 else 0
			end as churn
from eventos_cliente ev  
join meses m on m.mes <= ev."Tenure Months"
order by ev."Customer_ID", m.mes 
),
mes_segmento as (
select te.mes, ec.segmetacion_clientes, count(*) as clientes_iniciales, sum(te.churn) as clientes_churn
from tabla_expandida te
join eventos_cliente ec on ec."Customer_ID" = te."Customer_ID"
group by te.mes, ec.segmetacion_clientes
order by te.mes, ec.segmetacion_clientes
),
tasa_supervivencia as (
select ms.mes, ms.segmetacion_clientes, 
round(((ms.clientes_iniciales::decimal - ms.clientes_churn::decimal) / ms.clientes_iniciales::decimal),2) as tasa_supervivencia
from mes_segmento ms
),
probabilidad_acumulada as (
  select 
    mes,
    segmetacion_clientes,
    tasa_supervivencia,
    -- 🔧 Aquí reemplazás los ceros para evitar el error
    exp(sum(ln(case 
                 when tasa_supervivencia = 0 then 0.0001 
                 else tasa_supervivencia 
              end)) 
        over (partition by segmetacion_clientes order by mes)) 
    as probabilidad_acumulada
  from tasa_supervivencia
)
select * 
from probabilidad_acumulada;




/* Optimización de consulta para reporte ejecutivo

Crea una consulta única que resuma:

Tendencias de churn trimestrales

CLTV por segmento demográfico

Penetración de servicios

Optimiza con índices sugeridos y explica el plan de ejecución*/

with eventos_cliente as (
select tccs."Customer_ID" , 
DATE_TRUNC('quarter', '2023-09-30'::date - (tcc."Tenure Months"  || ' months')::interval) as fecha_inicio, 
case 
	when tcc."Churn Label" = 'Yes'then DATE_TRUNC('quarter', '2023-09-30'::date) else null end as fecha_churn, 
	tcc."Churn Value" as hizo_churn,
	case
		when tcc."Contract" ='Month-to-month' and tcc."Tenure Months" < 12 then 'riesgo alto' 
		when tcc."Contract" ='Month-to-month' and tcc."Tenure Months" >= 12 then 'riesgo alto'
		when tcc."Contract" = 'One year' and tcc."Tenure Months" <= 12 then 'riesgo medio'
		when tcc."Contract" = 'One year' and tcc."Tenure Months" > 12 then 'riesgo medio'
		when tcc."Contract" = 'Two year' and tcc."Tenure Months" <= 24 then 'riesgo bajo'
		when tcc."Contract" = 'Two year' and tcc."Tenure Months" > 24 then 'riesgo bajo'
		else 'no clasificado'
	end as segmetacion_clientes,
	tcc."Tenure Months", tcc."Monthly Charges", tcc."Total Charges", 
	tcc."Monthly Charges" * tcc."Total Charges" as cltv_estimado,
	tcc."Gender", tcc."Senior Citizen", tcc."Partner", tcc."Dependents", tcc."Payment Method",
	tcc."Internet Service", tcc."Phone Service", tcc."Multiple Lines", tcc."Online Security",
	tcc."Online Backup", tcc."Device Protection",tcc."Tech Support", tcc."Streaming TV", tcc."Streaming Movies",tcc."Contract"
from telco_customer_churn_status tccs
join telco_customer_churn tcc on tccs."Customer_ID" = tcc."Customer_ID"
),
churn_trimestral as (
select ec.fecha_churn, ec.segmetacion_clientes, count(*)
from eventos_cliente ec where ec.hizo_churn = 1
group by ec.fecha_churn, ec.segmetacion_clientes
),
cltv_demografico as (
select  ev.segmetacion_clientes, ev."Contract", 
ev."Gender", ev."Senior Citizen", round(avg(ev.cltv_estimado),2) as promedio_cltv
from eventos_cliente ev
group by ev."Gender", ev."Senior Citizen", ev.segmetacion_clientes, ev."Contract"
),
servicios_binarios as (
select ec.segmetacion_clientes, ec."Contract", 
	   case  
	   	when ec."Internet Service" = 'No' then 0 else 1
	   end as internet,
	   case  
	   	when ec."Phone Service" = 'Yes' then 1 else 0
	   end as phone_service,
	    case  
	   	when ec."Multiple Lines"  = 'No phone service' then 0 else 1
	   end as multiple_lines,
	   case  
	   	when ec."Online Security"  = 'Yes' then 1 else 0
	   end as online_security,
	   case  
	   	when ec."Online Backup"  = 'Yes' then 1 else 0
	   end as online_backup,
	   case  
	   	when ec."Device Protection"  = 'Yes' then 1 else 0
	   end as device_protection,
	    case  
	   	when ec."Tech Support"  = 'Yes' then 1 else 0
	   end as tech_support,
	   case  
	   	when ec."Streaming TV"  = 'Yes' then 1 else 0
	   end as streaming_TV,
	      case  
	   	when ec."Streaming Movies"  = 'Yes' then 1 else 0
	   end as streaming_movies
from eventos_cliente ec
),
agregaciones as (
select sb.segmetacion_clientes, 
       sb."Contract", 
      	AVG(sb.internet) AS proporcion_internet,
		AVG(sb.phone_service) AS proporcion_phone,
		AVG(sb.multiple_lines) AS proporcion_multiple_lines,
		AVG(sb.online_security) AS proporcion_online_security,
		AVG(sb.online_backup) AS proporcion_online_backup,
		AVG(sb.device_protection) AS proporcion_device_protection,
		AVG(sb.tech_support) AS proporcion_tech_support,
		AVG(sb.streaming_TV) AS proporcion_streaming_TV,
		AVG(sb.streaming_movies) AS proporcion_streaming_movies
from servicios_binarios sb
group by sb.segmetacion_clientes, 
       sb."Contract"
)
select*
from agregaciones;



/*Análisis de impacto económico del churn

Calcula el ingreso perdido por churn en el último trimestre

Proyecta la pérdida anual si la tasa se mantiene

Identifica los 3 servicios con mayor impacto económico al perderse*/



with trimestre_actual as (
select tcc."Customer_ID", 
case 
	when tcc."Churn Label" = 'Yes'then DATE_TRUNC('quarter', '2023-09-30'::date) else null end as fecha_churn, 
	tcc."Monthly Charges", 
	tcc."Contract",
	case
		when tcc."Contract" ='Month-to-month' and tcc."Tenure Months" < 12 then 'riesgo alto' 
		when tcc."Contract" ='Month-to-month' and tcc."Tenure Months" >= 12 then 'riesgo alto'
		when tcc."Contract" = 'One year' and tcc."Tenure Months" <= 12 then 'riesgo medio'
		when tcc."Contract" = 'One year' and tcc."Tenure Months" > 12 then 'riesgo medio'
		when tcc."Contract" = 'Two year' and tcc."Tenure Months" <= 24 then 'riesgo bajo'
		when tcc."Contract" = 'Two year' and tcc."Tenure Months" > 24 then 'riesgo bajo'
		else 'no clasificado'
	end as segmetacion_clientes
from telco_customer_churn tcc
where tcc."Churn Value" = 1
),
ingresos_perdidos as (
select sum(ta."Monthly Charges") as ingresos_trimestrales, sum(ta."Monthly Charges") * 4 as ingresos_anuales_proyectados
from trimestre_actual ta 
),
servicios_churn_binarios as (
select ec."Customer_ID", ta."Monthly Charges",
	   case  
	   	when ec."Internet Service" = 'No' then 0 else 1
	   end as internet,
	   case  
	   	when ec."Phone Service" = 'Yes' then 1 else 0
	   end as phone_service,
	    case  
	   	when ec."Multiple Lines"  = 'No phone service' then 0 else 1
	   end as multiple_lines,
	   case  
	   	when ec."Online Security"  = 'Yes' then 1 else 0
	   end as online_security,
	   case  
	   	when ec."Online Backup"  = 'Yes' then 1 else 0
	   end as online_backup,
	   case  
	   	when ec."Device Protection"  = 'Yes' then 1 else 0
	   end as device_protection,
	    case  
	   	when ec."Tech Support"  = 'Yes' then 1 else 0
	   end as tech_support,
	   case  
	   	when ec."Streaming TV"  = 'Yes' then 1 else 0
	   end as streaming_TV,
	      case  
	   	when ec."Streaming Movies"  = 'Yes' then 1 else 0
	   end as streaming_movies 
from telco_customer_churn ec
join trimestre_actual ta on ec."Customer_ID" = ta."Customer_ID"
),
impacto_economico_servicios AS (
    SELECT 'internet' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE internet = 1
--
    UNION ALL
--
    SELECT 'phone_service' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE phone_service = 1
--
    UNION ALL
--
    SELECT 'multiple_lines' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE multiple_lines = 1
--
    UNION ALL
--
    SELECT 'online_security' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE online_security = 1
--
    UNION ALL
--
    SELECT 'online_backup' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE online_backup = 1
--
    UNION ALL
--
    SELECT 'device_protection' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE device_protection = 1
--
    UNION ALL
--
    SELECT 'tech_support' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE tech_support = 1
--
    UNION ALL
--
    SELECT 'streaming_TV' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE streaming_TV = 1
--
    UNION ALL
--
    SELECT 'streaming_movies' AS servicio, "Monthly Charges" AS ingreso_perdido
    FROM servicios_churn_binarios
    WHERE streaming_movies = 1
)
SELECT servicio, 
       SUM(ingreso_perdido) AS perdida_total
FROM impacto_economico_servicios
GROUP BY servicio
ORDER BY perdida_total DESC



/*Consulta para estrategia de retención

Desarrolla una consulta que identifique:

Clientes de alto valor en riesgo (CLTV alto + churn score alto)

Servicios que les faltan (oportunidades de upselling)

Ofertas disponibles para ellos

Usa múltiples JOINs y subconsultas correlacionadas*/


with clientes_valor_riesgo as ( 
select tcc."Customer_ID", tcc."CLTV", tcc."Churn Score"
from telco_customer_churn tcc, 
(select 
 PERCENTILE_CONT(0.75) within group (order by tcc."CLTV") as cltv_75,
 PERCENTILE_CONT(0.75) within group (order by tcc."Churn Score" ) as churn_score_75
from telco_customer_churn tcc) as umbrales 
where tcc."CLTV" >= umbrales.cltv_75 and tcc."Churn Score" >= umbrales.churn_score_75
),
servicios_churn_binarios as (
select ec."Customer_ID",
	   case  
	   	when ec."Internet Service" = 'No' then 0 else 1
	   end as internet,
	   case  
	   	when ec."Phone Service" = 'Yes' then 1 else 0
	   end as phone_service,
	    case  
	   	when ec."Multiple Lines"  = 'No phone service' then 0 else 1
	   end as multiple_lines,
	   case  
	   	when ec."Online Security"  = 'Yes' then 1 else 0
	   end as online_security,
	   case  
	   	when ec."Online Backup"  = 'Yes' then 1 else 0
	   end as online_backup,
	   case  
	   	when ec."Device Protection"  = 'Yes' then 1 else 0
	   end as device_protection,
	    case  
	   	when ec."Tech Support"  = 'Yes' then 1 else 0
	   end as tech_support,
	   case  
	   	when ec."Streaming TV"  = 'Yes' then 1 else 0
	   end as streaming_TV,
	      case  
	   	when ec."Streaming Movies"  = 'Yes' then 1 else 0
	   end as streaming_movies 
from telco_customer_churn ec
join clientes_valor_riesgo cl on ec."Customer_ID" = cl."Customer_ID"
),
servicios_faltanes AS (
    SELECT servicios_churn_binarios."Customer_ID", 'internet' AS servicio  
    FROM servicios_churn_binarios
    WHERE internet = 0
--
    UNION ALL
--
    SELECT servicios_churn_binarios."Customer_ID", 'phone_service' AS servicio
    FROM servicios_churn_binarios
    WHERE phone_service = 0
--
    UNION ALL
--
    SELECT servicios_churn_binarios."Customer_ID", 'multiple_lines' AS servicio
    FROM servicios_churn_binarios
    WHERE multiple_lines = 0
--
    UNION ALL
--
    SELECT servicios_churn_binarios."Customer_ID", 'online_security' AS servicio
    FROM servicios_churn_binarios
    WHERE online_security = 0
--
    UNION ALL
--
    SELECT servicios_churn_binarios."Customer_ID",'online_backup' AS servicio
    FROM servicios_churn_binarios
    WHERE online_backup = 0
--
    UNION ALL
--
    SELECT servicios_churn_binarios."Customer_ID", 'device_protection' AS servicio
    FROM servicios_churn_binarios
    WHERE device_protection = 0
--
    UNION ALL
--
    SELECT servicios_churn_binarios."Customer_ID", 'tech_support' AS servicio
    FROM servicios_churn_binarios
    WHERE tech_support = 0
--
    UNION ALL
--
    SELECT servicios_churn_binarios."Customer_ID", 'streaming_TV' AS servicio
    FROM servicios_churn_binarios
    WHERE streaming_TV = 0
--
    UNION ALL
--
    select servicios_churn_binarios."Customer_ID",  'streaming_movies' AS servicio
    FROM servicios_churn_binarios
    WHERE streaming_movies = 0
)
select cvr."Customer_ID", cvr.servicio    
FROM servicios_faltanes cvr
order by cvr."Customer_ID"
 








--