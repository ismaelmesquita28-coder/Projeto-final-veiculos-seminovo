-- Pergunta: como as vendas se distribuem quando se filtra por marca e por estado?
-- Uma linha = uma combinacao de marca, estado, ano e forma de pagamento. Alimenta os filtros do dashboard.

CREATE OR REPLACE TABLE gold.vendas_detalhadas AS
SELECT
    m.marca,
    c.estado,
    YEAR(v.data_venda) AS ano,
    v.forma_pagamento,
    COUNT(*) AS total_vendas,
    SUM(v.valor_venda) AS faturamento
FROM silver.vendas AS v
JOIN silver.modelos AS m ON m.modelo_id = v.modelo_id
JOIN silver.clientes AS c ON c.cliente_id = v.cliente_id
GROUP BY m.marca, c.estado, ano, v.forma_pagamento
ORDER BY m.marca, c.estado, ano, v.forma_pagamento;
