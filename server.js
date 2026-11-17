require('dotenv').config();

const crypto = require('node:crypto');
const path = require('node:path');
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { Pool } = require('pg');

const app = express();
const PORT = Number(process.env.PORT || 3000);
const SESSION_DAYS = Math.max(1, Math.min(30, Number(process.env.SESSION_DAYS || 7)));
const COOKIE_NAME = 'ecodata_sid';
const SESSION_SECRET = process.env.SESSION_SECRET || '';

if (SESSION_SECRET.length < 32) {
  console.error('ERROR: SESSION_SECRET debe tener al menos 32 caracteres. Configura el archivo .env.');
  process.exit(1);
}

const poolConfig = process.env.DATABASE_URL
  ? { connectionString: process.env.DATABASE_URL }
  : {
      host: process.env.DB_HOST || '127.0.0.1',
      port: Number(process.env.DB_PORT || 5432),
      database: process.env.DB_NAME || 'ecodata',
      user: process.env.DB_USER || 'lis',
      password: process.env.DB_PASSWORD || undefined,
    };

if (process.env.DB_SSL === 'true') {
  poolConfig.ssl = { rejectUnauthorized: process.env.DB_SSL_REJECT_UNAUTHORIZED !== 'false' };
}

const pool = new Pool({ ...poolConfig, max: 10, idleTimeoutMillis: 30000, connectionTimeoutMillis: 5000 });
pool.on('error', (err) => console.error('Error inesperado del pool PostgreSQL:', err.message));

app.disable('x-powered-by');
app.use(helmet({ contentSecurityPolicy: false, crossOriginEmbedderPolicy: false }));
app.use(express.json({ limit: '32kb' }));

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 12,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { error: 'Demasiados intentos. Espera unos minutos e inténtalo nuevamente.' },
});

