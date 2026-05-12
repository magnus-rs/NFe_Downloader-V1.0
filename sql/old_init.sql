-- =========================================
-- CONFIGURAÇÕES INICIAIS
-- =========================================

PRAGMA foreign_keys = ON;

-- =========================================
-- CRIAÇÃO DAS TABELAS
-- =========================================

CREATE TABLE IF NOT EXISTS distribuicao_dfe (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entidade_id INTEGER NOT NULL,
  ultima_busca DATETIME,
  ultimo_nsu TEXT,
  FOREIGN KEY (entidade_id) REFERENCES entidade(id)
);

CREATE TABLE IF NOT EXISTS uf (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo_ibge INTEGER NOT NULL,
    sigla TEXT NOT NULL UNIQUE,
    nome TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS entidade (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo INTEGER NOT NULL, -- 1 = CNPJ | 2 = CPF
    documento TEXT NOT NULL UNIQUE,
    razao_social TEXT NOT NULL,
    email TEXT,
    uf_id INTEGER,
	ambiente INTEGER,  -- 1=produção, 2=homologação
    ativo INTEGER DEFAULT 1,
    FOREIGN KEY (uf_id) REFERENCES uf(id)
);

CREATE TABLE IF NOT EXISTS certificado (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entidade_id INTEGER NULL,
    caminho_pfx TEXT NOT NULL,
    senha TEXT,
    data_ativacao DATE,
    data_validade DATE,
    numero_serie TEXT NOT NULL,
    ativo INTEGER DEFAULT 1,
    FOREIGN KEY (entidade_id) REFERENCES entidade(id)
);

CREATE TABLE IF NOT EXISTS configuracao (
    chave TEXT PRIMARY KEY,
    valor TEXT
);

-- =========================================
-- NOVAS TABELAS - NFE (CORE)
-- =========================================

CREATE TABLE IF NOT EXISTS nfe (
    ID                INTEGER PRIMARY KEY AUTOINCREMENT,

    CNPJ              TEXT NOT NULL,
    CHAVE             TEXT NOT NULL,
    NSU               TEXT UNIQUE,

    NUMERO            TEXT,
    SERIE             TEXT,
    MODELO            TEXT,

    TIPO_XML          TEXT NOT NULL,

    DATA_EMISSAO      DATETIME,
    DATA_AUTORIZACAO  DATETIME,
    DATA_ENTRADA      DATETIME,

    VALOR_TOTAL       REAL,

    EMITENTE_CNPJ     TEXT,
    EMITENTE_NOME     TEXT,

    DEST_CNPJ         TEXT,
    DEST_NOME         TEXT,

    UF                TEXT,
    CFOP              TEXT,
    NATUREZA          TEXT,

    STATUS            TEXT,

    XML_REL_PATH      TEXT NOT NULL,

    DATA_DOWNLOAD     DATETIME DEFAULT CURRENT_TIMESTAMP,
	
	MANIFESTACAO	  TEXT
);

-- =========================================
-- NFE_TOTAIS
-- =========================================

CREATE TABLE IF NOT EXISTS nfe_totais (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    nfe_id          INTEGER NOT NULL,

    base_icms       REAL,
    valor_icms      REAL,
    valor_icms_st   REAL,

    valor_pis       REAL,
    valor_cofins    REAL,

    valor_ipi       REAL,
    valor_frete     REAL,
    valor_seguro    REAL,
    valor_desconto  REAL,
    valor_outros    REAL,

    FOREIGN KEY (nfe_id) REFERENCES nfe(id) ON DELETE CASCADE
);

-- =========================================
-- NFE_EVENTOS
-- =========================================

CREATE TABLE IF NOT EXISTS nfe_eventos (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    nfe_id        INTEGER NOT NULL,

    tipo_evento   TEXT,
    descricao     TEXT,

    data_evento   DATETIME,

    xml_rel_path  TEXT,

    FOREIGN KEY (nfe_id) REFERENCES nfe(id) ON DELETE CASCADE
);

-- =========================================
-- CONTROLE DE VERSÃO DO BANCO
-- =========================================

CREATE TABLE IF NOT EXISTS deb_version (
    versao INTEGER
);

INSERT OR IGNORE INTO db_version (versao) VALUES (1);

-- =========================================
-- ÍNDICES (performance futura)
-- =========================================

CREATE INDEX IF NOT EXISTS idx_entidade_documento ON entidade(documento);
CREATE INDEX IF NOT EXISTS idx_certificado_entidade ON certificado(entidade_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_dist_entidade ON distribuicao_dfe(entidade_id);

-- NFE
CREATE INDEX IF NOT EXISTS idx_nfe_chave ON nfe (chave);
CREATE INDEX IF NOT EXISTS idx_nfe_cnpj  ON nfe (cnpj);
CREATE INDEX IF NOT EXISTS idx_nfe_data  ON nfe (data_emissao);
CREATE INDEX IF NOT EXISTS idx_nfe_numero_serie ON nfe (numero, serie);

-- =========================================
-- CARGA INICIAL - UFs
-- =========================================

INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (12, 'AC', 'Acre');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (27, 'AL', 'Alagoas');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (16, 'AP', 'Amapá');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (13, 'AM', 'Amazonas');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (29, 'BA', 'Bahia');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (23, 'CE', 'Ceará');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (53, 'DF', 'Distrito Federal');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (32, 'ES', 'Espírito Santo');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (52, 'GO', 'Goiás');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (21, 'MA', 'Maranhão');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (51, 'MT', 'Mato Grosso');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (50, 'MS', 'Mato Grosso do Sul');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (31, 'MG', 'Minas Gerais');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (15, 'PA', 'Pará');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (25, 'PB', 'Paraíba');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (41, 'PR', 'Paraná');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (26, 'PE', 'Pernambuco');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (22, 'PI', 'Piauí');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (33, 'RJ', 'Rio de Janeiro');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (24, 'RN', 'Rio Grande do Norte');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (43, 'RS', 'Rio Grande do Sul');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (11, 'RO', 'Rondônia');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (14, 'RR', 'Roraima');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (42, 'SC', 'Santa Catarina');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (35, 'SP', 'São Paulo');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (28, 'SE', 'Sergipe');
INSERT INTO uf (codigo_ibge, sigla, nome) VALUES (17, 'TO', 'Tocantins');

-- =========================================
-- CONFIGURAÇÕES PADRÃO
-- =========================================

INSERT OR IGNORE INTO configuracao (chave, valor) VALUES ('path_xml', 'dados/xml/');
INSERT OR IGNORE INTO configuracao (chave, valor) VALUES ('path_eventos', 'dados/eventos/');
INSERT OR IGNORE INTO configuracao (chave, valor) VALUES ('path_resumos', 'dados/resumos/');