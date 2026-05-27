-- ══════════════════════════════════════════════════════
--  OrangeNFe · Migration 005 — Estados e Municípios (IBGE)
-- ══════════════════════════════════════════════════════

-- ── ESTADOS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS estados (
  sigla text PRIMARY KEY,
  nome  text NOT NULL,
  ibge  text NOT NULL   -- código IBGE de 2 dígitos
);

ALTER TABLE estados DISABLE ROW LEVEL SECURITY;

INSERT INTO estados (sigla, nome, ibge) VALUES
  ('AC','Acre','12'),
  ('AL','Alagoas','27'),
  ('AP','Amapá','16'),
  ('AM','Amazonas','13'),
  ('BA','Bahia','29'),
  ('CE','Ceará','23'),
  ('DF','Distrito Federal','53'),
  ('ES','Espírito Santo','32'),
  ('GO','Goiás','52'),
  ('MA','Maranhão','21'),
  ('MT','Mato Grosso','51'),
  ('MS','Mato Grosso do Sul','50'),
  ('MG','Minas Gerais','31'),
  ('PA','Pará','15'),
  ('PB','Paraíba','25'),
  ('PR','Paraná','41'),
  ('PE','Pernambuco','26'),
  ('PI','Piauí','22'),
  ('RJ','Rio de Janeiro','33'),
  ('RN','Rio Grande do Norte','24'),
  ('RS','Rio Grande do Sul','43'),
  ('RO','Rondônia','11'),
  ('RR','Roraima','14'),
  ('SC','Santa Catarina','42'),
  ('SP','São Paulo','35'),
  ('SE','Sergipe','28'),
  ('TO','Tocantins','17')
ON CONFLICT (sigla) DO NOTHING;

-- ── MUNICÍPIOS ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS municipios (
  ibge   text PRIMARY KEY,   -- código de 7 dígitos, ex: 3550308
  nome   text NOT NULL,
  uf     text NOT NULL,      -- sigla do estado, ex: SP
  nome_uf text NOT NULL      -- nome do estado, ex: São Paulo
);

ALTER TABLE municipios DISABLE ROW LEVEL SECURITY;

-- índice para buscas rápidas por nome + UF
CREATE INDEX IF NOT EXISTS idx_municipios_nome ON municipios (nome);
CREATE INDEX IF NOT EXISTS idx_municipios_uf   ON municipios (uf);
