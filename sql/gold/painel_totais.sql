-- Pergunta: quais sao os totais do painel para cada filtro de marca e de estado?
-- Uma linha = uma combinacao de filtro. 'Todas' e 'Todos' significam sem filtro.
-- O dashboard so le esta tabela: nenhum total e calculado na tela.

CREATE OR REPLACE TABLE gold.painel_totais AS
WITH base AS (
    SELECT m.marca, c.estado, YEAR(v.data_venda) AS ano, v.forma_pagamento, v.valor_venda
    FROM silver.vendas AS v
    JOIN silver.modelos AS m ON m.modelo_id = v.modelo_id
    JOIN silver.clientes AS c ON c.cliente_id = v.cliente_id
),
marcas AS (SELECT DISTINCT marca FROM base UNION ALL SELECT 'Todas'),
estados AS (SELECT DISTINCT estado FROM base UNION ALL SELECT 'Todos'),
filtros AS (SELECT m.marca, e.estado FROM marcas AS m CROSS JOIN estados AS e),
totais AS (
    SELECT f.marca AS filtro_marca, f.estado AS filtro_estado,
           COUNT(b.valor_venda) AS total_vendas,
           COALESCE(SUM(b.valor_venda), 0) AS faturamento,
           ROUND(COALESCE(AVG(b.valor_venda), 0), 2) AS ticket_medio
    FROM filtros AS f
    LEFT JOIN base AS b ON (f.marca = 'Todas' OR b.marca = f.marca) AND (f.estado = 'Todos' OR b.estado = f.estado)
    GROUP BY f.marca, f.estado
),
por_marca AS (
    SELECT f.marca AS filtro_marca, f.estado AS filtro_estado, b.marca, SUM(b.valor_venda) AS faturamento
    FROM filtros AS f JOIN base AS b ON (f.marca = 'Todas' OR b.marca = f.marca) AND (f.estado = 'Todos' OR b.estado = f.estado)
    GROUP BY f.marca, f.estado, b.marca
),
por_estado AS (
    SELECT f.marca AS filtro_marca, f.estado AS filtro_estado, b.estado, COUNT(*) AS total_vendas
    FROM filtros AS f JOIN base AS b ON (f.marca = 'Todas' OR b.marca = f.marca) AND (f.estado = 'Todos' OR b.estado = f.estado)
    GROUP BY f.marca, f.estado, b.estado
)
SELECT t.*,
       (SELECT ARG_MAX(p.marca, p.faturamento) FROM por_marca AS p
        WHERE p.filtro_marca = t.filtro_marca AND p.filtro_estado = t.filtro_estado) AS marca_lider,
       (SELECT ARG_MAX(p.estado, p.total_vendas) FROM por_estado AS p
        WHERE p.filtro_marca = t.filtro_marca AND p.filtro_estado = t.filtro_estado) AS estado_lider
FROM totais AS t
ORDER BY t.filtro_marca, t.filtro_estado;
