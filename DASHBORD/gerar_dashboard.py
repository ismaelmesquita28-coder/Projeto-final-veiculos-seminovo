import json
from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
BANCO = RAIZ / "dados" / "seminovos.duckdb"
SAIDA = Path(__file__).resolve().parent / "site" / "index.html"


def conferir(conexao, detalhe):
    # O dashboard recalcula os indicadores a partir de gold.vendas_detalhadas.
    # Sem filtro, eles precisam bater com as tabelas gold de cada indicador.
    for tabela, posicao in [("faturamento_por_marca", 0), ("vendas_por_estado", 1), ("vendas_por_ano", 2)]:
        esperado = {linha[0]: linha[1] for linha in conexao.execute(f"SELECT * FROM gold.{tabela}").fetchall()}
        calculado = {}
        for linha in detalhe:
            calculado[linha[posicao]] = calculado.get(linha[posicao], 0) + linha[4]
        if calculado != esperado:
            raise ValueError(f"gold.vendas_detalhadas nao bate com gold.{tabela}")


def main():
    if not BANCO.exists():
        raise FileNotFoundError("Rode antes: python src/pipeline.py")
    conexao = duckdb.connect(str(BANCO), read_only=True)
    detalhe = conexao.execute("SELECT * FROM gold.vendas_detalhadas").fetchall()
    conferir(conexao, detalhe)
    dados = {
        "colunas": ["marca", "estado", "ano", "forma_pagamento", "total_vendas", "faturamento"],
        "linhas": [[marca, estado, ano, forma, vendas, float(fat)] for marca, estado, ano, forma, vendas, fat in detalhe],
    }
    conexao.close()
    html = MODELO.replace("__DADOS__", json.dumps(dados, ensure_ascii=False, separators=(",", ":")))
    SAIDA.parent.mkdir(exist_ok=True)
    SAIDA.write_text(html, encoding="utf-8")
    print(f"Dashboard gerado em {SAIDA}")


MODELO = (Path(__file__).resolve().parent / "modelo.html").read_text(encoding="utf-8")


if __name__ == "__main__":
    main()
