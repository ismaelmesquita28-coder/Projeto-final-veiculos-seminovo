import json
from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
BANCO = RAIZ / "dados" / "seminovos.duckdb"
SAIDA = Path(__file__).resolve().parent / "site" / "index.html"
TABELAS = ["painel_totais", "painel_marcas", "painel_estados", "painel_anos", "painel_pagamentos"]


def ler(conexao, tabela):
    resultado = conexao.execute(f"SELECT * FROM gold.{tabela}")
    colunas = [coluna[0] for coluna in resultado.description]
    return [dict(zip(colunas, (v if v is None or isinstance(v, str) else float(v) for v in linha)))
            for linha in resultado.fetchall()]


def conferir(conexao):
    # Sem filtro, as tabelas do painel precisam bater com as tabelas gold de cada indicador.
    comparacoes = {
        "painel_marcas": ("faturamento_por_marca", "marca", "filtro_estado = 'Todos'"),
        "painel_estados": ("vendas_por_estado", "estado", "filtro_marca = 'Todas'"),
        "painel_anos": ("vendas_por_ano", "ano", "filtro_marca = 'Todas' AND filtro_estado = 'Todos'"),
        "painel_pagamentos": ("formas_pagamento", "forma_pagamento", "filtro_marca = 'Todas' AND filtro_estado = 'Todos'"),
    }
    for painel, (indicador, chave, sem_filtro) in comparacoes.items():
        diferentes = conexao.execute(f"""
            SELECT COUNT(*) FROM gold.{indicador} AS i
            FULL JOIN (SELECT * FROM gold.{painel} WHERE {sem_filtro}) AS p USING ({chave})
            WHERE p.total_vendas IS DISTINCT FROM i.total_vendas
        """).fetchone()[0]
        if diferentes:
            raise ValueError(f"gold.{painel} nao bate com gold.{indicador}")


def main():
    if not BANCO.exists():
        raise FileNotFoundError("Rode antes: python src/pipeline.py")
    conexao = duckdb.connect(str(BANCO), read_only=True)
    conferir(conexao)
    dados = {tabela.removeprefix("painel_"): ler(conexao, tabela) for tabela in TABELAS}
    conexao.close()
    html = MODELO.replace("__DADOS__", json.dumps(dados, ensure_ascii=False, separators=(",", ":")))
    SAIDA.parent.mkdir(exist_ok=True)
    SAIDA.write_text(html, encoding="utf-8")
    print(f"Dashboard gerado em {SAIDA}")


MODELO = (Path(__file__).resolve().parent / "modelo.html").read_text(encoding="utf-8")


if __name__ == "__main__":
    main()
