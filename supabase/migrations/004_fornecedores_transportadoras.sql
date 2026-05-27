-- ══════════════════════════════════════════════════════
--  OrangeNFe · Migration 004 — Fornecedores e Transportadoras
-- ══════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS fornecedores (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  razao       text NOT NULL,
  fantasia    text,
  cnpj        text,
  cpf         text,
  tipo        text DEFAULT 'PJ',       -- PJ | PF
  logradouro  text, numero text, complemento text,
  bairro      text, municipio text, uf text, cep text,
  ie          text, im text, suframa text,
  regime      text,
  email       text, tel text, site text, obs text,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS transportadoras (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  razao       text NOT NULL,
  cnpj        text,
  cpf         text,
  ie          text,
  logradouro  text, numero text, complemento text,
  bairro      text, municipio text, uf text DEFAULT 'SP', cep text,
  antt        text,                    -- RNTRC
  email       text, tel text, obs text,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

ALTER TABLE fornecedores    DISABLE ROW LEVEL SECURITY;
ALTER TABLE transportadoras DISABLE ROW LEVEL SECURITY;
