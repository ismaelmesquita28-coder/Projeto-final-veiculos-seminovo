CREATE OR REPLACE TABLE bronze.vendas AS
SELECT *
FROM read_csv('dados/bronze/vendas_loja_seminovos.csv', delim = ';', header = true, all_varchar = true);