-- Uma linha = uma combinacao de marca e modelo. Corrige Volskwagen.
CREATE OR REPLACE TABLE silver.modelos AS
SELECT
    ROW_NUMBER() OVER (ORDER BY marca, modelo) AS modelo_id,
    marca,
    modelo
FROM (
    SELECT DISTINCT
        CASE WHEN "Marca" = 'Volskwagen' THEN 'Volkswagen' ELSE "Marca" END AS marca,
        "Modelo" AS modelo
    FROM bronze.vendas
);