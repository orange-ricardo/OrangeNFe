-- ══════════════════════════════════════════════════════
--  OrangeNFe · Migration 003 — Tabela empresa
--  Tabela única (single-row) com dados cadastrais,
--  endereço e logo da empresa emitente.
-- ══════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS empresa (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Identificação
  cnpj        text,
  ie          text,
  im          text,
  razao       text,
  fantasia    text,
  cnae        text,
  regime      text DEFAULT '1',   -- 1=Simples | 2=SimplesExcesso | 3=Normal
  -- Endereço
  cep         text,
  logradouro  text,
  numero      text,
  complemento text,
  bairro      text,
  municipio   text,
  uf          text DEFAULT 'SP',
  ibge        text,
  -- Contato
  tel         text,
  email       text,
  email_nfe   text,
  resp_fiscal text,
  -- Logo (base64 data-URL)
  logo_b64    text,
  updated_at  timestamptz DEFAULT now()
);

ALTER TABLE empresa DISABLE ROW LEVEL SECURITY;

-- Garante ao menos uma linha
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM empresa) THEN
    INSERT INTO empresa DEFAULT VALUES;
  END IF;
END $$;
