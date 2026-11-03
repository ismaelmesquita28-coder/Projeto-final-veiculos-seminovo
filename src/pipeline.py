from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
BANCO = RAIZ / "dados" / "seminovos.duckdb"
PASTA_SQL = RAIZ / "sql"

CAMADAS = {
    "bronze": ["vendas"],
    "silver": ["clientes", "modelos", "vendas"],
    "gold": ["faturamento_por_marca", "vendas_por_ano", "vendas_por_estado", "formas_pagamento", "painel_totais", "painel_marcas", "painel_estados", "painel_anos", "painel_pagamentos"],
}


def contar_linhas(conexao, tabela):
    return conexao.execute(f"SELECT COUNT(*) FROM {tabela}").fetchone()[0]


def rodar_tabela(conexao, camada, tabela):
    arquivo = PASTA_SQL / camada / f"{tabela}.sql"
    conexao.execute(arquivo.read_text(encoding="utf-8"))
    print(f"{camada}.{tabela}: {contar_linhas(conexao, f'{camada}.{tabela}')} linhas")

def conferir_vendas(conexao):
    bronze = contar_linhas(conexao, "bronze.vendas")
    silver = contar_linhas(conexao, "silver.vendas")
    if bronze != silver:
        raise ValueError(f"Bronze tem {bronze} vendas, mas a silver tem {silver}.")

def main():
    conexao = duckdb.connect(str(BANCO))
    for camada, tabelas in CAMADAS.items():
        conexao.execute(f"CREATE SCHEMA IF NOT EXISTS {camada}")
        for tabela in tabelas:
            rodar_tabela(conexao, camada, tabela)
            if camada == "gold":
                print(conexao.execute(f"SELECT * FROM gold.{tabela} LIMIT 30").df().to_string(index=False))
                print()
        if camada == "silver":
            conferir_vendas(conexao)
    conexao.close()

if __name__ == "__main__":
    main()