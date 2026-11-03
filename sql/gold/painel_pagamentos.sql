-- Pergunta: Como os clientes pagam, para cada filtro de marca e de estado?
-- Uma linha = uma forma de pagamento dentro de uma combinacao de filtro. 'Todas' e 'Todos' significam sem filtro.

CREATE OR REPLACE TABLE gold.painel_pagamentos AS
WITH base AS (
    SELECT m.marca, c.estado, YEAR(v.data_venda) AS ano, v.forma_pagamento, v.valor_venda
    FROM silver.vendas AS v
    JOIN silver.modelos AS m ON m.modelo_id = v.modelo_id
    JOIN silver.clientes AS c ON c.cliente_id = v.cliente_id
),
marcas AS (SELECT DISTINCT marca FROM base UNION ALL SELECT 'Todas'),
estados AS (SELECT DISTINCT estado FROM base UNION ALL SELECT 'Todos'),
filtros AS (SELECT m.marca, e.estado FROM marcas AS m CROSS JOIN estados AS e),
agrupado AS (
    SELECT f.marca AS filtro_marca, f.estado AS filtro_estado, d.forma_pagamento,
           COUNT(b.valor_venda) AS total_vendas,
           COALESCE(SUM(b.valor_venda), 0) AS faturamento,
           ROUND(COALESCE(AVG(b.valor_venda), 0), 2) AS ticket_medio
    FROM filtros AS f
    CROSS JOIN (SELECT DISTINCT forma_pagamento FROM base) AS d
    LEFT JOIN base AS b ON b.forma_pagamento = d.forma_pagamento AND (f.marca = 'Todas' OR b.marca = f.marca) AND (f.estado = 'Todos' OR b.estado = f.estado)
    GROUP BY f.marca, f.estado, d.forma_pagamento
)
SELECT *,
       ROUND(total_vendas / NULLIF(SUM(total_vendas) OVER (PARTITION BY filtro_marca, filtro_estado), 0), 4) AS participacao
FROM agrupado
ORDER BY filtro_marca, filtro_estado, total_vendas DESC;
