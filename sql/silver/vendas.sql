-- Uma linha = uma venda. Mantem as vendas com data anterior a fabricacao e marca com uma coluna.
CREATE OR REPLACE TABLE silver.vendas AS
SELECT
    CAST(r."ID" AS INTEGER)            AS venda_id,
    CAST(r."ID" AS INTEGER)            AS cliente_id,
    m.modelo_id,
    CAST(r."Ano_fabricacao" AS INTEGER) AS ano_fabricacao,
    r."Cor"                            AS cor,
    CAST(r."Valor_venda" AS DECIMAL(12, 2)) AS valor_venda,
    CAST(r."Data_venda" AS DATE)       AS data_venda,
    r."Forma_pagamento"                AS forma_pagamento,
    YEAR(CAST(r."Data_venda" AS DATE)) < CAST(r."Ano_fabricacao" AS INTEGER) AS venda_antes_fabricacao
FROM bronze.vendas AS r
JOIN silver.modelos AS m
  ON m.modelo = r."Modelo"
 AND m.marca = CASE WHEN r."Marca" = 'Volskwagen' THEN 'Volkswagen' ELSE r."Marca" END;