function parseCookies(header = '') {
  const result = {};
  for (const item of header.split(';')) {
    const index = item.indexOf('=');
    if (index < 0) continue;
    const key = item.slice(0, index).trim();
    const value = item.slice(index + 1).trim();
    try { result[key] = decodeURIComponent(value); } catch { result[key] = value; }
  }
  return result;
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function cookieOptions() {
  return {
    httpOnly: true,
    secure: process.env.COOKIE_SECURE === 'true' || process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    path: '/',
    maxAge: SESSION_DAYS * 24 * 60 * 60 * 1000,
  };
}

function createPasswordHash(password) {
  return new Promise((resolve, reject) => {
    const salt = crypto.randomBytes(16);
    crypto.scrypt(password, salt, 64, { N: 16384, r: 8, p: 1, maxmem: 64 * 1024 * 1024 }, (err, derivedKey) => {
      if (err) return reject(err);
      resolve(`scrypt$${salt.toString('hex')}$${derivedKey.toString('hex')}`);
    });
  });
}

function verifyPassword(password, stored) {
  return new Promise((resolve, reject) => {
    const [scheme, saltHex, keyHex] = String(stored || '').split('$');
    if (scheme !== 'scrypt' || !saltHex || !keyHex) return resolve(false);
    const salt = Buffer.from(saltHex, 'hex');
    const expected = Buffer.from(keyHex, 'hex');
    crypto.scrypt(password, salt, expected.length, { N: 16384, r: 8, p: 1, maxmem: 64 * 1024 * 1024 }, (err, actual) => {
      if (err) return reject(err);
      if (actual.length !== expected.length) return resolve(false);
      resolve(crypto.timingSafeEqual(actual, expected));
    });
  });
}

async function createSession(userId, res) {
  const token = crypto.randomBytes(32).toString('base64url');
  const expiresAt = new Date(Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000);
  await pool.query(
    'INSERT INTO public.usuario_sesion_ecodata (id_usuario, token_hash, expira_en) VALUES ($1, $2, $3)',
    [userId, hashToken(token), expiresAt]
  );
  res.cookie(COOKIE_NAME, token, cookieOptions());
}

async function requireUser(req, res, next) {
  try {
    const token = parseCookies(req.headers.cookie || '')[COOKIE_NAME];
    if (!token || token.length > 200) return res.status(401).json({ error: 'Inicia sesión para continuar.' });
    const result = await pool.query(
      `SELECT u.id_usuario, u.nombre, u.correo
       FROM public.usuario_sesion_ecodata s
       JOIN public.usuario_ecodata u ON u.id_usuario = s.id_usuario
       WHERE s.token_hash = $1 AND s.expira_en > NOW() AND u.activo = TRUE
       LIMIT 1`,
      [hashToken(token)]
    );
    if (!result.rowCount) return res.status(401).json({ error: 'La sesión expiró. Inicia sesión nuevamente.' });
    req.user = result.rows[0];
    req.sessionTokenHash = hashToken(token);
    next();
  } catch (err) {
    next(err);
  }
}

function parsePositiveInt(value) {
  if (!/^\d+$/.test(String(value || ''))) return null;
  const number = Number(value);
  return Number.isSafeInteger(number) && number > 0 ? number : null;
}

function buildProductFilters(query, params) {
  const filters = [];
  const q = String(query.q || '').trim();
  if (q) {
    params.push(`%${q.slice(0, 100)}%`);
    filters.push(`(p.nombre ILIKE $${params.length} OR COALESCE(p.marca, '') ILIKE $${params.length})`);
  }
  const category = query.categoria ? parsePositiveInt(query.categoria) : null;
  if (query.categoria && !category) throw Object.assign(new Error('La categoría seleccionada no es válida.'), { status: 400 });
  if (category) { params.push(category); filters.push(`p.id_categoria = $${params.length}`); }
  const material = query.material ? parsePositiveInt(query.material) : null;
  if (query.material && !material) throw Object.assign(new Error('El material seleccionado no es válido.'), { status: 400 });
  if (material) {
    params.push(material);
    filters.push(`EXISTS (SELECT 1 FROM public.producto_material pmf WHERE pmf.id_producto = p.id_producto AND pmf.id_material = $${params.length})`);
  }
  const country = query.pais ? parsePositiveInt(query.pais) : null;
  if (query.pais && !country) throw Object.assign(new Error('El país seleccionado no es válido.'), { status: 400 });
  if (country) { params.push(country); filters.push(`p.id_pais = $${params.length}`); }
  const level = String(query.nivel || '').trim();
  const validLevels = ['Bajo (caso nacional)', 'Medio (caso nacional)', 'Alto (caso nacional)'];
  if (level && !validLevels.includes(level)) throw Object.assign(new Error('El nivel de impacto seleccionado no es válido.'), { status: 400 });
  if (level) { params.push(level); filters.push(`EXISTS (SELECT 1 FROM public.impacto_ambiental il WHERE il.id_producto = p.id_producto AND il.nivel_impacto = $${params.length})`); }
  return filters.length ? `WHERE ${filters.join(' AND ')}` : '';
}

const productSelect = `
  SELECT
    p.id_producto, p.nombre, p.marca, p.precio_aproximado, p.vida_util,
    c.nombre AS categoria, pa.nombre AS pais,
    COALESCE(mat.materiales, '[]'::json) AS materiales,
    COALESCE(imp.impactos, '[]'::json) AS impactos
  FROM public.producto p
  JOIN public.categoria c ON c.id_categoria = p.id_categoria
  LEFT JOIN public.pais pa ON pa.id_pais = p.id_pais
  LEFT JOIN LATERAL (
    SELECT json_agg(json_build_object(
      'id_material', m.id_material,
      'nombre', m.nombre,
      'tipo', m.tipo,
      'reciclable', m.reciclable
    ) ORDER BY m.nombre) AS materiales
    FROM public.producto_material pm
    JOIN public.material m ON m.id_material = pm.id_material
    WHERE pm.id_producto = p.id_producto
  ) mat ON TRUE
  LEFT JOIN LATERAL (
    SELECT json_agg(json_build_object(
      'id_impacto', ia.id_impacto,
      'consumo_agua', ia.consumo_agua,
      'consumo_energia', ia.consumo_energia,
      'emisiones_co2', ia.emisiones_co2,
      'residuos_generados', ia.residuos_generados,
      'nivel_impacto', ia.nivel_impacto,
      'fecha_dato', ia.fecha_dato,
      'fuente', f.nombre
    ) ORDER BY ia.fecha_dato NULLS LAST, ia.id_impacto) AS impactos
    FROM public.impacto_ambiental ia
    JOIN public.fuente f ON f.id_fuente = ia.id_fuente
    WHERE ia.id_producto = p.id_producto
  ) imp ON TRUE
`;

app.get('/api/health', async (req, res, next) => {
  try {
    const r = await pool.query('SELECT current_database() AS database, NOW() AS server_time');
    res.json({ ok: true, database: r.rows[0].database, serverTime: r.rows[0].server_time });
  } catch (err) { next(err); }
});

app.get('/api/catalogos', async (req, res, next) => {
  try {
    const [categories, materials, countries] = await Promise.all([
      pool.query('SELECT id_categoria, nombre FROM public.categoria ORDER BY nombre'),
      pool.query('SELECT id_material, nombre FROM public.material ORDER BY nombre'),
      pool.query('SELECT id_pais, nombre FROM public.pais ORDER BY nombre'),
    ]);
    res.json({ categories: categories.rows, materials: materials.rows, countries: countries.rows });
  } catch (err) { next(err); }
});

app.get('/api/productos', async (req, res, next) => {
  try {
    const params = [];
    const where = buildProductFilters(req.query, params);
    const countParams = [...params];
    params.push(100);
    const [result, totalResult] = await Promise.all([
      pool.query(`${productSelect} ${where} ORDER BY p.id_producto LIMIT $${params.length}`, params),
      pool.query(`SELECT COUNT(*)::int AS total FROM public.producto p ${where}`, countParams),
    ]);
    res.json({ total: totalResult.rows[0].total, products: result.rows });
  } catch (err) { next(err); }
});

app.get('/api/comparar', async (req, res, next) => {
  try {
    const raw = String(req.query.ids || '').split(',').filter(Boolean);
    const ids = [...new Set(raw.map(parsePositiveInt))];
    if (ids.some(id => id === null) || ids.length < 2 || ids.length > 3) {
      return res.status(400).json({ error: 'Selecciona entre dos y tres productos válidos para comparar.' });
    }
    const result = await pool.query(`${productSelect} WHERE p.id_producto = ANY($1::int[]) ORDER BY p.id_producto`, [ids]);
    if (result.rowCount !== ids.length) return res.status(404).json({ error: 'Uno o más productos ya no están disponibles.' });
    res.json({ products: result.rows });
  } catch (err) { next(err); }
});

app.post('/api/auth/registro', authLimiter, async (req, res, next) => {
  const nombre = String(req.body?.nombre || '').trim();
  const correo = String(req.body?.correo || '').trim().toLowerCase();
  const contrasena = String(req.body?.contrasena || '');
  if (nombre.length < 2 || nombre.length > 120) return res.status(400).json({ error: 'Escribe un nombre de entre 2 y 120 caracteres.' });
  if (correo.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo)) return res.status(400).json({ error: 'Escribe un correo electrónico válido.' });
  if (contrasena.length < 10 || contrasena.length > 128) return res.status(400).json({ error: 'La contraseña debe tener entre 10 y 128 caracteres.' });
  try {
    const passwordHash = await createPasswordHash(contrasena);
    const client = await pool.connect();
    let user;
    try {
      await client.query('BEGIN');
      const inserted = await client.query(
        `INSERT INTO public.usuario_ecodata (nombre, correo, password_hash)
         VALUES ($1, $2, $3)
         RETURNING id_usuario, nombre, correo`,
        [nombre, correo, passwordHash]
      );
      user = inserted.rows[0];
      const token = crypto.randomBytes(32).toString('base64url');
      const expiresAt = new Date(Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000);
      await client.query(
        'INSERT INTO public.usuario_sesion_ecodata (id_usuario, token_hash, expira_en) VALUES ($1, $2, $3)',
        [user.id_usuario, hashToken(token), expiresAt]
      );
      await client.query('COMMIT');
      res.cookie(COOKIE_NAME, token, cookieOptions());
    } catch (err) {
      await client.query('ROLLBACK').catch(() => {});
      if (err.code === '23505') return res.status(409).json({ error: 'Ya existe una cuenta con ese correo electrónico.' });
      throw err;
    } finally { client.release(); }
    res.status(201).json({ user });
  } catch (err) { next(err); }
});

