from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
BANCO = RAIZ / "dados" / "seminovos.duckdb"
PASTA_SQL = RAIZ / "sql"

CAMADAS = {
    "bronze": ["vendas"],
    "silver": ["clientes", "modelos"],
}


def contar_linhas(conexao, tabela):
    return conexao.execute(f"SELECT COUNT(*) FROM {tabela}").fetchone()[0]


def rodar_tabela(conexao, camada, tabela):
    arquivo = PASTA_SQL / camada / f"{tabela}.sql"
    conexao.execute(arquivo.read_text(encoding="utf-8"))
    print(f"{camada}.{tabela}: {contar_linhas(conexao, f'{camada}.{tabela}')} linhas")


def main():
    conexao = duckdb.connect(str(BANCO))
    for camada, tabelas in CAMADAS.items():
        conexao.execute(f"CREATE SCHEMA IF NOT EXISTS {camada}")
        for tabela in tabelas:
            rodar_tabela(conexao, camada, tabela)
            if camada == "gold":
                print(conexao.execute(f"SELECT * FROM gold.{tabela}").df().to_string(index=False))
                print()
    conexao.close()


if __name__ == "__main__":
    main()