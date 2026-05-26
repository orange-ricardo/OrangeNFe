-- CLIENTES
CREATE TABLE IF NOT EXISTS clientes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  razao text NOT NULL,
  fantasia text,
  cnpj text,
  tipo text DEFAULT 'PJ', -- PJ | PF
  logradouro text, numero text, complemento text, bairro text,
  municipio text, uf text, cep text, pais text DEFAULT 'Brasil',
  ie text, im text, suframa text,
  regime text, -- 1=Simples, 2=SimplesExcesso, 3=Normal
  email text, tel text, site text, obs text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS clientes_contatos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id uuid REFERENCES clientes(id) ON DELETE CASCADE,
  nome text, cargo text, telefone_email text
);

-- PRODUTOS
CREATE TABLE IF NOT EXISTS produtos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo text,
  descricao text NOT NULL,
  tipo text DEFAULT 'produto', -- produto | servico
  categ text,
  ncm text, cest text, ean text, cfop text, unid text,
  origem text DEFAULT '0',
  preco numeric(15,2) DEFAULT 0,
  custo numeric(15,2),
  margem numeric(8,2),
  desc_max numeric(8,2),
  preco_atacado numeric(15,2),
  estoque integer,
  estoque_min integer,
  estoque_max integer,
  localizacao text,
  fornecedor text,
  cst_icms text, cst_pis text, cst_cofins text,
  aliq_icms numeric(8,4), aliq_pis numeric(8,4), aliq_cofins numeric(8,4),
  info text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- NOTAS EMITIDAS
CREATE TABLE IF NOT EXISTS notas_emitidas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  numero text,
  serie text DEFAULT '1',
  chave_acesso text,
  tipo_nota text DEFAULT 'NF-e', -- NF-e | NFC-e | NFS-e
  tipo_operacao text DEFAULT 'saida', -- saida | entrada
  natureza text,
  destinatario_nome text,
  destinatario_doc text,
  valor_total numeric(15,2) DEFAULT 0,
  status text DEFAULT 'em_digitacao',
  -- autorizada | cancelada | em_digitacao | validada | rejeitada | denegada
  ambiente text DEFAULT 'homologacao', -- homologacao | producao
  data_emissao timestamptz DEFAULT now(),
  xml text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- NOTAS RECEBIDAS (também usada pela manifestação)
CREATE TABLE IF NOT EXISTS notas_recebidas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chave text,
  emitente text,
  emitente_cnpj text,
  uf text,
  num text,
  serie text,
  data_emissao date,
  valor numeric(15,2),
  prazo_manifest integer DEFAULT 30,
  sit text DEFAULT 'autorizada',
  manifest text DEFAULT 'pendente',
  -- pendente | confirmada | negada | desconhecida
  xml text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ARQUIVOS RECEBIDOS
CREATE TABLE IF NOT EXISTS arquivos_recebidos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  tipo text, -- xml | pdf | zip | xls
  tamanho_bytes integer,
  origem text,
  nota_id uuid REFERENCES notas_recebidas(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- NF-e RASCUNHOS (already exists, keep as-is)
CREATE TABLE IF NOT EXISTS nfe_rascunhos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text,
  snapshot jsonb,
  updated_at timestamptz DEFAULT now()
);

-- disable RLS for personal use
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes_contatos DISABLE ROW LEVEL SECURITY;
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE notas_emitidas DISABLE ROW LEVEL SECURITY;
ALTER TABLE notas_recebidas DISABLE ROW LEVEL SECURITY;
ALTER TABLE arquivos_recebidos DISABLE ROW LEVEL SECURITY;
ALTER TABLE nfe_rascunhos DISABLE ROW LEVEL SECURITY;
