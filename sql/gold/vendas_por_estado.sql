-- Pergunta: em quais estados estao os clientes que mais compram?

CREATE OR REPLACE TABLE gold.vendas_por_estado AS
SELECT
    c.estado,
    COUNT(*) AS total_vendas,
    SUM(v.valor_venda) AS faturamento
FROM silver.vendas AS v
JOIN silver.clientes AS c ON c.cliente_id = v.cliente_id
GROUP BY c.estado
ORDER BY total_vendas DESC;