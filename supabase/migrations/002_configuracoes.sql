-- ══════════════════════════════════════════════════════
--  OrangeNFe · Migration 002 — Tabela configuracoes
--  Tabela única (single-row) com todos os parâmetros
--  de emissão, certificado, e-mail e DANFe.
-- ══════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS configuracoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- ── Certificado Digital ──────────────────────────
  cert_tipo       text DEFAULT 'A1',      -- A1 | A3
  cert_nome       text,                   -- nome do arquivo .pfx
  cert_b64        text,                   -- conteúdo base64 do .pfx
  cert_senha      text,                   -- senha do .pfx
  cert_cn         text,                   -- Common Name extraído
  cert_issuer     text,                   -- Emissor extraído
  cert_validade   date,                   -- data de validade

  -- ── Parâmetros de Emissão ────────────────────────
  ambiente            text DEFAULT 'homologacao',
  tipo_emissao        text DEFAULT '1',
  uf                  text DEFAULT 'SP',
  versao_nfe          text DEFAULT '4.00',
  serie_nfe_prod      text DEFAULT '1',
  serie_nfe_homol     text DEFAULT '1',
  serie_nfce_prod     text DEFAULT '1',
  serie_nfce_homol    text DEFAULT '1',
  decimais_unit       integer DEFAULT 4,
  dest_tipo           text DEFAULT '1',
  cons_final          text DEFAULT '0',
  ind_pres            text DEFAULT '1',
  ind_intermed        text DEFAULT '',
  cfop_padrao         text DEFAULT '5102',
  sub_icms_piscofins  boolean DEFAULT false,
  sub_fcp_piscofins   boolean DEFAULT false,
  icms_desonerado     boolean DEFAULT false,
  difal_calc          text DEFAULT '1',

  -- ── Reforma Tributária (IBS/CBS — LC 214/2025) ───
  sit_ibs     text DEFAULT '',
  class_trib  text DEFAULT '',
  ibs_est     numeric(8,4) DEFAULT 0,
  ibs_mun     numeric(8,4) DEFAULT 0,
  cbs         numeric(8,4) DEFAULT 0,

  -- ── Impostos / Retenções ─────────────────────────
  inf_contribuinte  text,
  inf_fisco         text,
  lei_transp        boolean DEFAULT true,
  aliq_transp       numeric(8,4) DEFAULT 0,
  cfop_padroes      jsonb DEFAULT '[]',   -- array de padrões por CFOP
  retencoes         jsonb DEFAULT '[]',   -- array de padrões de retenção

  -- ── E-mail e DANFe ───────────────────────────────
  mde_ativo         boolean DEFAULT true,
  mde_auto          boolean DEFAULT false,
  nao_envia_copia   boolean DEFAULT false,
  desativ_email     boolean DEFAULT false,
  email_copia       text,
  msg_email         text,
  danfe_fantasia    boolean DEFAULT false,
  danfe_no_email    boolean DEFAULT false,
  danfe_logo_b64    text,                 -- data-URL da logomarca (base64 jpg)
  danfe_align       text DEFAULT 'centro',
  allow_xml_dl      boolean DEFAULT true,
  resumo_diario     boolean DEFAULT false,
  resumo_semanal    boolean DEFAULT false,
  resumo_mensal     boolean DEFAULT true,

  updated_at timestamptz DEFAULT now()
);

ALTER TABLE configuracoes DISABLE ROW LEVEL SECURITY;

-- Garante que sempre exista exatamente uma linha
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM configuracoes) THEN
    INSERT INTO configuracoes DEFAULT VALUES;
  END IF;
END $$;
