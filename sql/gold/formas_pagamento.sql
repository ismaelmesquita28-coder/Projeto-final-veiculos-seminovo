-- Pergunta: como os clientes pagam e qual e o valor medio em cada forma?

CREATE OR REPLACE TABLE gold.formas_pagamento AS
SELECT
    forma_pagamento,
    COUNT(*) AS total_vendas,
    ROUND(AVG(valor_venda), 2) AS ticket_medio
FROM silver.vendas
GROUP BY forma_pagamento
ORDER BY total_vendas DESC;