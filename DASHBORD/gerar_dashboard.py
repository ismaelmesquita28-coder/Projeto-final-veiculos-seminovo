import json
from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
BANCO = RAIZ / "dados" / "seminovos.duckdb"
SAIDA = Path(__file__).resolve().parent / "site" / "index.html"


def ler(conexao, tabela):
    resultado = conexao.execute(f"SELECT * FROM gold.{tabela}")
    colunas = [coluna[0] for coluna in resultado.description]
    return [dict(zip(colunas, (v if isinstance(v, str) else float(v) for v in linha)))
            for linha in resultado.fetchall()]


def main():
    if not BANCO.exists():
        raise FileNotFoundError("Rode antes: python src/pipeline.py")
    conexao = duckdb.connect(str(BANCO), read_only=True)
    dados = {
        "marcas": ler(conexao, "faturamento_por_marca"),
        "anos": ler(conexao, "vendas_por_ano"),
        "estados": ler(conexao, "vendas_por_estado"),
        "pagamentos": ler(conexao, "formas_pagamento"),
    }
    conexao.close()
    html = MODELO.replace("__DADOS__", json.dumps(dados, ensure_ascii=False, default=str))
    SAIDA.parent.mkdir(exist_ok=True)
    SAIDA.write_text(html, encoding="utf-8")
    print(f"Dashboard gerado em {SAIDA}")


MODELO = (Path(__file__).resolve().parent / "modelo.html").read_text(encoding="utf-8")


if __name__ == "__main__":
    main()
