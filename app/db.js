/* ══ OrangeNFe · Supabase shared client ══ */
const SUPA_URL = 'https://erueerxquddtuucrllim.supabase.co';
const SUPA_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVydWVlcnhxdWRkdHV1Y3JsbGltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3MTgxOTAsImV4cCI6MjA5NTI5NDE5MH0.Mf1lN4V9AT81yMKbOIXA9ihX9pGc1NF6mkPbnq5yyWA';

let _db = null;
function getDB() {
  if (!_db) _db = supabase.createClient(SUPA_URL, SUPA_KEY);
  return _db;
}

/* ── helpers ── */
function fmtDate(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return d.toLocaleDateString('pt-BR');
}
function fmtMoney(v) {
  return Number(v||0).toLocaleString('pt-BR',{minimumFractionDigits:2,maximumFractionDigits:2});
}
function showToast(msg, type='ok') {
  const t = document.createElement('div');
  t.className = 'db-toast ' + type;
  t.textContent = msg;
  document.body.appendChild(t);
  setTimeout(()=>t.remove(), 3200);
}

/* ── CLIENTES ── */
async function dbGetClientes() {
  const {data,error} = await getDB().from('clientes').select('*, clientes_contatos(*)').order('razao');
  if(error) throw error; return data||[];
}
async function dbSaveCliente(c) {
  const {id, clientes_contatos:contatos, ...fields} = c;
  fields.updated_at = new Date().toISOString();
  let clienteId = id;
  if(id) {
    const {error} = await getDB().from('clientes').update(fields).eq('id',id);
    if(error) throw error;
  } else {
    const {data,error} = await getDB().from('clientes').insert(fields).select().single();
    if(error) throw error; clienteId = data.id;
  }
  if(contatos) {
    await getDB().from('clientes_contatos').delete().eq('cliente_id',clienteId);
    if(contatos.length) await getDB().from('clientes_contatos').insert(contatos.map(c=>({...c,cliente_id:clienteId,id:undefined})));
  }
  return clienteId;
}
async function dbDeleteCliente(id) {
  const {error} = await getDB().from('clientes').delete().eq('id',id);
  if(error) throw error;
}

/* ── PRODUTOS ── */
async function dbGetProdutos() {
  const {data,error} = await getDB().from('produtos').select('*').order('descricao');
  if(error) throw error; return data||[];
}
async function dbSaveProduto(p) {
  const {id, ...fields} = p;
  fields.updated_at = new Date().toISOString();
  if(id) {
    const {error} = await getDB().from('produtos').update(fields).eq('id',id);
    if(error) throw error; return id;
  } else {
    const {data,error} = await getDB().from('produtos').insert(fields).select().single();
    if(error) throw error; return data.id;
  }
}
async function dbDeleteProduto(id) {
  const {error} = await getDB().from('produtos').delete().eq('id',id);
  if(error) throw error;
}

/* ── NOTAS EMITIDAS ── */
async function dbGetNotasEmitidas(filters={}) {
  let q = getDB().from('notas_emitidas').select('*').order('data_emissao',{ascending:false});
  if(filters.status) q = q.eq('status',filters.status);
  if(filters.tipo) q = q.eq('tipo_nota',filters.tipo);
  if(filters.search) q = q.or(`destinatario_nome.ilike.%${filters.search}%,numero.ilike.%${filters.search}%,chave_acesso.ilike.%${filters.search}%`);
  const {data,error} = await q;
  if(error) throw error; return data||[];
}
async function dbSaveNotaEmitida(n) {
  const {id,...fields} = n;
  fields.updated_at = new Date().toISOString();
  if(id) { await getDB().from('notas_emitidas').update(fields).eq('id',id); return id; }
  const {data,error} = await getDB().from('notas_emitidas').insert(fields).select().single();
  if(error) throw error; return data.id;
}

