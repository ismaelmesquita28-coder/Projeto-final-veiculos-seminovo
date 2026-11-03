-- Pergunta: quais marcas vendem e faturam mais?

CREATE OR REPLACE TABLE gold.faturamento_por_marca AS
SELECT
    m.marca,
    COUNT(*) AS total_vendas,
    SUM(v.valor_venda) AS faturamento,
    ROUND(AVG(v.valor_venda), 2) AS ticket_medio
FROM silver.vendas AS v
JOIN silver.modelos AS m ON m.modelo_id = v.modelo_id
GROUP BY m.marca
ORDER BY faturamento DESC;