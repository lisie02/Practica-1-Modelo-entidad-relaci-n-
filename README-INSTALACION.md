# EcoData Web — instalación local

Esta versión conserva el proyecto visual de EcoData y añade una API Node.js/Express que consulta PostgreSQL y gestiona registro e inicio de sesión.

## Qué contiene

- `index.html`: página responsive en español, con catálogo, filtros, detalle, comparación y formularios de usuario.
- `server.js`: API que entrega el HTML y consulta PostgreSQL; gestiona cuentas y sesiones.
- `sql/010-usuarios-ecodata.sql`: crea las tablas de cuentas y sesiones, sin modificar las nueve tablas existentes.
- `sql/011-permisos-api.sql`: crea un usuario PostgreSQL de privilegios limitados para la aplicación.
- `.env.example`: plantilla de configuración. Debe copiarse a `.env` y completarse localmente.

## Requisitos

- Node.js 20 o posterior.
- Docker con el contenedor PostgreSQL `practica1` en ejecución.
- Acceso administrativo a la base `ecodata` para ejecutar las dos migraciones.

## 1. Copiar los archivos al repositorio

Copia `index.html`, `server.js`, `package.json`, `.gitignore`, `.env.example`, `README-INSTALACION.md` y las carpetas `sql` al directorio raíz de tu repositorio, donde actualmente está el `index.html` publicado.

Conserva `index-original.html` como respaldo si viene incluido en el paquete; no es necesario publicarlo.

## 2. Crear las tablas de usuarios

Desde PowerShell, en la raíz del repositorio:

```powershell
Get-Content .\sql\010-usuarios-ecodata.sql -Raw | docker exec -i practica1 psql -v ON_ERROR_STOP=1 -U lis -d ecodata
```

## 3. Crear el usuario limitado para la API

Ejecuta los permisos:

```powershell
Get-Content .\sql\011-permisos-api.sql -Raw | docker exec -i practica1 psql -v ON_ERROR_STOP=1 -U lis -d ecodata
```

Asigna una contraseña local al usuario de aplicación. Abre una sesión interactiva:

```powershell
docker exec -it practica1 psql -U lis -d ecodata
```

Dentro de `psql`, ejecuta:

```text
\password ecodata_web
\q
```

La contraseña no se guarda en este repositorio. No la pegues en el chat ni en archivos `.sql`.

## 4. Comprobar el puerto del contenedor

Node.js se ejecutará en Windows y necesita poder alcanzar PostgreSQL por TCP. Comprueba si el contenedor publica el puerto 5432:

```powershell
docker port practica1 5432
```

Si aparece una dirección como `0.0.0.0:5432` o `127.0.0.1:5432`, usa ese puerto en `.env`. Si no aparece ninguna asignación, el contenedor no expone PostgreSQL al host; no cambies ni recrees el contenedor todavía. Se debe configurar la red de Docker de forma controlada antes de iniciar la API.

## 5. Configurar las variables privadas

Copia la plantilla:

```powershell
Copy-Item .env.example .env
```

Abre `.env` y completa:

```dotenv
NODE_ENV=development
PORT=3000
SESSION_DAYS=7
SESSION_SECRET=PEGA_AQUI_UN_SECRETO_ALEATORIO_LARGO
COOKIE_SECURE=false
DB_HOST=127.0.0.1
DB_PORT=5432
DB_NAME=ecodata
DB_USER=ecodata_web
DB_PASSWORD=LA_CONTRASENA_QUE_ASIGNASTE_A_ECODATA_WEB
DB_SSL=false
```

Genera el secreto de sesión desde PowerShell:

```powershell
node -e "console.log(require('crypto').randomBytes(48).toString('base64url'))"
```

Copia el resultado en `SESSION_SECRET`. No publiques `.env`; está excluido mediante `.gitignore`.

## 6. Instalar e iniciar

```powershell
npm install
npm start
```

Abre `http://localhost:3000` en el navegador. La barra de estado debe indicar que la base de datos está conectada. Prueba el catálogo y registra una cuenta de prueba.

Si aparece un error de conexión, revisa que el contenedor esté activo, que el puerto esté publicado y que los valores de `.env` coincidan. No compartas contraseñas para pedir ayuda; basta con compartir el mensaje de error sin credenciales.

## 7. Cómo funciona el registro

El registro inserta una fila en `usuario_ecodata`. La contraseña se deriva con `scrypt` y una sal aleatoria; nunca se almacena la contraseña original. Al iniciar sesión se crea una sesión aleatoria, de la que se guarda solamente su hash en `usuario_sesion_ecodata`. El navegador recibe una cookie `HttpOnly`, `SameSite=Strict`; el servidor valida la sesión contra PostgreSQL.

La API limita los intentos de registro e inicio de sesión. Los endpoints de catálogo y comparación son de solo lectura. Esta versión no permite que un usuario modifique los productos del catálogo.

## 8. Publicación en Internet

GitHub Pages solamente publica archivos estáticos; no ejecuta `server.js` ni puede abrir una conexión privada a PostgreSQL. Para que el registro y las consultas funcionen públicamente, hay que desplegar **esta aplicación Node.js** en un servicio de hosting y utilizar una base PostgreSQL accesible desde ese servicio (por ejemplo, una instancia administrada). No expongas el contenedor local ni sus credenciales a Internet.

En producción configura `NODE_ENV=production`, `COOKIE_SECURE=true`, `SESSION_SECRET` como secreto del proveedor, y los datos de conexión PostgreSQL como variables privadas. Sirve el frontend y la API desde el mismo origen para que la cookie de sesión funcione correctamente.
