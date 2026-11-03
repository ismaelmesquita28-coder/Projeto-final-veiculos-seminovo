from pathlib import Path

import duckdb
import pytest

PASTA_SQL = Path(__file__).resolve().parent.parent / "sql"

COLUNAS = (
    '"ID", "Nome Completo", "Idade", "Sexo", "Estado Civil", "Cidade", "Estado", '
    '"Marca", "Modelo", "Ano_fabricacao", "Cor", "Valor_venda", "Data_venda", "Forma_pagamento"'
)


@pytest.fixture
def conexao():
    con = duckdb.connect(":memory:")
    con.execute("CREATE SCHEMA bronze; CREATE SCHEMA silver; CREATE SCHEMA gold")
    con.execute(f"""
        CREATE TABLE bronze.vendas AS
        SELECT * FROM (VALUES
            ('1', 'Ana', '30', 'Feminino', 'Casado', 'Campinas', 'SP', 'Volskwagen', 'Gol', '2020', 'Preto', '50000.00', '2021-05-10', 'À vista'),
            ('2', 'Bia', '40', 'Feminino', 'Solteiro', 'Recife', 'PE', 'Volkswagen', 'Gol', '2022', 'Azul', '70000.00', '2021-06-01', 'Leasing')
        ) AS t({COLUNAS})
    """)
    for arquivo in ["clientes.sql", "modelos.sql", "vendas.sql"]:
        con.execute((PASTA_SQL / "silver" / arquivo).read_text(encoding="utf-8"))
    yield con
    con.close()


def test_corrige_volskwagen_e_nao_duplica_modelo(conexao):
    assert conexao.execute("SELECT marca, modelo FROM silver.modelos").fetchall() == [("Volkswagen", "Gol")]


def test_nao_perde_venda_na_transformacao(conexao):
    assert conexao.execute("SELECT COUNT(*) FROM silver.vendas").fetchone()[0] == 2


def test_marca_venda_antes_da_fabricacao(conexao):
    resultado = conexao.execute("SELECT venda_id, venda_antes_fabricacao FROM silver.vendas ORDER BY venda_id").fetchall()
    assert resultado == [(1, False), (2, True)]


def test_faturamento_por_marca_soma_as_vendas(conexao):
    conexao.execute((PASTA_SQL / "gold" / "faturamento_por_marca.sql").read_text(encoding="utf-8"))
    linha = conexao.execute("SELECT marca, total_vendas, faturamento FROM gold.faturamento_por_marca").fetchone()
    assert linha[0] == "Volkswagen" and linha[1] == 2 and float(linha[2]) == 120000.0