/* ── NOTAS RECEBIDAS ── */
async function dbGetNotasRecebidas(filters={}) {
  let q = getDB().from('notas_recebidas').select('*').order('data_emissao',{ascending:false});
  if(filters.manifest) q = q.eq('manifest',filters.manifest);
  if(filters.search) q = q.or(`emitente.ilike.%${filters.search}%,num.ilike.%${filters.search}%,chave.ilike.%${filters.search}%`);
  const {data,error} = await q;
  if(error) throw error; return data||[];
}
async function dbUpdateManifest(id, manifest) {
  const {error} = await getDB().from('notas_recebidas').update({manifest, updated_at: new Date().toISOString()}).eq('id',id);
  if(error) throw error;
}

/* ── ARQUIVOS RECEBIDOS ── */
async function dbGetArquivos(filters={}) {
  let q = getDB().from('arquivos_recebidos').select('*').order('created_at',{ascending:false});
  if(filters.tipo) q = q.eq('tipo',filters.tipo);
  if(filters.search) q = q.ilike('nome',`%${filters.search}%`);
  const {data,error} = await q;
  if(error) throw error; return data||[];
}
async function dbDeleteArquivo(id) {
  const {error} = await getDB().from('arquivos_recebidos').delete().eq('id',id);
  if(error) throw error;
}

/* ── DASHBOARD STATS ── */
async function dbGetDashboardStats() {
  const db = getDB();
  const now = new Date();
  const mesInicio = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();

  const [emitidas, recebidas, pendentes, arquivos] = await Promise.all([
    db.from('notas_emitidas').select('id,status,valor_total,tipo_nota').gte('data_emissao', mesInicio),
    db.from('notas_recebidas').select('id').gte('data_emissao', mesInicio.split('T')[0]),
    db.from('notas_recebidas').select('id').eq('manifest','pendente'),
    db.from('arquivos_recebidos').select('id'),
  ]);

  const em = emitidas.data || [];
  return {
    nfe_mes: em.filter(n=>n.tipo_nota==='NF-e').length,
    nfce_mes: em.filter(n=>n.tipo_nota==='NFC-e').length,
    recebidas_mes: (recebidas.data||[]).length,
    valor_mes: em.reduce((s,n)=>s+Number(n.valor_total||0),0),
    pendentes_manifest: (pendentes.data||[]).length,
    arquivos_total: (arquivos.data||[]).length,
    status_breakdown: {
      autorizada: em.filter(n=>n.status==='autorizada').length,
      cancelada: em.filter(n=>n.status==='cancelada').length,
      pendente: em.filter(n=>['em_digitacao','validada','processando'].includes(n.status)).length,
      rejeitada: em.filter(n=>n.status==='rejeitada').length,
    }
  };
}

/* ── MUNICIPIOS / IBGE ── */
async function dbGetMunicipioIBGE(nome, uf) {
  if (!nome || !uf) return null;
  const {data} = await getDB()
    .from('municipios')
    .select('ibge,nome,uf')
    .ilike('nome', nome.trim())
    .eq('uf', uf.toUpperCase())
    .limit(1)
    .maybeSingle();
  return data;
}

/**
 * Consulta ViaCEP e preenche campos de endereço.
 * @param {string} cep - CEP sem formatação (8 dígitos)
 * @param {object} ids - mapa de campo → id do elemento
 *   ex: { logradouro:'m-logradouro', bairro:'m-bairro', municipio:'m-municipio', uf:'m-uf', ibge:'m-ibge' }
 */
async function dbBuscarCEP(cep, ids) {
  const v = cep.replace(/\D/g,'');
  if (v.length !== 8) return;
  try {
    const r = await fetch(`https://viacep.com.br/ws/${v}/json/`);
    const d = await r.json();
    if (d.erro) return;
    if (ids.logradouro) { const el=document.getElementById(ids.logradouro); if(el && !el.value) el.value = d.logradouro||''; }
    if (ids.bairro)     { const el=document.getElementById(ids.bairro);     if(el) el.value = d.bairro||''; }
    if (ids.municipio)  { const el=document.getElementById(ids.municipio);  if(el) el.value = d.localidade||''; }
    if (ids.uf)         { const el=document.getElementById(ids.uf);         if(el) el.value = d.uf||'SP'; }
    if (ids.ibge && d.ibge) { const el=document.getElementById(ids.ibge); if(el) el.value = d.ibge; }
  } catch(e) { /* silencioso — sem internet */ }
}

