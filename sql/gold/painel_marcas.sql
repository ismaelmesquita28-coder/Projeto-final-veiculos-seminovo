-- Pergunta: quais marcas vendem e faturam mais em cada estado escolhido no filtro?
-- Uma linha = uma marca dentro de um filtro de estado. 'Todos' significa sem filtro.

CREATE OR REPLACE TABLE gold.painel_marcas AS
WITH base AS (
    SELECT m.marca, c.estado, YEAR(v.data_venda) AS ano, v.forma_pagamento, v.valor_venda
    FROM silver.vendas AS v
    JOIN silver.modelos AS m ON m.modelo_id = v.modelo_id
    JOIN silver.clientes AS c ON c.cliente_id = v.cliente_id
),
marcas AS (SELECT DISTINCT marca FROM base UNION ALL SELECT 'Todas'),
estados AS (SELECT DISTINCT estado FROM base UNION ALL SELECT 'Todos'),
agrupado AS (
    SELECT e.estado AS filtro_estado, m.marca,
           COUNT(b.valor_venda) AS total_vendas,
           COALESCE(SUM(b.valor_venda), 0) AS faturamento,
           ROUND(COALESCE(AVG(b.valor_venda), 0), 2) AS ticket_medio
    FROM estados AS e
    CROSS JOIN (SELECT marca FROM marcas WHERE marca <> 'Todas') AS m
    LEFT JOIN base AS b ON b.marca = m.marca AND (e.estado = 'Todos' OR b.estado = e.estado)
    GROUP BY e.estado, m.marca
)
SELECT *,
       ROUND(total_vendas / NULLIF(SUM(total_vendas) OVER (PARTITION BY filtro_estado), 0), 4) AS participacao
FROM agrupado
ORDER BY filtro_estado, faturamento DESC;
