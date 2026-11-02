# src/database.py
import sqlite3
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CAMINHO_BANCO = RAIZ / "dados" / "seminovos.db"
CAMINHO_SCHEMA = RAIZ / "sql" / "schema.sql"
CAMINHO_CSV = RAIZ / "dados" / "vendas_loja_seminovos.csv"


def conectar():
    conexao = sqlite3.connect(CAMINHO_BANCO)
    conexao.execute("PRAGMA foreign_keys = ON")
    return conexao


def criar_tabelas(conexao):
    script = CAMINHO_SCHEMA.read_text(encoding="utf-8")
    conexao.executescript(script)
    