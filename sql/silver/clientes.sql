-- Uma linha = o cliente de uma venda. O CSV nao tem id de cliente e o CPF se repete com nomes diferentes.
CREATE OR REPLACE TABLE silver.clientes AS
SELECT
    CAST("ID" AS INTEGER) AS cliente_id,
    "Nome Completo"       AS nome,
    CAST("Idade" AS INTEGER) AS idade,
    "Sexo"                AS sexo,
    "Estado Civil"        AS estado_civil,
    "Cidade"              AS cidade,
    "Estado"              AS estado
FROM bronze.vendas;