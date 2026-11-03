-- Pergunta: como as vendas e o faturamento mudam a cada ano?
-- Atencao: 2017 e 2025 estao incompletos, as datas vao de 16/04/2017 a 15/04/2025.

CREATE OR REPLACE TABLE gold.vendas_por_ano AS
SELECT
    YEAR(data_venda) AS ano,
    COUNT(*) AS total_vendas,
    SUM(valor_venda) AS faturamento
FROM silver.vendas
GROUP BY ano
ORDER BY ano;