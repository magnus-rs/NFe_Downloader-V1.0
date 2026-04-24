CREATE TABLE empresa (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cnpj TEXT NOT NULL UNIQUE,
  razao_social TEXT NOT NULL,
  uf_cod TEXT NOT NULL,
  ativo INTEGER DEFAULT 1
);

CREATE TABLE certificado (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  empresa_id INTEGER NOT NULL,
  caminho_pfx TEXT NOT NULL,
  senha TEXT NOT NULL,
  data_validade DATE,
  ativo INTEGER DEFAULT 1,
  FOREIGN KEY (empresa_id) REFERENCES empresa(id)
);

CREATE TABLE nsu (
  empresa_id INTEGER PRIMARY KEY,
  ultimo_nsu TEXT,
  ultima_consulta DATETIME,
  FOREIGN KEY (empresa_id) REFERENCES empresa(id)
);

CREATE TABLE configuracao (
  chave TEXT PRIMARY KEY,
  valor TEXT
);