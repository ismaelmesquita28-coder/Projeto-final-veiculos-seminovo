-- Pergunta: em quais estados cada marca escolhida no filtro mais vende?
-- Uma linha = um estado dentro de um filtro de marca. 'Todas' significa sem filtro.

CREATE OR REPLACE TABLE gold.painel_estados AS
WITH base AS (
    SELECT m.marca, c.estado, YEAR(v.data_venda) AS ano, v.forma_pagamento, v.valor_venda
    FROM silver.vendas AS v
    JOIN silver.modelos AS m ON m.modelo_id = v.modelo_id
    JOIN silver.clientes AS c ON c.cliente_id = v.cliente_id
),
marcas AS (SELECT DISTINCT marca FROM base UNION ALL SELECT 'Todas'),
estados AS (SELECT DISTINCT estado FROM base UNION ALL SELECT 'Todos'),
agrupado AS (
    SELECT m.marca AS filtro_marca, e.estado,
           COUNT(b.valor_venda) AS total_vendas,
           COALESCE(SUM(b.valor_venda), 0) AS faturamento,
           ROUND(COALESCE(AVG(b.valor_venda), 0), 2) AS ticket_medio
    FROM marcas AS m
    CROSS JOIN (SELECT estado FROM estados WHERE estado <> 'Todos') AS e
    LEFT JOIN base AS b ON b.estado = e.estado AND (m.marca = 'Todas' OR b.marca = m.marca)
    GROUP BY m.marca, e.estado
)
SELECT *,
       ROUND(total_vendas / NULLIF(SUM(total_vendas) OVER (PARTITION BY filtro_marca), 0), 4) AS participacao
FROM agrupado
ORDER BY filtro_marca, total_vendas DESC;