app.post('/api/auth/login', authLimiter, async (req, res, next) => {
  const correo = String(req.body?.correo || '').trim().toLowerCase();
  const contrasena = String(req.body?.contrasena || '');
  if (!correo || !contrasena) return res.status(400).json({ error: 'Escribe tu correo y contraseña.' });
  try {
    const result = await pool.query(
      'SELECT id_usuario, nombre, correo, password_hash FROM public.usuario_ecodata WHERE correo = $1 AND activo = TRUE LIMIT 1',
      [correo]
    );
    const userRow = result.rows[0];
    const valid = userRow ? await verifyPassword(contrasena, userRow.password_hash) : false;
    if (!valid) return res.status(401).json({ error: 'Correo o contraseña incorrectos.' });
    const user = { id_usuario: userRow.id_usuario, nombre: userRow.nombre, correo: userRow.correo };
    await createSession(user.id_usuario, res);
    res.json({ user });
  } catch (err) { next(err); }
});

app.get('/api/auth/me', requireUser, (req, res) => res.json({ user: req.user }));

app.post('/api/auth/logout', async (req, res, next) => {
  try {
    const token = parseCookies(req.headers.cookie || '')[COOKIE_NAME];
    if (token) await pool.query('DELETE FROM public.usuario_sesion_ecodata WHERE token_hash = $1', [hashToken(token)]);
    res.clearCookie(COOKIE_NAME, { ...cookieOptions(), maxAge: undefined });
    res.json({ ok: true });
  } catch (err) { next(err); }
});

app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'index.html')));
app.get('*', (req, res) => res.status(404).send('Ruta no encontrada.'));

app.use((err, req, res, next) => {
  console.error('Error API:', err.message);
  const status = Number(err.status) >= 400 && Number(err.status) < 600 ? Number(err.status) : 500;
  res.status(status).json({ error: status === 500 ? 'Ocurrió un error en el servidor. Revisa la conexión con PostgreSQL.' : err.message });
});

const server = app.listen(PORT, () => console.log(`EcoData API disponible en http://localhost:${PORT}`));

async function shutdown() {
  console.log('\nCerrando EcoData API…');
  server.close(async () => {
    await pool.end();
    process.exit(0);
  });
}
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
