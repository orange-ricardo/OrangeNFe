-- ══════════════════════════════════════════════════════
--  OrangeNFe · Migration 006 — Adiciona campo ibge_municipio
--  em clientes, fornecedores e transportadoras
-- ══════════════════════════════════════════════════════

ALTER TABLE clientes       ADD COLUMN IF NOT EXISTS ibge text;
ALTER TABLE fornecedores   ADD COLUMN IF NOT EXISTS ibge text;
ALTER TABLE transportadoras ADD COLUMN IF NOT EXISTS ibge text;