/* ── FORNECEDORES ── */
async function dbGetFornecedores() {
  const {data,error} = await getDB().from('fornecedores').select('*').order('razao');
  if(error) throw error; return data||[];
}
async function dbSaveFornecedor(f) {
  const {id,...fields} = f;
  fields.updated_at = new Date().toISOString();
  if(id) {
    const {error} = await getDB().from('fornecedores').update(fields).eq('id',id);
    if(error) throw error; return id;
  } else {
    const {data,error} = await getDB().from('fornecedores').insert(fields).select().single();
    if(error) throw error; return data.id;
  }
}
async function dbDeleteFornecedor(id) {
  const {error} = await getDB().from('fornecedores').delete().eq('id',id);
  if(error) throw error;
}

/* ── TRANSPORTADORAS ── */
async function dbGetTransportadoras() {
  const {data,error} = await getDB().from('transportadoras').select('*').order('razao');
  if(error) throw error; return data||[];
}
async function dbSaveTransportadora(t) {
  const {id,...fields} = t;
  fields.updated_at = new Date().toISOString();
  if(id) {
    const {error} = await getDB().from('transportadoras').update(fields).eq('id',id);
    if(error) throw error; return id;
  } else {
    const {data,error} = await getDB().from('transportadoras').insert(fields).select().single();
    if(error) throw error; return data.id;
  }
}
async function dbDeleteTransportadora(id) {
  const {error} = await getDB().from('transportadoras').delete().eq('id',id);
  if(error) throw error;
}

/* ── EMPRESA (single-row) ── */
async function dbGetEmpresa() {
  const { data, error } = await getDB()
    .from('empresa').select('*').limit(1).maybeSingle();
  if (error) throw error;
  return data || {};
}

async function dbSaveEmpresa(emp) {
  const db = getDB();
  emp.updated_at = new Date().toISOString();
  const { data: existing } = await db.from('empresa').select('id').limit(1).maybeSingle();
  if (existing?.id) {
    const { error } = await db.from('empresa').update(emp).eq('id', existing.id);
    if (error) throw error;
  } else {
    const { error } = await db.from('empresa').insert(emp);
    if (error) throw error;
  }
}

/* ── CONFIGURAÇÕES (single-row) ── */
async function dbGetConfig() {
  const { data, error } = await getDB()
    .from('configuracoes')
    .select('*')
    .limit(1)
    .maybeSingle();
  if (error) throw error;
  return data || {};
}

async function dbSaveConfig(cfg) {
  const db = getDB();
  cfg.updated_at = new Date().toISOString();
  const { data: existing } = await db.from('configuracoes').select('id').limit(1).maybeSingle();
  if (existing?.id) {
    const { error } = await db.from('configuracoes').update(cfg).eq('id', existing.id);
    if (error) throw error;
  } else {
    const { error } = await db.from('configuracoes').insert(cfg);
    if (error) throw error;
  }
}

/* ── Toast CSS injected ── */
(function(){
  const s = document.createElement('style');
  s.textContent = `.db-toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%);padding:10px 22px;border-radius:8px;font-size:13px;font-weight:600;z-index:9999;animation:toastIn .2s ease;color:#fff;box-shadow:0 4px 16px rgba(0,0,0,.15)}.db-toast.ok{background:#16a34a}.db-toast.error{background:#dc2626}.db-toast.info{background:#f97316}@keyframes toastIn{from{opacity:0;transform:translateX(-50%) translateY(12px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}`;
  document.head.appendChild(s);
})();
