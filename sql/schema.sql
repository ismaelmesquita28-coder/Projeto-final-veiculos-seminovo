DROP TABLE IF EXISTS vendas;
DROP TABLE IF EXISTS veiculos;
DROP TABLE IF EXISTS modelos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    nome         TEXT NOT NULL,
    idade        INTEGER,
    cpf          TEXT NOT NULL,
    sexo         TEXT,
    estado_civil TEXT,
    email        TEXT,
    telefone     TEXT,
    cidade       TEXT,
    estado       TEXT
);

CREATE TABLE modelos (
    id     INTEGER PRIMARY KEY AUTOINCREMENT,
    marca  TEXT NOT NULL,
    modelo TEXT NOT NULL,
    UNIQUE (marca, modelo)
);

CREATE TABLE veiculos (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    modelo_id      INTEGER NOT NULL,
    ano_fabricacao INTEGER NOT NULL,
    cor            TEXT,
    FOREIGN KEY (modelo_id) REFERENCES modelos (id)
);

CREATE TABLE vendas (
    id              INTEGER PRIMARY KEY,
    cliente_id      INTEGER NOT NULL,
    veiculo_id      INTEGER NOT NULL,
    valor_venda     REAL NOT NULL CHECK (valor_venda >= 0),
    data_venda      TEXT NOT NULL,
    forma_pagamento TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes (id),
    FOREIGN KEY (veiculo_id) REFERENCES veiculos (id)
);