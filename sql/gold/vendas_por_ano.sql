CREATE OR REPLACE TABLE gold.vendas_por_ano AS
SELECT
    YEAR(data_venda) AS ano,
    COUNT(*) AS total_vendas,
    SUM(valor_venda) AS faturamento
FROM silver.vendas
GROUP BY ano
ORDER BY ano;