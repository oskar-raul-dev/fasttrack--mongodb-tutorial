# MongoDB FastTrack — Sección 1: entorno Docker

**Repositorio:** `mongodb-fasttrack-tutorial`  
**Perfil:** desarrollador Senior Java con experiencia en Docker, SQL y Spring Boot.  
**Duración fijada por `00-syllabus.md`:** 45 minutos. La comparación profunda entre variantes, la compilación extensa y los respaldos son una ampliación opcional fuera de ese bloque; el syllabus completo establece un máximo de 12 horas.  
**Alcance:** solamente la sección 1; no se adelantan las lecciones de modelado ni de drivers.

> **Origen de los archivos técnicos.** La variante A parte de los cuatro archivos que
> funcionaron en el equipo del alumno: `Dockerfile`, `compose.yaml`,
> `supervisord.conf` y `start-mongo-express.sh`. Se reorganizan para ubicar
> TODOS los archivos de construcción de la imagen bajo
> `docker-image-scripts/`. Se actualizan las rutas en Compose y los
> comentarios que todavía aludían a npm. La variante B es una alternativa
> adicional con dos imágenes oficiales; no se afirma que se haya ejecutado
> en el equipo del alumno.

## Fuente de verdad y correspondencia con `00-syllabus.md`

Esta edición se ha contrastado **directamente con el archivo
`00-syllabus.md` del proyecto**. Se respeta el título, duración (45 minutos),
la lista completa de temas y los cuatro entregables de su sección 01. El
syllabus indica que se trabaja una sección por chat, de forma incremental,
escribiendo el repositorio en VS Code; se presupone un desarrollador Senior
Java y no se repiten clases generales de Docker o programación.

| Tema literal de la sección 01 | Actividad en esta lección |
|---|---|
| Estructura del repositorio Git | §2 y §2.1: árbol, inicialización y Git |
| VS Code | §2.1: abrir proyecto y crear archivos |
| Docker Compose | §4.6–4.7 y §5.1–5.3 |
| MongoDB 8.0 | §3, §4 y §5.2–5.4 |
| Mongo Express | §3, §4 y comprobación HTTP en §5 |
| Redes Docker | §3.1–3.2, §4, §5.3 |
| Volúmenes | §3, §4.6–4.7, §5.6 |
| Bind mounts | §2, §4.6–4.7 y §5.5 |
| Persistencia frente a backup | §5.6, ejercicio individual |
| `mongod` | §5.3.1: servidor, versión y proceso |
| `mongosh` | §5.3.1, §5.4, §5.5 |
| Bash dentro del contenedor | §5.3.1 y §5.5 |
| Primera base de datos | §5.4–5.5: `inventory` |
| Primera colección | §5.4–5.5: `products` |
| Primer documento | §5.4–5.5: `LAB-001` y `SCRIPT-001` |
| Scripts JavaScript del repositorio | §5.5: `--file` y `load()` |

**Los cuatro entregables que exige el syllabus:** `compose.yaml`,
`.gitignore`, estructura inicial del proyecto y primer script de `mongosh`.
Sus comprobaciones objetivas están en §6.2. Los archivos adicionales
`compose.multi.yaml`, `.env.example`, `.dockerignore` y los tres archivos
bajo `docker-image-scripts/` forman parte de la **ampliación solicitada para
este proyecto**, no de nuevos requisitos impuestos por el syllabus.

### Distribución de los 45 minutos obligatorios

| Tiempo | Laboratorio principal |
|---:|---|
| 0–7 min | Crear árbol, `.gitignore`, Git y abrir VS Code (§2) |
| 7–13 min | Revisar redes, puertos y montajes; elegir A o B (§3–4) |
| 13–25 min | Validar Compose y arrancar una variante (§5.1–5.3) |
| 25–32 min | Entrar a Bash; comprobar `mongod` y `mongosh` (§5.3–5.4) |
| 32–41 min | Crear primera base, colección, documento y script (§5.4–5.5) |
| 41–45 min | Ejecutar `--file`, comprobar persistencia y entregables (§5–6) |

**Ampliación opcional, fuera de los 45 minutos:** construir A desde cero,
compararla con B en ejecución simultánea, profundizar en Node/Corepack/Yarn,
crear `mongodump`, reproducir errores e implementar el ejercicio individual.
El build completo de A puede exceder el tiempo de la sesión. Para mantener
el itinerario de 45 minutos, si A no está ya construida utiliza B para el
primer contacto y realiza la compilación de A como ampliación.

## 1. Objetivos y requisitos

Al terminar podrás: distinguir imagen, contenedor, volumen y red; levantar
MongoDB 8.0 y Mongo Express 1.0.2 de dos maneras; explicar por qué la variante
A necesita Node.js, Git, Corepack, Yarn, Supervisor y Tini; ejecutar `mongosh`;
verificar autenticación, puertos, procesos y persistencia; realizar un respaldo
de laboratorio mediante `mongodump`; ejecutar el primer archivo JavaScript versionado con `mongosh --file`;
y diagnosticar errores de construcción
y de arranque sin borrar accidentalmente los datos.

**Requisitos:** Docker Desktop o Docker Engine con Docker Compose v2, terminal,
VS Code y conexión a Internet durante la descarga de imágenes y dependencias.
Se presupone familiaridad con Docker: nos concentraremos en sus decisiones
específicas para MongoDB. Los comandos están escritos para Bash o zsh en
macOS/Linux; en Windows pueden ejecutarse desde una terminal compatible.

**Puertos deliberadamente no predeterminados:**

| Servicio | Puerto interno | Variante A en host | Variante B en host |
|---|---:|---:|---:|
| MongoDB | 27017 | 27028 | 27029 |
| Mongo Express | 8081 | 8082 | 8083 |

Los puertos del host se publican exclusivamente en `127.0.0.1`: accesibles
desde la propia máquina, no desde toda la LAN. Los puertos internos no cambian.

## 2. Estructura del repositorio

Crea este esqueleto; los módulos Node.js, Java Core y Spring Boot se
incorporarán en secciones posteriores. La carpeta `docker-image-scripts/`
contiene el Dockerfile y **todos sus archivos locales de entrada**; sus
dependencias remotas se descargan durante la construcción.

```text
mongodb-fasttrack-tutorial/
|-- compose-a.yaml               # A: un contenedor
|-- compose-b.yaml               # B: dos contenedores
|-- .env.example                 # plantilla sin secretos reales
|-- .env                         # configuración local; ignorada por Git
|-- .dockerignore                # reduce el contexto del build
|-- .gitignore
|-- README.md                    # índice del futuro curso
|-- docker-image-scripts/
|   |-- Dockerfile
|   |-- supervisord.conf
|   `-- start-mongo-express.sh
|-- docs/
|   |-- lessons/
|   |   `-- 01-entorno-docker.md
|   `-- adr/
|-- mongo/
|   |-- init/
|   |-- scripts/
|   |   `-- 01-primer-contacto.js
|   |-- datasets/
|   `-- backups/
|       |-- single/
|       `-- multi/
|-- node-api/                     # secciones posteriores
|-- java-core/                    # secciones posteriores
|-- spring-api/                   # secciones posteriores
`-- http/                         # secciones posteriores
```

```bash
mkdir -p docker-image-scripts docs/lessons docs/adr \
  mongo/init mongo/scripts mongo/datasets \
  mongo/backups/single mongo/backups/multi \
  node-api java-core spring-api http

# Git no versiona carpetas vacías: conservar el esqueleto.
touch docs/lessons/.gitkeep docs/adr/.gitkeep \
  mongo/init/.gitkeep mongo/scripts/.gitkeep \
  mongo/datasets/.gitkeep mongo/backups/single/.gitkeep \
  mongo/backups/multi/.gitkeep node-api/.gitkeep \
  java-core/.gitkeep spring-api/.gitkeep http/.gitkeep

# Si partes de los cuatro archivos entregados y todavía están
# en la raíz, mueve los tres archivos de construcción:
mv Dockerfile supervisord.conf start-mongo-express.sh \
   docker-image-scripts/

# compose.yaml permanece en la raíz: referencia el Dockerfile
# mediante build.dockerfile: docker-image-scripts/Dockerfile.
```

### 2.1. Git y VS Code: preparar el espacio de trabajo

En VS Code abre la carpeta **`mongodb-fasttrack-tutorial/`** como
*workspace*, no únicamente el Dockerfile. Usa el terminal integrado
(`Terminal → New Terminal`) para ejecutar los comandos desde la raíz.
Instala la extensión oficial **MongoDB for VS Code** únicamente si
quieres explorar los datos gráficamente: los ejercicios de esta
sección se hacen con `mongosh`, de modo que la extensión no es obligatoria.
La extensión Docker es opcional para inspeccionar imágenes, redes y logs.

```bash
# Situarse en la raíz del repositorio desde el terminal integrado.
pwd

# Crear un repositorio local solo si todavía no está inicializado.
# Este control evita reemplazar o alterar un repositorio existente.
if [ ! -d .git ]; then git init; fi

# Abrir el workspace completo en VS Code (si 'code' está en el PATH).
code .

# Ver qué archivos están pendientes de versionar.
git status --short

# Comprobar que el archivo con secretos está excluido.
git check-ignore .env
```

**Estructura y responsabilidades:** `docker-image-scripts/` contiene
exclusivamente archivos que consume el Dockerfile durante el build.
`mongo/scripts/` almacena JavaScript ejecutado manualmente desde
`mongosh`; `mongo/init/` queda reservado para inicializadores que
requieren un volumen vacío; `mongo/backups/` contiene datos generados,
ignorados por Git. Los archivos Compose y `.env.example` permanecen en
la raíz porque configuran el laboratorio, no la construcción de la imagen.

**Archivo `README.md` mínimo (editar desde VS Code):**

Guarda este documento en `docs/lessons/01-entorno-docker.md` y conserva
`00-syllabus.md` en el proyecto como referencia de alcance; no modifiques
el contenido de la sección 02 para adelantar temas en este chat.

```markdown
# mongodb-fasttrack-tutorial

Laboratorio incremental MongoDB para desarrollador Senior Java.

## Sección 01

- Variante A: `docker compose -f compose-a.yaml up -d --build`
- Variante B: `docker compose -f compose-b.yaml up -d`
- Variables: copiar `.env.example` a `.env` y cambiar contraseñas.
- Script inicial: `mongo/scripts/01-primer-contacto.js`.
- Lección: `docs/lessons/01-entorno-docker.md`.

No publicar `.env` ni los archivos de `mongo/backups/`.
```

No hagas `git add .` sin revisar antes el resultado de
`git status --short`. En particular, `.env` nunca debe entrar al commit.

## 3. Arquitectura y conceptos necesarios

**Imagen**: plantilla inmutable formada por capas. **Contenedor**: instancia
ejecutable de una imagen. **Volumen con nombre**: persiste los archivos de
MongoDB aunque se recree su contenedor. **Bind mount**: enlaza un directorio
real del repositorio (`mongo/backups/...`) para inspeccionar respaldos desde
el host. **Red bridge de Compose**: facilita que servicios separados se
encuentren por nombre DNS, como `mongodb:27017`. **Healthcheck**: comprueba
que un servicio responde; no sustituye las pruebas de la aplicación.

### 3.1. Variante A: un contenedor, dos procesos

```text
Host (Mac / Windows / Linux)
+------------------------------------------------------------------+
| 127.0.0.1:27028 ---------------------+                            |
| 127.0.0.1:8082 -------------------+  |                            |
|                                  |  |                            |
|  Contenedor mongodb-fasttrack-tutorial                           |
|  +-------------------------------|--|-------------------------+  |
|  | tini (PID 1)                  |  |                         |  |
|  |   `-- supervisord             |  |                         |  |
|  |       |                       |  |                         |  |
|  |       |-- entrypoint -> mongod|<-+ :27017                  |  |
|  |       `-- script -> node      |    Mongo Express :8081     |  |
|  |                    |          |                           |  |
|  |                    `----------+                           |  |
|  |                                                           |  |
|  | /data/db        -> volumen mongo_data                     |  |
|  | /data/configdb  -> volumen mongo_config                   |  |
|  | /backups        -> ./mongo/backups/single                 |  |
|  +-----------------------------------------------------------+  |
+------------------------------------------------------------------+
```

Ambos procesos comparten el espacio de red del mismo contenedor. Mongo
Express se conecta a `127.0.0.1:27017`; **jamás** a `27028`, que es el puerto
publicado en el host. Tini reenvía señales y recolecta procesos hijos;
Supervisor inicia, observa y reinicia los dos programas. Su prioridad de
arranque no garantiza que MongoDB acepte conexiones: el script hace un
`ping` autenticado y espera hasta obtener `ok: 1`.

### 3.2. Variante B: dos contenedores, una red privada

```text
Host (Mac / Windows / Linux)
+------------------------------------------------------------------+
| 127.0.0.1:27029          127.0.0.1:8083                         |
|       |                          |                               |
|       v                          v                               |
|  +-------------------+      +-------------------------+          |
|  | mongo:8.0         |      | mongo-express:1.0.2     |          |
|  | servicio: mongodb |<-----| servicio: mongo-express |          |
|  | interno: 27017    | DNS  | interno: 8081           |          |
|  +---------+---------+      +-------------------------+          |
|            |              red bridge inventory_net              |
|     +------+------+                                             |
|     |             |                                             |
| mongo_data_multi  mongo_config_multi                             |
|     /data/db      /data/configdb                                 |
|                                                                  |
| mongo:/backups -> ./mongo/backups/multi                          |
+------------------------------------------------------------------+
```

La conexión entre servicios utiliza `mongodb:27017`, nombre DNS que
Docker Compose resuelve dentro de `inventory_net`. `127.0.0.1` desde Mongo
Express apuntaría **a su propio contenedor**, no al de MongoDB. No hay
necesidad de Supervisor ni de instalar manualmente Node.js: cada imagen
oficial ejecuta su propio proceso principal.

## 4. Alternativas de contenerización

| Criterio | A: Dockerfile + 1 contenedor | B: Compose + 2 contenedores |
|---|---|---|
| Componentes | Imagen propia: MongoDB + Mongo Express | Dos imágenes oficiales |
| Construcción | Descarga código, instala Node/Yarn y compila | Descarga imágenes ya construidas |
| Proceso principal | Tini -> Supervisor -> dos programas | Uno principal por contenedor |
| Conexión interna | `127.0.0.1:27017` | `mongodb:27017` en red bridge |
| Puertos del host | `27028` y `8082` | `27029` y `8083` |
| Volúmenes | Exclusivos de A | Exclusivos de B |
| Ventaja principal | Practicar Dockerfile, build, PID 1 y procesos | Más simple de operar y actualizar |
| Desventaja principal | Mayor imagen y mantenimiento de Node/Yarn | Coordinar dos servicios y su red |
| Diagnóstico | Logs de dos procesos mezclados | Logs y reinicio independientes |
| Actualización | Reconstruir imagen propia | Cambiar la etiqueta de cada imagen |
| Escalamiento | Componentes acoplados | Servicios separados |
| Uso indicado | Laboratorio de construcción y procesos | Desarrollo diario y bases de despliegue |

**Elección para el tutorial:** construye ambas para entender la diferencia.
Si solo necesitas MongoDB y su panel durante el desarrollo habitual, la
variante B reduce trabajo de mantenimiento. La variante A es deliberadamente
educativa: un contenedor con dos procesos **no es el patrón predeterminado**
para ejecutar servicios independientes.

### 4.1. Qué se descarga realmente en el Dockerfile de A

1. **`mongo:8.0` (Docker Hub)**: capas de la imagen base con MongoDB, `mongod`,
   `mongosh` y el `docker-entrypoint.sh` oficial. No compilamos MongoDB.
2. **APT del sistema base**: `curl`, certificados CA, `gnupg`, `git`,
   `supervisor` y `tini`. Se purgan los índices de APT tras instalarlos.
3. **NodeSource**: el script `setup_20.x` incorpora el repositorio APT que
   suministra Node.js 20 y npm. Esta combinación reproduce el build que ya
   terminaste; no debe interpretarse como selección para producción futura.
4. **Corepack desde npm**: gestor que activa la versión de Yarn declarada por
   el proyecto, evitando elegir Yarn Classic arbitrariamente.
5. **GitHub**: `git clone --depth 1 --branch release/v1.0.2` descarga el código
   de Mongo Express a `/opt/mongo-express`, incluida su configuración de Yarn,
   `package.json`, lockfile y entrada `app.js`.
6. **Registro de paquetes mediante Yarn**: `corepack yarn install` resuelve
   dependencias; `yarn build` genera recursos web; `yarn workspaces focus
   --production` conserva las dependencias de ejecución; `yarn cache clean`
   elimina la caché. El contenido del repositorio descargado **permanece**
   en la imagen; solo se borra su directorio `.git`.
7. **Archivos locales**: `COPY` incorpora únicamente
   `docker-image-scripts/supervisord.conf` y
   `docker-image-scripts/start-mongo-express.sh`.

**Por qué falló npm:** el intento inicial de `npm install
mongo-express@1.0.2` terminó con `EUNSUPPORTEDPROTOCOL` al encontrar una
referencia `patch:mongodb-query-parser...`. `patch:` es una función del
administrador de paquetes Yarn que npm no interpreta. Subir la versión de
npm no convierte automáticamente esos parches en dependencias instalables.
Por eso esta variante obtiene el repositorio y ejecuta **su propio Yarn**.

**Por qué falló el arranque después de compilar:** el script antiguo buscaba
`/opt/mongo-express/node_modules/mongo-express/app.js`, ruta propia de
una instalación distinta mediante npm. En el árbol clonado y construido,
el punto de entrada utilizado es `/opt/mongo-express/app.js`. La línea
correcta al final del script es `exec node /opt/mongo-express/app.js`.

### 4.2. Archivos comunes y configuración de entorno

Los dos Compose utilizan **las mismas variables** de autenticación, pero
puertos, proyectos y volúmenes diferentes. Los ejemplos de contraseñas son
solo marcadores: reemplázalos localmente antes de arrancar. Para simplificar
la URI del ejercicio, utiliza contraseñas alfanuméricas; los caracteres
reservados requieren codificación URL. `.env` es local y no se sube a Git.

```dotenv
# .env.example — copiar a .env y sustituir contraseñas.
# Docker Compose lee .env para interpolar ${VARIABLE} en YAML.
# Este archivo NO se añade a la imagen Docker mediante COPY.

# Credenciales de MongoDB para ambas variantes.
# Solo se crean automáticamente cuando el volumen está vacío.
MONGO_INITDB_ROOT_USERNAME=labadmin
MONGO_INITDB_ROOT_PASSWORD=REEMPLAZAR_ClaveMongo123

# Autenticación HTTP básica de Mongo Express (independiente
# de la autenticación de MongoDB).
ME_CONFIG_BASICAUTH_USERNAME=labweb
ME_CONFIG_BASICAUTH_PASSWORD=REEMPLAZAR_ClaveWeb123

# Variante A: host -> puertos internos 27017 y 8081.
MONGO_HOST_PORT=27028
MONGO_EXPRESS_HOST_PORT=8082

# Variante B: otros puertos para coexistir con A.
MONGO_MULTI_HOST_PORT=27029
MONGO_EXPRESS_MULTI_HOST_PORT=8083
```

```bash
# .gitignore — archivo de texto con reglas Git.
# Los secretos se quedan exclusivamente en cada máquina.
.env
.env.*
!.env.example

# Los backups reales no deben subirse accidentalmente.
mongo/backups/**
!mongo/backups/**/
!mongo/backups/**/.gitkeep

# Cachés y artefactos de entornos de desarrollo posteriores.
.DS_Store
node_modules/
target/
build/
.idea/
.vscode/*.log
```

```dockerignore
# .dockerignore — se aplica al contexto de build (la raíz).
# Reduce archivos enviados al demonio de Docker.
# NO ignorar docker-image-scripts/: contiene el Dockerfile
# y los dos archivos que emplean las instrucciones COPY.
.git
.env
.env.*
!.env.example
mongo/backups/
node-api/
java-core/
spring-api/
docs/
http/
**/node_modules/
**/target/
**/build/
.DS_Store
```

```bash
# Crear .env a partir de la plantilla y editar credenciales.
cp .env.example .env

# Comprobar que Git no incorporará los secretos.
git check-ignore .env
```

### 4.3. Variante A — `docker-image-scripts/Dockerfile`

Este es el Dockerfile de la compilación exitosa aportada para la lección,
con los comentarios de ruta y de instalación corregidos. **Ubicación
obligatoria:** `docker-image-scripts/Dockerfile`. El contexto de
construcción seguirá siendo la raíz del repositorio, para que `COPY
 docker-image-scripts/...` encuentre sus entradas. Durante el build, Git y
Yarn acceden a Internet; el código resultante queda incluido en la imagen.

```dockerfile

# =============================================================================
# MONGODB FASTTRACK — SECCIÓN 1
# =============================================================================
#
# ARCHIVO: docker-image-scripts/Dockerfile
#
# VARIANTE A:
# MongoDB y Mongo Express dentro de un único contenedor.
#
# COMPONENTES:
#
#   1. MongoDB Server 8.0
#   2. MongoDB Shell (mongosh)
#   3. Node.js 20
#   4. Yarn (administrador de paquetes de Mongo Express)
#   5. Mongo Express 1.0.2
#   6. Supervisor
#   7. Tini
#
# ARQUITECTURA DE PROCESOS:
#
#   Docker
#     |
#     +-- tini (PID 1)
#           |
#           +-- supervisord
#                 |
#                 +-- docker-entrypoint.sh
#                 |       |
#                 |       +-- mongod
#                 |
#                 +-- start-mongo-express.sh
#                         |
#                         +-- node app.js
#
# PUERTOS INTERNOS:
#
#   MongoDB:       27017
#   Mongo Express: 8081
#
# PUERTOS EXTERNOS:
#
#   Se configuran en compose.yaml:
#
#   MongoDB:       27028
#   Mongo Express: 8082
#
# PERSISTENCIA:
#
#   /data/db       Archivos de MongoDB
#   /data/configdb Configuración de MongoDB
#   /backups       Respaldos creados con mongodump
#
# IMPORTANTE:
# Esta imagen está destinada exclusivamente al laboratorio local.
#
# =============================================================================


# =============================================================================
# 1. IMAGEN BASE
# =============================================================================
#
# Utilizamos la imagen oficial de MongoDB 8.0.
#
# La imagen proporciona el servidor mongod y el script oficial
# docker-entrypoint.sh.
#
# Este último es importante porque realiza la inicialización
# de MongoDB y crea el usuario administrador cuando el volumen
# de datos está vacío.
#
# No instalaremos MongoDB manualmente ni modificaremos sus
# archivos binarios.
#
# La etiqueta 8.0 puede recibir actualizaciones de mantenimiento.
# Para una compilación estrictamente reproducible se debe fijar
# posteriormente un digest concreto.

FROM mongo:8.0


# =============================================================================
# 2. CONFIGURACIÓN GENERAL DE LA CONSTRUCCIÓN
# =============================================================================
#
# Evitamos que APT muestre diálogos interactivos durante
# la instalación de paquetes.
#
# Esta variable solo se necesita durante la construcción,
# por lo que utilizamos ARG en lugar de ENV.

ARG DEBIAN_FRONTEND=noninteractive


# =============================================================================
# 3. INSTALACIÓN DE DEPENDENCIAS DEL SISTEMA OPERATIVO
# =============================================================================
#
# Instalamos las herramientas necesarias para construir y ejecutar
# Mongo Express dentro de la imagen de MongoDB.
#
# curl:
#   Descargar el script de instalación de Node.js.
#
# ca-certificates:
#   Validar certificados HTTPS.
#
# gnupg:
#   Administrar las claves utilizadas por repositorios APT.
#
# git:
#   Descargar el código fuente de Mongo Express desde GitHub.
#
# supervisor:
#   Administrar simultáneamente MongoDB y Mongo Express.
#
# tini:
#   Administrar las señales y los procesos hijos del contenedor.
#
# No instalamos nodejs ni npm desde los repositorios originales
# de la distribución porque queremos controlar su versión.
#
# Instalaremos Node.js 20 en el siguiente paso.

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       ca-certificates \
       gnupg \
       git \
       supervisor \
       tini \
    && rm -rf /var/lib/apt/lists/*


# =============================================================================
# 4. INSTALACIÓN DE NODE.JS
# =============================================================================
#
# Mongo Express es una aplicación desarrollada en Node.js.
#
# Instalamos Node.js 20 utilizando el repositorio de NodeSource.
#
# Node.js 20 es una elección de compatibilidad para esta versión
# histórica de Mongo Express, no una recomendación para producción.
#
# Node.js 20 se usa para reproducir la compilación probada.
# Es una dependencia del laboratorio, no una pauta para producción.
#
# El script setup_20.x configura el repositorio APT.
#
# Después instalamos el paquete nodejs, que incluye npm.
#
# Comprobamos ambas versiones para detectar inmediatamente
# cualquier problema durante la construcción.

RUN curl -fsSL https://deb.nodesource.com/setup_20.x \
      -o /tmp/nodesource_setup.sh \
    && bash /tmp/nodesource_setup.sh \
    && apt-get install -y --no-install-recommends nodejs \
    && node --version \
    && npm --version \
    && rm -f /tmp/nodesource_setup.sh \
    && rm -rf /var/lib/apt/lists/*


# =============================================================================
# 5. INSTALACIÓN DE COREPACK
# =============================================================================
#
# PROBLEMA ENCONTRADO EN LA PRIMERA VERSIÓN DEL LABORATORIO:
#
# Al ejecutar:
#
#   npm install mongo-express@1.0.2
#
# npm devolvió:
#
#   EUNSUPPORTEDPROTOCOL
#   Unsupported URL Type "patch:"
#
# La causa es que algunas dependencias de Mongo Express utilizan
# el protocolo patch: de Yarn.
#
# npm no interpreta ese protocolo.
#
# SOLUCIÓN:
#
# Utilizar el administrador de paquetes que requiere el proyecto.
#
# Corepack permite seleccionar la versión de Yarn declarada
# en package.json mediante la propiedad packageManager.
#
# Instalamos Corepack y habilitamos sus ejecutables.
#
# --force:
#   Permite reemplazar los enlaces de gestores de paquetes
#   existentes si los hubiera.
#
# No instalamos Yarn Classic mediante npm install -g yarn,
# porque podría seleccionar una versión incompatible.

RUN npm install --global --force corepack \
    && corepack enable \
    && corepack --version


# =============================================================================
# 6. DESCARGA DEL CÓDIGO FUENTE DE MONGO EXPRESS
# =============================================================================
#
# Descargamos la versión 1.0.2 desde el repositorio oficial.
#
# Utilizamos la referencia release/v1.0.2, empleada por
# el proceso de construcción de la imagen oficial.
#
# --depth 1:
#   Descarga únicamente el historial necesario para la referencia.
#
# --branch:
#   Selecciona la referencia concreta del proyecto.
#
# El código quedará almacenado en:
#
#   /opt/mongo-express
#
# A diferencia de la primera versión del Dockerfile,
# no instalamos el paquete publicado directamente desde npm.
#
# Necesitamos los archivos del repositorio, incluidos:
#
#   package.json
#   yarn.lock
#   .yarnrc.yml
#   app.js
#   webpack.config.js, si está presente
#
# y los demás archivos necesarios para construir la aplicación.

RUN git clone \
      --depth 1 \
      --branch release/v1.0.2 \
      https://github.com/mongo-express/mongo-express.git \
      /opt/mongo-express


# =============================================================================
# 7. DIRECTORIO DE TRABAJO DE MONGO EXPRESS
# =============================================================================
#
# Las instrucciones siguientes se ejecutarán desde el
# directorio del código fuente de Mongo Express.
#
# WORKDIR crea el directorio si todavía no existe.
#
# En este caso, el directorio ya fue creado por git clone.

WORKDIR /opt/mongo-express


# =============================================================================
# 8. INSTALACIÓN DE LAS DEPENDENCIAS CON YARN
# =============================================================================
#
# Corepack seleccionará el administrador de paquetes apropiado
# a partir de la configuración del repositorio.
#
# Desactivamos las preguntas interactivas de Corepack porque
# Docker construye las imágenes sin intervención del usuario.
#
# También desactivamos la caché de compilación de V8, siguiendo
# el procedimiento utilizado en la construcción oficial.
#
# yarn install:
#   Instala las dependencias declaradas por el proyecto.
#
# yarn build:
#   Compila los recursos necesarios para la interfaz web.
#
# yarn workspaces focus --production:
#   Conserva las dependencias necesarias para ejecutar
#   la aplicación, excluyendo las de desarrollo.
#
# yarn cache clean:
#   Elimina la caché de paquetes descargados.
#
# IMPORTANTE:
# No sustituir yarn install por npm install.
#
# El repositorio utiliza características específicas de Yarn,
# incluido el protocolo patch: que provocó el error inicial.

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN set -eux \
    && export DISABLE_V8_COMPILE_CACHE=1 \
    && corepack yarn --version \
    && corepack yarn install \
    && corepack yarn build \
    && corepack yarn workspaces focus --production \
    && corepack yarn cache clean \
    && rm -rf /opt/mongo-express/.git


# =============================================================================
# 9. CONFIGURACIÓN DE MONGO EXPRESS
# =============================================================================
#
# Mongo Express obtiene su configuración de las variables
# de entorno proporcionadas por Docker Compose.
#
# No almacenamos usuarios ni contraseñas en la imagen.
#
# ME_CONFIG_MONGODB_URL:
#   Se definirá en compose.yaml.
#
# ME_CONFIG_BASICAUTH_USERNAME:
#   Usuario de acceso a la interfaz web.
#
# ME_CONFIG_BASICAUTH_PASSWORD:
#   Contraseña de acceso a la interfaz web.
#
# Mongo Express y MongoDB comparten el mismo contenedor.
# Por eso Mongo Express se conectará a:
#
#   127.0.0.1:27017
#
# El script de arranque comprobará que MongoDB esté disponible
# antes de iniciar la aplicación web.


# =============================================================================
# 10. INSTALACIÓN DE LA CONFIGURACIÓN DE SUPERVISOR
# =============================================================================
#
# Copiamos el archivo supervisord.conf creado en esta sección.
#
# Supervisor administra los dos procesos principales:
#
#   mongodb
#   mongo-express
#
# El archivo también configura:
#
#   - Orden de arranque.
#   - Reinicio automático.
#   - Gestión de señales.
#   - Salida de registros hacia Docker.
#
# No copiamos todo el repositorio del laboratorio dentro
# de la imagen; únicamente los archivos necesarios.

COPY docker-image-scripts/supervisord.conf /etc/supervisor/conf.d/lab.conf


# =============================================================================
# 11. SCRIPT DE ARRANQUE DE MONGO EXPRESS
# =============================================================================
#
# Copiamos el script que espera a que MongoDB esté disponible.
#
# Secuencia:
#
#   1. Supervisor inicia MongoDB.
#   2. Supervisor inicia este script.
#   3. El script comprueba la conexión mediante mongosh.
#   4. Cuando MongoDB responde, inicia Mongo Express.
#
# El script debe terminar ejecutando:
#
#   exec node /opt/mongo-express/app.js
#
# ATENCIÓN:
# La ruta anterior corresponde a la instalación desde
# el código fuente.
#
# En el Dockerfile anterior utilizábamos:
#
#   /opt/mongo-express/node_modules/mongo-express/app.js
#
# Esa ruta pertenecía a la instalación mediante npm
# y ya no corresponde a esta imagen.

COPY docker-image-scripts/start-mongo-express.sh /usr/local/bin/start-mongo-express.sh


# Concedemos permisos de ejecución al script.
#
# Sin estos permisos, Supervisor no podrá ejecutarlo
# directamente.

RUN chmod 755 /usr/local/bin/start-mongo-express.sh


# =============================================================================
# 12. DIRECTORIOS DE PERSISTENCIA
# =============================================================================
#
# La imagen oficial de MongoDB utiliza:
#
#   /data/db
#   /data/configdb
#
# No es necesario volver a declarar VOLUME.
#
# Docker Compose montará los volúmenes:
#
#   mongo_data:/data/db
#   mongo_config:/data/configdb
#
# Los respaldos se guardarán mediante un bind mount:
#
#   ./mongo/backups/single:/backups
#
# No utilizamos la capa escribible del contenedor
# como mecanismo principal de persistencia.


# =============================================================================
# 13. PUERTOS INTERNOS
# =============================================================================
#
# MongoDB escucha internamente en el puerto 27017.
#
# Mongo Express escucha internamente en el puerto 8081.
#
# EXPOSE documenta estos puertos, pero no los publica
# automáticamente en el host.
#
# La publicación se configura mediante Docker Compose:
#
#   127.0.0.1:27028:27017
#   127.0.0.1:8082:8081
#
# No modificamos los puertos internos porque no existe
# ningún conflicto entre ellos dentro del contenedor.

EXPOSE 27017 8081


# =============================================================================
# 14. DIRECTORIO DE TRABAJO FINAL
# =============================================================================
#
# Establecemos el directorio raíz como directorio general
# para el proceso principal del contenedor.
#
# Supervisor configurará individualmente el directorio
# de trabajo de cada programa.

WORKDIR /


# =============================================================================
# 15. ENTRYPOINT: TINI
# =============================================================================
#
# La imagen oficial de MongoDB tiene su propio ENTRYPOINT.
#
# Lo sustituimos porque necesitamos iniciar Supervisor
# en lugar de ejecutar directamente MongoDB.
#
# Sin embargo, Supervisor invocará explícitamente el
# entrypoint oficial de MongoDB.
#
# Tini será el proceso PID 1 del contenedor.
#
# Sus responsabilidades incluyen:
#
#   - Reenviar las señales enviadas por Docker.
#   - Recoger los procesos hijos terminados.
#   - Facilitar el apagado ordenado.
#
# La opción -g permite enviar señales al grupo de procesos.
#
# El argumento -- indica el final de las opciones de Tini.

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]


# =============================================================================
# 16. COMANDO PRINCIPAL: SUPERVISOR
# =============================================================================
#
# Supervisor administra MongoDB y Mongo Express.
#
# -n:
#   Ejecuta Supervisor en primer plano.
#
# -c:
#   Selecciona nuestro archivo de configuración.
#
# Docker mantendrá el contenedor activo mientras
# Supervisor continúe ejecutándose.
#
# Si Supervisor termina, Docker aplicará la política
# restart definida en compose.yaml.

CMD ["/usr/bin/supervisord", "-n", \
     "-c", "/etc/supervisor/conf.d/lab.conf"]


# =============================================================================
# FIN DEL DOCKERFILE
# =============================================================================
```

### 4.4. Variante A — `docker-image-scripts/supervisord.conf`

Supervisor llama expresamente al `docker-entrypoint.sh` original de la
imagen de MongoDB. Esto conserva la creación del administrador al primer
arranque; reemplazarlo por `mongod` directamente perdería esa fase de
inicialización. Se preserva la configuración aportada y se utiliza la
salida estándar para que `docker compose logs` vea los dos programas.

> Nota sobre `supervisorctl`: este archivo no define la interfaz RPC ni
> el socket de control de Supervisor. Por eso, la verificación de procesos
> de esta lección utiliza `ps` y registros; **no** presupone que funcione
> `supervisorctl status`.

```ini

; =============================================================================
; mongodb-fasttrack-tutorial — Sección 1
;
; Archivo: supervisord.conf
;
; Objetivo:
;   Administrar MongoDB y Mongo Express dentro de un único contenedor.
;
; Jerarquía de procesos:
;
;   tini (PID 1)
;     |
;     +-- supervisord
;           |
;           +-- mongodb
;           |     |
;           |     +-- docker-entrypoint.sh
;           |             |
;           |             +-- mongod
;           |
;           +-- mongo-express
;                 |
;                 +-- start-mongo-express.sh
;                         |
;                         +-- node
;
; Supervisor inicia los programas según su prioridad.
; El script de Mongo Express comprueba por separado que MongoDB
; esté listo antes de iniciar la aplicación web.
; =============================================================================


; =============================================================================
; 1. CONFIGURACIÓN GENERAL DE SUPERVISOR
; =============================================================================

[supervisord]

; Ejecutar Supervisor en primer plano.
;
; Docker necesita que el proceso principal del contenedor
; permanezca activo.
;
; Si Supervisor se ejecutara como demonio, el proceso principal
; podría terminar y Docker detendría el contenedor.

nodaemon=true


; Desactivar el archivo de registro propio de Supervisor.
;
; Los registros de los programas se enviarán a stdout y stderr,
; para que puedan consultarse mediante docker compose logs.

logfile=/dev/null

; No intentar rotar el registro principal.
; /dev/null no es un archivo de registro convencional.

logfile_maxbytes=0


; =============================================================================
; 2. PROGRAMA MONGODB
; =============================================================================

[program:mongodb]

; Utilizar el entrypoint oficial de la imagen MongoDB.
;
; No ejecutamos mongod directamente porque necesitamos
; conservar la inicialización que proporciona la imagen oficial:
;
;   - Lectura de las variables MONGO_INITDB_ROOT_USERNAME
;     y MONGO_INITDB_ROOT_PASSWORD.
;
;   - Creación del usuario administrador en el primer arranque.
;
;   - Ejecución de los scripts de inicialización, si existen.
;
;   - Arranque del servidor MongoDB.
;
; El entrypoint termina sustituyéndose por mongod cuando
; finaliza la inicialización.

command=/usr/local/bin/docker-entrypoint.sh mongod


; Directorio de trabajo del proceso.

directory=/


; Prioridad de arranque.
;
; Los programas con menor número de prioridad arrancan primero.
; MongoDB debe comenzar antes que Mongo Express.
;
; IMPORTANTE:
; La prioridad no garantiza que MongoDB ya acepte conexiones.
; Esa comprobación la realiza start-mongo-express.sh.

priority=10


; Arrancar MongoDB automáticamente cuando inicia Supervisor.

autostart=true


; Reiniciar MongoDB si termina inesperadamente.
;
; Esto no sustituye a una política de recuperación completa,
; pero permite reiniciar el proceso ante determinados fallos.

autorestart=true


; Considerar que MongoDB ha arrancado correctamente cuando
; permanece ejecutándose durante al menos cinco segundos.
;
; Esto no equivale a una comprobación de salud de la base
; de datos ni garantiza que pueda aceptar conexiones.

startsecs=5


; Enviar SIGTERM al detener el programa.
;
; Permite que MongoDB inicie su proceso de apagado ordenado.

stopsignal=TERM


; Tiempo máximo de espera para que MongoDB termine.
;
; Si no termina dentro de este intervalo, Supervisor puede
; recurrir a SIGKILL.
;
; Para el laboratorio utilizamos 60 segundos.

stopwaitsecs=60


; Enviar las señales de parada a todo el grupo de procesos.
;
; Resulta útil si existen procesos hijos durante
; la inicialización de MongoDB.

stopasgroup=true

killasgroup=true


; Enviar la salida estándar de MongoDB a Docker.
;
; /dev/fd/1 representa stdout.
; /dev/fd/2 representa stderr.

stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0

stderr_logfile=/dev/fd/2
stderr_logfile_maxbytes=0


; =============================================================================
; 3. PROGRAMA MONGO EXPRESS
; =============================================================================

[program:mongo-express]

; Ejecutar el script de inicialización de Mongo Express.
;
; Este script:
;
;   1. Verifica las variables de entorno.
;   2. Espera a que MongoDB acepte conexiones autenticadas.
;   3. Ejecuta Mongo Express mediante Node.js.
;
; No ejecutamos directamente Node.js porque MongoDB puede
; necesitar varios segundos para completar su inicialización.

command=/usr/local/bin/start-mongo-express.sh


; Directorio de trabajo de Mongo Express.

directory=/opt/mongo-express


; Mongo Express comienza después de iniciar MongoDB.
;
; Recordatorio:
; priority=20 establece el orden de arranque, pero no
; espera a que MongoDB esté completamente disponible.

priority=20


; Arrancar automáticamente con Supervisor.

autostart=true


; Reiniciar Mongo Express si termina inesperadamente.

autorestart=true


; Considerar que el proceso ha arrancado correctamente
; después de permanecer activo durante cinco segundos.
;
; El script de espera también cuenta como proceso activo,
; por lo que esta opción no verifica la disponibilidad HTTP.

startsecs=5


; Utilizar SIGTERM para solicitar una terminación ordenada.

stopsignal=TERM


; Esperar hasta 20 segundos antes de forzar la terminación.

stopwaitsecs=20


; Enviar las señales a todo el grupo de procesos.

stopasgroup=true

killasgroup=true


; Redirigir los registros a la salida de Docker.
;
; Así podemos observar los mensajes del script de espera,
; el arranque de Node.js y los errores de Mongo Express.

stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0

stderr_logfile=/dev/fd/2
stderr_logfile_maxbytes=0
```

### 4.5. Variante A — `docker-image-scripts/start-mongo-express.sh`

El script comprueba credenciales y espera al `ping` autenticado antes de
reemplazarse por Node.js mediante `exec`. Se corrige el comentario obsoleto
sobre npm. Atención: una contraseña incorrecta o un servidor inaccesible
mantendrán el bucle de espera indefinidamente; en ese caso revisa `.env`,
los volúmenes existentes y los registros. Las credenciales usadas por
`mongosh` en argumentos de proceso son aceptables únicamente para este
laboratorio local.

```bash
#!/usr/bin/env bash

# =============================================================================
# mongodb-fasttrack-tutorial — Sección 1
#
# Archivo: start-mongo-express.sh
#
# Objetivo:
#   Esperar a que MongoDB esté disponible y autenticado antes de
#   iniciar Mongo Express.
#
# Arquitectura:
#   Un único contenedor ejecuta MongoDB y Mongo Express.
#   Supervisor administra los dos procesos.
#
# Secuencia:
#   1. Comprobar las variables de entorno necesarias.
#   2. Intentar conectarse a MongoDB mediante mongosh.
#   3. Repetir la comprobación mientras MongoDB no esté listo.
#   4. Iniciar Mongo Express cuando la conexión funcione.
#
# Las credenciales se reciben desde compose.yaml, que las obtiene
# del archivo .env. No se incluyen contraseñas en este script.
# =============================================================================


# =============================================================================
# 1. CONFIGURACIÓN DE BASH
# =============================================================================

# -e:
#   Termina el script si un comando falla fuera de los contextos
#   donde Bash permite controlar explícitamente el error.
#
# -u:
#   Considera un error utilizar una variable no definida.
#
# -o pipefail:
#   Una tubería falla si cualquiera de sus comandos falla.
#
# Esto facilita detectar errores de configuración.

set -euo pipefail


# =============================================================================
# 2. VARIABLES DE ENTORNO
# =============================================================================

# Las variables se reciben del entorno del contenedor.
#
# El operador :? obliga a que la variable exista y no esté vacía.
# Si falta, Bash termina mostrando el mensaje correspondiente.

: "${MONGO_INITDB_ROOT_USERNAME:?Falta el usuario de MongoDB}"
: "${MONGO_INITDB_ROOT_PASSWORD:?Falta la contraseña de MongoDB}"
: "${ME_CONFIG_MONGODB_URL:?Falta la URI de Mongo Express}"


# =============================================================================
# 3. PARÁMETROS DE CONEXIÓN
# =============================================================================

# Ambos procesos comparten la misma red del contenedor.
# Por eso utilizamos 127.0.0.1 y el puerto interno de MongoDB.
#
# No utilizamos el puerto 27028:
# ese puerto pertenece al host y se configura en Docker Compose.

MONGO_HOST="127.0.0.1"
MONGO_PORT="27017"

# Tiempo de espera entre intentos, expresado en segundos.

RETRY_INTERVAL=2


# =============================================================================
# 4. ESPERAR A QUE MONGODB ESTÉ DISPONIBLE
# =============================================================================

echo "[mongo-express] Esperando a MongoDB..."

# until ejecuta repetidamente el comando hasta que devuelve
# un código de salida exitoso (0).
#
# mongosh:
#   Cliente de línea de comandos de MongoDB.
#
# --quiet:
#   Reduce los mensajes informativos.
#
# --authenticationDatabase admin:
#   Indica dónde se autentica el usuario administrador.
#
# --eval:
#   Ejecuta una expresión JavaScript y termina.
#
# ping:
#   Comprueba que MongoDB puede responder a comandos.
#
# grep -qx 1:
#   Verifica que el resultado de ping sea exactamente 1.
#
# La contraseña se pasa como argumento al proceso mongosh.
# Esto es suficiente para un laboratorio local, pero en
# entornos compartidos conviene utilizar mecanismos de
# gestión de secretos que eviten exponer credenciales.

until mongosh \
    --quiet \
    --host "$MONGO_HOST" \
    --port "$MONGO_PORT" \
    --username "$MONGO_INITDB_ROOT_USERNAME" \
    --password "$MONGO_INITDB_ROOT_PASSWORD" \
    --authenticationDatabase admin \
    --eval 'db.adminCommand({ ping: 1 }).ok' \
    2>/dev/null | grep -qx 1
do
    # MongoDB todavía no está disponible o la autenticación
    # no ha terminado de inicializarse.
    #
    # Esperamos antes de realizar un nuevo intento.

    echo "[mongo-express] MongoDB todavía no está listo."

    sleep "$RETRY_INTERVAL"
done


# =============================================================================
# 5. INICIAR MONGO EXPRESS
# =============================================================================

echo "[mongo-express] MongoDB disponible."
echo "[mongo-express] Iniciando la interfaz web..."

# Mongo Express fue descargado con Git y compilado con Yarn.
# La aplicación se ejecuta desde /opt/mongo-express/app.js.
# No usar la antigua ruta node_modules/mongo-express/app.js.
#
# exec:
#   Sustituye este proceso Bash por el proceso Node.js.
#
# De esta manera, Supervisor administra directamente Node.js
# en lugar de administrar un shell que mantiene otro proceso hijo.
#
# Esto también facilita el manejo de señales al detener
# el contenedor.

exec node /opt/mongo-express/app.js
```

### 4.6. Variante A — `compose-a.yaml` (completo y comentado)

El Compose que entregaste tenía `build.dockerfile: Dockerfile`; ahora apunta
a `docker-image-scripts/Dockerfile`. Se conserva el nombre de imagen y el
de contenedor. El bind mount de respaldo se separa como
`./mongo/backups/single` para que no mezclemos copias A/B. Se añade un
healthcheck autenticado; supervisar MongoDB no equivale a comprobar HTTP,
por lo que el panel se verifica también mediante `curl`.

Los comandos de ejecución usan explícitamente `-f compose-a.yaml` para evitar
ambigüedades entre las dos variantes.

**Cambios importantes en esta versión (vs. composición anterior):**

1. **`VCAP_APP_HOST: "0.0.0.0"`** (línea ~49): Mongo Express por defecto 
   intenta escuchar en `localhost`, que Node.js puede interpretar como 
   únicamente IPv6 (`::1`). Configurando `0.0.0.0`, Mongo Express escucha 
   en todas las interfaces (IPv4 e IPv6), permitiendo que funcione correctamente 
   en `127.0.0.1:8082` desde tu navegador.

2. **`ME_CONFIG_SITE_SESSIONSECRET`** (línea ~50): Express-session requiere 
   este secreto para gestionar sesiones seguras. Sin él, Mongo Express devuelve 
   errores 500 al intento de conexión. El valor `"mongo-express-fasttrack-secret"` 
   es suficiente para laboratorio; en producción usa un valor más largo y aleatorio.

Estas dos variables son **críticas** para que Mongo Express funcione correctamente 
en un contenedor Docker con un proceso Node.js que necesita escuchar en una 
dirección accesible desde el host.

```yaml
# =============================================================================
# mongodb-fasttrack-tutorial — Variante A (un único contenedor)
# =============================================================================
# Ubicación: compose-a.yaml
# Ejecutar desde la raíz:
#   docker compose -f compose-a.yaml config --quiet
#   docker compose -f compose-a.yaml up -d --build
#
# build.context: . significa que COPY opera desde la raíz del repositorio.
# build.dockerfile: el Dockerfile se guarda junto con sus scripts auxiliares.
# Las variables ${...:?...} obligan a definir credenciales y puertos en .env.
# =============================================================================
name: mongodb-fasttrack-tutorial

services:
  mongodb:
    # Construimos la imagen propia con MongoDB y Mongo Express.
    build:
      context: .
      dockerfile: docker-image-scripts/Dockerfile

    # Nombre legible de la imagen que Compose generará.
    image: mongo-db-and-express-fasttrack:1.0

    # Nombre del contenedor. No debe repetirse en la variante B.
    container_name: mongodb-fasttrack-tutorial

    # Recuperación tras reinicios inesperados (salvo parada explícita).
    restart: unless-stopped

    # Solo se publica en la interfaz loopback del host.
    # Izquierda = host; derecha = puerto INTERNO del contenedor.
    ports:
      - "127.0.0.1:${MONGO_HOST_PORT:?Definir puerto Mongo A}:27017"
      - "127.0.0.1:${MONGO_EXPRESS_HOST_PORT:?Definir puerto web A}:8081"

    # Usuarios iniciales de MongoDB y configuración de Mongo Express.
    # Los usuarios root NO se recrean al arrancar un volumen ya inicializado.
    # La URI contiene credenciales: no publiques 'docker compose config'.
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME:?Usuario requerido}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_INITDB_ROOT_PASSWORD:?Clave requerida}

      # En A Mongo Express comparte red con MongoDB: localhost es correcto.
      # Si la clave incluye @, :, /, ?, #, etc., codificarla en la URI.
      ME_CONFIG_MONGODB_URL: "mongodb://${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@127.0.0.1:27017/?authSource=admin"
      ME_CONFIG_BASICAUTH_USERNAME: ${ME_CONFIG_BASICAUTH_USERNAME:?Usuario web requerido}
      ME_CONFIG_BASICAUTH_PASSWORD: ${ME_CONFIG_BASICAUTH_PASSWORD:?Clave web requerida}
      ME_CONFIG_SITE_BASEURL: "/"
      
      # VCAP_APP_HOST: configura la dirección de escucha de Mongo Express.
      # Por defecto, Mongo Express usa 'localhost', que Node.js puede
      # interpretar como IPv6 (::1) exclusivamente, impidiendo conexiones
      # desde 127.0.0.1 en el host.
      #
      # Valores permitidos:
      #   - "0.0.0.0": escucha en todas las interfaces (IPv4 e IPv6)
      #   - "127.0.0.1": escucha solo en IPv4 loopback (alternativa)
      #   - "localhost": comportamiento por defecto (problemático en Docker)
      #
      # Se usa "0.0.0.0" para permitir conexiones desde 127.0.0.1:8082
      # del navegador del host.
      VCAP_APP_HOST: "0.0.0.0"
      
      # ME_CONFIG_SITE_SESSIONSECRET: secreto para express-session.
      # Express-session mantiene datos de sesión (login, cookies, etc.).
      # Sin este secreto, Mongo Express devuelve error 500 al intento
      # de acceso. En desarrollo/laboratorio, este valor es suficiente.
      #
      # IMPORTANTE: en producción, reemplazar con un valor largo,
      # aleatorio y seguro (mínimo 32 caracteres, preferiblemente base64).
      #
      # Ejemplo seguro:
      #   ME_CONFIG_SITE_SESSIONSECRET: "${MONGO_EXPRESS_SESSION_SECRET}"
      # ...donde MONGO_EXPRESS_SESSION_SECRET se define en .env como:
      #   MONGO_EXPRESS_SESSION_SECRET=aXf9kL2pQ4mN7vB5xZ8wA1cD3eR6tY9u
      ME_CONFIG_SITE_SESSIONSECRET: "mongo-express-fasttrack-secret"

    # Volúmenes con nombre: datos. Bind mount: respaldos inspeccionables.
    # Los datos sobreviven a 'docker compose down' SIN '-v'.
    volumes:
      - mongo_data:/data/db
      - mongo_config:/data/configdb
      - ./mongo/backups/single:/backups
      # Los scripts del repositorio se leen dentro del contenedor.
      # :ro evita que un proceso del contenedor los modifique.
      - ./mongo/scripts:/workspace/mongo/scripts:ro

    # Comprueba MongoDB de forma autenticada dentro del contenedor.
    # '$$' evita que Compose sustituya las variables antes de la ejecución.
    # No comprueba que la interfaz web esté disponible; usar curl aparte.
    healthcheck:
      test:
        - CMD-SHELL
        - >
          mongosh --quiet --host 127.0.0.1 --port 27017
          --username "$$MONGO_INITDB_ROOT_USERNAME"
          --password "$$MONGO_INITDB_ROOT_PASSWORD"
          --authenticationDatabase admin
          --eval "db.adminCommand({ ping: 1 }).ok"
          | grep -qx 1
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

# Recursos creados por este proyecto de Compose.
volumes:
  mongo_data:
  mongo_config:
```

### 4.7. Variante B — `compose-b.yaml` (completo y comentado)

Aquí **no hay Dockerfile**. Compose descarga `mongo:8.0` y
`mongo-express:1.0.2` del registro de imágenes. El servicio `mongodb` tendrá
un healthcheck; `mongo-express` esperará a que esté saludable, aunque
`depends_on` no garantiza que cualquier operación posterior vaya a tener
éxito. En el caso de la variante B la conexión es `mongodb:27017`.

Los comandos de ejecución usan explícitamente `-f compose-b.yaml` para evitar
ambigüedades entre las dos variantes.

**Cambios importantes en esta versión (vs. composición anterior):**

1. **`VCAP_APP_HOST: "0.0.0.0"`** (sección mongo-express): Mismo motivo 
   que en Variante A. Mongo Express debe escuchar en todas las interfaces 
   para ser accesible desde `127.0.0.1:8083` en el navegador del host. 
   Sin este cambio, solo escucharía en IPv6 y devolvería `ERR_EMPTY_RESPONSE`.

2. **`ME_CONFIG_SITE_SESSIONSECRET`** (sección mongo-express): Como en A, 
   Express-session requiere este secreto. La imagen `mongo-express:1.0.2` 
   oficial también necesita esta configuración para funcionar.

Ambas variables se heredan de `config.default.js` que viene con la imagen 
oficial de mongo-express. Este archivo busca `VCAP_APP_HOST` y 
`ME_CONFIG_SITE_SESSIONSECRET` en el entorno del contenedor.

**Importante:** esta alternativa se propone como configuración reproducible,
pero no fue una de las cuatro piezas aportadas como ya probadas. Ejecútala y
revisa los registros antes de darla por validada en tu máquina.

```yaml
# =============================================================================
# mongodb-fasttrack-tutorial — Variante B (dos imágenes, dos contenedores)
# =============================================================================
# Ubicación: compose-b.yaml
# No se construye ninguna imagen propia. Docker Compose descarga dos imágenes
# oficiales independientes; cada servicio tiene su propio proceso principal.
# Se usan proyecto, puertos, volúmenes y directorio de respaldo exclusivos.
# =============================================================================
name: mongodb-fasttrack-multi

services:
  mongodb:
    # Imagen oficial. Mantener explícita la misma línea de MongoDB que A.
    image: mongo:8.0
    container_name: mongodb-fasttrack-multi
    restart: unless-stopped

    # El puerto 27017 interno se publica como 27029 en el host.
    # Entre contenedores se usa el puerto INTERNO, no 27029.
    ports:
      - "127.0.0.1:${MONGO_MULTI_HOST_PORT:?Definir puerto Mongo B}:27017"

    # La imagen oficial crea el usuario administrador en un volumen vacío.
    # Si ya existe el volumen, cambiar .env NO cambia la contraseña guardada.
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME:?Usuario requerido}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_INITDB_ROOT_PASSWORD:?Clave requerida}

    # Persistencia independiente de la variante A.
    volumes:
      - mongo_data_multi:/data/db
      - mongo_config_multi:/data/configdb
      - ./mongo/backups/multi:/backups
      # Igual que en A: scripts locales accesibles mediante --file.
      - ./mongo/scripts:/workspace/mongo/scripts:ro

    # Red bridge con DNS interno: el otro contenedor usa 'mongodb:27017'.
    networks:
      - inventory_net

    # Comprobación autenticada del servidor, no solo del proceso mongod.
    healthcheck:
      test:
        - CMD-SHELL
        - >
          mongosh --quiet --host 127.0.0.1 --port 27017
          --username "$$MONGO_INITDB_ROOT_USERNAME"
          --password "$$MONGO_INITDB_ROOT_PASSWORD"
          --authenticationDatabase admin
          --eval "db.adminCommand({ ping: 1 }).ok"
          | grep -qx 1
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  mongo-express:
    # Imagen oficial ya construida: no necesita Node ni Yarn en nuestro host.
    image: mongo-express:1.0.2
    container_name: mongo-express-fasttrack-multi
    restart: unless-stopped

    # Espera a que MongoDB haya superado el healthcheck inicial.
    depends_on:
      mongodb:
        condition: service_healthy

    # Puerto HTTP interno 8081 -> 8083 en el host, solo loopback.
    ports:
      - "127.0.0.1:${MONGO_EXPRESS_MULTI_HOST_PORT:?Definir puerto web B}:8081"

    # Distinto de A: '127.0.0.1' aquí sería el propio Mongo Express.
    # Docker Compose resuelve 'mongodb' dentro de inventory_net.
    # Las contraseñas con caracteres reservados requieren URL encoding.
    environment:
      ME_CONFIG_MONGODB_URL: "mongodb://${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@mongodb:27017/?authSource=admin"
      ME_CONFIG_BASICAUTH_USERNAME: ${ME_CONFIG_BASICAUTH_USERNAME:?Usuario web requerido}
      ME_CONFIG_BASICAUTH_PASSWORD: ${ME_CONFIG_BASICAUTH_PASSWORD:?Clave web requerida}
      ME_CONFIG_SITE_BASEURL: "/"
      
      # VCAP_APP_HOST: configura la dirección de escucha de Mongo Express.
      # Ver detalle en sección 4.6 (Variante A).
      # En resumen: "0.0.0.0" permite que Mongo Express escuche en todas
      # las interfaces, incluyendo 127.0.0.1 (IPv4 loopback) que es donde
      # se conectará desde el navegador del host en 127.0.0.1:8083.
      VCAP_APP_HOST: "0.0.0.0"
      
      # ME_CONFIG_SITE_SESSIONSECRET: secreto para express-session.
      # Ver detalle en sección 4.6 (Variante A).
      # La imagen oficial mongo-express:1.0.2 también lo requiere para
      # gestionar sesiones de usuario correctamente.
      ME_CONFIG_SITE_SESSIONSECRET: "mongo-express-fasttrack-secret"

    # Ambos contenedores deben pertenecer a la misma red lógica.
    networks:
      - inventory_net

# La red privada es creada y administrada por este proyecto de Compose.
networks:
  inventory_net:
    driver: bridge

# Volúmenes propios: NO mezclar archivos de dos instancias mongod.
volumes:
  mongo_data_multi:
  mongo_config_multi:
```

### 4.7.1. Configuración de Mongo Express: variables de entorno críticas (IMPORTANTE)

**Problema identificado y solucionado en esta edición:**

Cuando Mongo Express se ejecuta sin las dos variables siguientes, puede ocurrir:

1. **`ERR_EMPTY_RESPONSE` en el navegador** (127.0.0.1:8082 o 127.0.0.1:8083)
   - Síntoma: "This page isn't working. 127.0.0.1 didn't send any data."
   - Causa: Mongo Express escucha en IPv6 `::1` por defecto, no en IPv4 `127.0.0.1`
   - Solución: `VCAP_APP_HOST: "0.0.0.0"`

2. **HTTP 500 con error `secret option required for sessions`**
   - Síntoma: Página de error cuando Express-session intenta crear sesiones
   - Causa: Express-session necesita un secreto configurado para firmar cookies
   - Solución: `ME_CONFIG_SITE_SESSIONSECRET: "..."`

#### ¿Por qué ocurren estos problemas?

**Problema 1: VCAP_APP_HOST**

El archivo `config.default.js` de Mongo Express contiene:

```javascript
host: process.env.VCAP_APP_HOST || 'localhost',
```

Cuando `VCAP_APP_HOST` no está definida, Express usa `'localhost'`. Node.js 
interpreta `'localhost'` de una forma dependiente de la configuración del 
sistema operativo y la versión de Node. En muchos entornos Docker, 
`'localhost'` se resuelve **únicamente a IPv6 (::1)**, no a IPv4 (127.0.0.1).

Desde el navegador del host, cuando intentas acceder a `http://127.0.0.1:8082`, 
estás usando IPv4. Si Mongo Express solo escucha en `::1` (IPv6), la conexión 
es rechazada, generando `ERR_EMPTY_RESPONSE`.

**Solución:** Fijar `VCAP_APP_HOST: "0.0.0.0"` hace que Node.js escuche en 
**todas las interfaces** (tanto IPv4 como IPv6), permitiendo conexiones desde 
`127.0.0.1` (IPv4) del host.

```bash
# Prueba dentro del contenedor (antes del arreglo):
# node /opt/mongo-express/app.js
# 
# Error:
# Address http://localhost:8081 already in use!
# Listening on [::1]:8081
#
# El proceso escucha en IPv6 solamente.
```

**Problema 2: ME_CONFIG_SITE_SESSIONSECRET**

El archivo `lib/router.js` de Mongo Express contiene:

```javascript
app.use(session({
  secret: config.site.sessionSecret,
  ...
}));
```

Express-session requiere un `secret` para firmar las cookies de sesión. Si no 
está configurado, devuelve el error:

```
Error: secret option required for sessions
at session (...express-session/index.js:200:12)
```

Este error ocurre **después** de que Mongo Express logra escuchar en el puerto 
(es decir, si ya arreglaste el problema 1).

**Solución:** Definir `ME_CONFIG_SITE_SESSIONSECRET` en las variables de 
entorno. Mongo Express leerá esta variable en `config.default.js`:

```javascript
sessionSecret: process.env.ME_CONFIG_SITE_SESSIONSECRET,
```

#### ¿Necesita cambios el Dockerfile de la Variante A?

**Respuesta: NO.**

El Dockerfile **no requiere cambios**. Las dos variables se pasan en tiempo 
de ejecución (via Docker Compose y `.env`), no en tiempo de construcción. 
El Dockerfile ya contiene todo lo necesario:

1. ✓ Descarga Mongo Express correctamente desde Git
2. ✓ Compila con Yarn (`yarn build` genera `build-assets.json`)
3. ✓ Expone el puerto interno 8081
4. ✓ Establece el directorio de trabajo correcto

El archivo de configuración `config.default.js` **dentro de la imagen** ya 
busca estas variables de entorno. Solo necesitamos que Docker Compose las 
inyecte en el contenedor al ejecutarse.

**Flujo:**

```
Dockerfile (durante build):
  - Descarga y compila Mongo Express ✓
  - El código dentro incluye config.default.js que busca env vars
  
compose.yaml (durante run):
  - Define VCAP_APP_HOST y ME_CONFIG_SITE_SESSIONSECRET
  - Docker Compose inyecta estas variables al contenedor
  - El proceso Node.js de Mongo Express lee las variables
  - Expressa escucha correctamente en 0.0.0.0 con sesión configurada ✓
```

#### Referencias de variables de Mongo Express

Tabla completa de variables que `config.default.js` busca en el entorno:

| Variable | Búsqueda en config.default.js | Función | Valor por defecto | Crítica |
|---|---|---|---|---|
| `VCAP_APP_HOST` | `site.host` | Dirección de escucha | `'localhost'` | ✓ Sí |
| `PORT` | `site.port` | Puerto HTTP interno | `8081` | No |
| `ME_CONFIG_SITE_BASEURL` | `site.baseUrl` | Ruta base de la URL | `'/'` | No |
| `ME_CONFIG_SITE_SESSIONSECRET` | `site.sessionSecret` | Secreto para express-session | `undefined` | ✓ Sí |
| `ME_CONFIG_BASICAUTH_USERNAME` | `site.usedAuth`, usuario | Login HTTP básico | `undefined` | No |
| `ME_CONFIG_BASICAUTH_PASSWORD` | `site.usedAuth`, contraseña | Login HTTP básico | `undefined` | No |
| `ME_CONFIG_MONGODB_URL` | `connectionString` | URL de conexión a MongoDB | `undefined` | ✓ Sí |

Las marcadas como "Crítica: ✓ Sí" causarán errores visibles si faltan.

#### Cómo verificar que está funcionando

Dentro del contenedor:

```bash
# Conectar al contenedor de A
docker compose -f compose-a.yaml exec mongodb bash

# Ver qué variables está usando Mongo Express
ps aux | grep 'node.*app.js'

# Si Mongo Express se está ejecutando, estas dos variables se leyeron
# correctamente. Verifica que el proceso está escuchando:
netstat -tlnp 2>/dev/null | grep 8081

# Salida esperada:
# tcp  0  0 0.0.0.0:8081  0.0.0.0:*  LISTEN  <pid>/node
```

Desde el host:

```bash
# Verificar que la interfaz está disponible
curl -I http://127.0.0.1:8082

# Salida esperada (con sesión funcionando):
# HTTP/1.1 200 OK
# Set-Cookie: mongo-express=<token>; Path=/; HttpOnly
```

---

## 5. Laboratorio guiado: compilar, ejecutar y romper

### 5.1. Validación previa (ambas variantes)

Empieza en la raíz y confirma la ubicación de los archivos. Comprueba la
configuración sin imprimirla en capturas ni tickets porque `config` puede
mostrar credenciales; `--quiet` evita mostrarlas.

```bash
# Revisar los cuatro archivos clave y sus ubicaciones.
ls -l docker-image-scripts/
ls -l compose-a.yaml compose-b.yaml .env

# Verificar que Dockerfile COPIA desde docker-image-scripts/.
grep -n '^COPY ' docker-image-scripts/Dockerfile

# Confirmar que el script EJECUTA app.js desde el árbol clonado.
grep -n '^exec node ' \
  docker-image-scripts/start-mongo-express.sh

# Verificar sintaxis de Compose sin volcar credenciales.
docker compose -f compose-a.yaml config --quiet
docker compose -f compose-b.yaml config --quiet
```

### 5.2. Ejecutar variante A

`docker build .` construye pero, sin `-t`, puede dejar una imagen sin etiqueta.
Preferimos `docker compose build`, que aplica el nombre declarado en
`image:` y utiliza exactamente el Dockerfile de `docker-image-scripts/`.
El primer build descarga paquetes de APT, NodeSource, Corepack, Git y Yarn;
los siguientes pueden reutilizar capas. Usa `--no-cache` solamente cuando
necesites repetir toda la compilación.

```bash
# Construye la imagen con el nombre declarado en compose-a.yaml.
docker compose -f compose-a.yaml build

# Crea o actualiza el contenedor con los puertos y volúmenes del proyecto.
docker compose -f compose-a.yaml up -d --force-recreate

# Comprueba que aparece 'healthy' una vez inicializada la BD.
docker compose -f compose-a.yaml ps

# Consulta registros; Ctrl+C solo deja de seguirlos.
docker compose -f compose-a.yaml logs -f --tail=100

# Prueba HTTP. 200 o 401 pueden ser normales según auth.
curl -I http://127.0.0.1:8082
```

La imagen de A se llama `mongo-db-and-express-fasttrack:1.0` y el
contenedor `mongodb-fasttrack-tutorial`. Para inspeccionar la imagen recién
construida **sin iniciar Supervisor**, cambia temporalmente el entrypoint:

```bash
# Confirmar rutas de scripts y de la aplicación en la imagen.
docker compose -f compose-a.yaml run --rm --no-deps \
  --entrypoint sh mongodb -lc \
  'tail -n 5 /usr/local/bin/start-mongo-express.sh; \
   ls -l /opt/mongo-express/app.js; \
   node --version; corepack yarn --version'

# Verificar procesos vivos dentro del contenedor A.
docker compose -f compose-a.yaml exec mongodb ps aux

# Supervisor del archivo aportado no habilita supervisorctl.
# Revisar procesos y logs es el método de comprobación usado aquí.
```

### 5.3. Ejecutar variante B y contrastar

Puedes ejecutarla simultáneamente con A porque los puertos externos, nombres
de proyecto y volúmenes son diferentes. Compose creará la red privada
`mongodb-fasttrack-multi_inventory_net` (nombre generado a partir del
proyecto y de la red lógica). Docker Compose no utiliza el Dockerfile en B.

```bash
# Descargar imágenes oficiales y crear los dos contenedores.
docker compose -f compose-b.yaml pull
docker compose -f compose-b.yaml up -d

# Ambos deben estar 'Up'; mongodb debe terminar 'healthy'.
docker compose -f compose-b.yaml ps

# Revisar solo los mensajes de MongoDB.
docker compose -f compose-b.yaml logs -f mongodb

# Revisar solo la aplicación web (Ctrl+C para salir).
docker compose -f compose-b.yaml logs -f mongo-express

# Verificar puertos HTTP de las dos variantes.
curl -I http://127.0.0.1:8082
curl -I http://127.0.0.1:8083
```

### 5.3.1. `mongod` frente a `mongosh`; inspección desde Bash

**`mongod`** es el proceso del servidor de bases de datos. **`mongosh`**
es su cliente interactivo JavaScript: hablar con MongoDB mediante
`mongosh` no arranca otro servidor. En A, Supervisor invoca el
`docker-entrypoint.sh` de la imagen oficial y este inicia `mongod`.
En B, el contenedor `mongo:8.0` lo inicia con su entrypoint habitual.
En ambos casos `mongosh` se ejecuta como proceso adicional y temporal.

```bash
# Variante A: entrar al Bash del contenedor ya levantado.
docker compose -f compose-a.yaml exec mongodb bash

# Dentro del contenedor: verificar binarios y procesos.
command -v mongod
command -v mongosh
mongod --version | head -n 3
mongosh --version
ps -ef | grep '[m]ongod'

# Opcional: comprobar la configuración de argumentos del servidor.
# El puerto interno permanece en 27017 aunque el host use 27028.
# Salir de Bash ANTES de los siguientes comandos del host.
exit

# Desde el host: inspeccionar el puerto publicado por Compose.
docker compose -f compose-a.yaml port mongodb 27017

# Variante B: Bash solo dentro del servicio que tiene MongoDB.
docker compose -f compose-b.yaml exec mongodb bash
# Repite la inspección; salir con exit.
```

En una sesión de `mongosh`, `db.adminCommand({ ping: 1 })` verifica
una conexión autenticada. Una respuesta exitosa no prueba por sí sola
que Mongo Express esté disponible: esa comprobación se hace por HTTP.

### 5.4. `mongosh`, autenticación y primera colección

Realiza la inserción primero en A y verifica que todavía no aparece en B;
después puedes repetirla en B para comparar los resultados.
`mongosh` evalúa JavaScript en el cliente y envía operaciones al servidor MongoDB. Usa el usuario
administrador del laboratorio para empezar; en las secciones de seguridad
crearemos usuarios con permisos limitados para aplicaciones reales.

```bash
# A: solicitar contraseña interactivamente, sin escribirla
# en el historial de la terminal.
docker compose -f compose-a.yaml exec mongodb \
  mongosh --username labadmin --authenticationDatabase admin \
  --password

# B: el comando debe ejecutarse en el servicio mongodb.
docker compose -f compose-b.yaml exec mongodb \
  mongosh --username labadmin --authenticationDatabase admin \
  --password
```

```javascript
// Dentro de mongosh: comprobar versión, autenticación y vida.
db.adminCommand({ ping: 1 })
db.version()

// Elegir una base separada en cada instancia según dónde estés.
use inventory

// Insertar un documento del sistema de inventario incremental.
db.products.insertOne({
  sku: "LAB-001",
  name: "Teclado mecánico",
  category: "peripherals",
  attributes: { layout: "ISO", switches: "brown" },
  createdAt: new Date()
})

// Confirmar lectura; el _id es generado por MongoDB.
db.products.find({ sku: "LAB-001" })

// Listar las colecciones creadas en esta base.
show collections
```

**Prueba de aislamiento:** inserta `LAB-001` solo en A y consulta B: no
debe aparecer allí hasta que lo insertes de forma independiente. Las
instancias tienen datos y volúmenes diferentes, aunque ambos Compose lean
las mismas credenciales de `.env`.

### 5.5. Primer script JavaScript guardado en el repositorio

Hasta ahora ejecutamos comandos manualmente en `mongosh`. El entregable de
esta sección incluye un **archivo JavaScript versionado en Git** que crea
la base de datos, crea explícitamente la colección e inserta el primer
documento. Para evitar confundirlo con los scripts de arranque de
contenedores, guárdalo en `mongo/scripts/`, **no** en
`docker-image-scripts/` ni en `mongo/init/`.

El archivo `mongo/init/` se reserva para scripts que la imagen oficial
ejecutaría durante la **primera inicialización de un volumen vacío**.
Nuestro script se ejecutará **a demanda**, también sobre un volumen que
ya tenga datos. Para ello utilizamos `mongosh --file`.

**Archivo: `mongo/scripts/01-primer-contacto.js`**

```javascript

// ============================================================================
// MONGODB FASTTRACK — SECCIÓN 01
// ============================================================================
// Archivo: mongo/scripts/01-primer-contacto.js
//
// Objetivo:
//   1. Seleccionar la base de datos inventory.
//   2. Crear explícitamente la colección products si todavía no existe.
//   3. Insertar el primer producto del laboratorio si no está registrado.
//   4. Consultar e imprimir el resultado.
//   5. Comprobar el documento mediante una aserción sencilla.
//
// Ejecución:
//   mongosh --file /workspace/mongo/scripts/01-primer-contacto.js
//
// Este archivo usa JavaScript de mongosh, no Node.js.
// No utiliza require(), npm, Yarn ni un driver de aplicación.
//
// Es idempotente para el SKU indicado: podemos repetirlo sin generar
// duplicados de ese producto. En lecciones posteriores veremos cómo
// reforzar esta garantía con un índice único.
// ============================================================================

// Obtener una referencia a inventory sin depender de la base de datos
// seleccionada al conectarnos (normalmente admin, para autenticación).
// MongoDB materializará la base al crear la colección o escribir datos.
const inventoryDb = db.getSiblingDB("inventory");

// Nombre de la primera colección del proyecto de inventario.
const collectionName = "products";

// Crear la colección solo si aún no existe. Este paso es deliberado:
// MongoDB también podría crearla implícitamente con insertOne().
if (!inventoryDb.getCollectionNames().includes(collectionName)) {
  inventoryDb.createCollection(collectionName);
  print("[OK] Colección inventory.products creada.");
} else {
  print("[OK] Colección inventory.products ya existe.");
}

// Primer producto de prueba. El identificador _id será generado
// automáticamente por MongoDB cuando insertemos el documento.
const firstProduct = {
  sku: "SCRIPT-001",
  name: "Ratón inalámbrico",
  category: "peripherals",
  attributes: {
    connection: "Bluetooth",
    color: "black"
  },
  stock: 15,
  createdAt: new Date()
};

// Insertar solo si todavía no existe este SKU.
// $setOnInsert evita cambiar createdAt o stock en nuevas ejecuciones.
// upsert=true crea el documento si no existe; si existe, no lo altera.
const writeResult = inventoryDb.products.updateOne(
  { sku: firstProduct.sku },
  { $setOnInsert: firstProduct },
  { upsert: true }
);

// Mostrar el resultado de la escritura para distinguir la primera
// ejecución de las posteriores.
print("[INFO] Resultado de la escritura:");
printjson(writeResult);

// Recuperar el documento por su SKU y mostrarlo en la terminal.
const savedProduct = inventoryDb.products.findOne({
  sku: firstProduct.sku
});

print("[INFO] Primer producto:");
printjson(savedProduct);

// Una comprobación ejecutable: el script fallará si no recuperamos
// el documento esperado. Esto facilita detectar problemas en el lab.
if (!savedProduct || savedProduct.sku !== "SCRIPT-001") {
  throw new Error("No se encontró el producto SCRIPT-001.");
}

print("[OK] Primera base, colección y documento verificados.");
```

**Cómo llega el archivo al contenedor.** Ambos Compose de esta edición
incorporan el mismo bind mount de solo lectura:

```yaml
# Archivo real en el Mac:
#   ./mongo/scripts/01-primer-contacto.js
#
# Ruta visible para mongosh en el contenedor:
#   /workspace/mongo/scripts/01-primer-contacto.js
volumes:
  - ./mongo/scripts:/workspace/mongo/scripts:ro
```

Este montaje no cambia la imagen construida ni guarda datos de MongoDB:
solo comparte el **código fuente del laboratorio**. Puedes editar el `.js`
en VS Code y volver a ejecutarlo sin reconstruir la imagen Docker.

**Ejecutar en la variante A, desde la terminal del host:**

```bash
# Verificar que el archivo se puede leer dentro del contenedor.
docker compose -f compose-a.yaml exec mongodb \
  ls -l /workspace/mongo/scripts/01-primer-contacto.js

# Abrir mongosh y solicitar la contraseña sin escribirla en el comando.
docker compose -f compose-a.yaml exec mongodb \
  mongosh --username labadmin \
  --authenticationDatabase admin \
  --password \
  --file /workspace/mongo/scripts/01-primer-contacto.js
```

**Ejecutar en la variante B:**

```bash
# Mismo script, distinto contenedor y distinta base de datos.
docker compose -f compose-b.yaml exec mongodb \
  mongosh --username labadmin \
  --authenticationDatabase admin \
  --password \
  --file /workspace/mongo/scripts/01-primer-contacto.js
```

Si cambiaste el usuario `labadmin` en `.env`, reemplázalo en los comandos.
Si el contenedor ya estaba creado **antes** de añadir el bind mount, ejecuta
`docker compose -f compose-a.yaml up -d --force-recreate` o su equivalente
para B: `restart` por sí solo no agrega montajes nuevos.

**Verificar el resultado desde una sesión interactiva:**

```bash
# Entrar a Bash del contenedor de A (salir con exit).
docker compose -f compose-a.yaml exec mongodb bash

# Desde Bash, abrir mongosh.
mongosh --username labadmin --authenticationDatabase admin --password
```

```javascript
// Dentro de mongosh:
use inventory

// Comprobar que el script creó explícitamente la colección.
show collections

// Recuperar el documento creado desde el archivo .js.
db.products.findOne({ sku: "SCRIPT-001" })

// Ejecuta el archivo desde una sesión mongosh ya autenticada,
// como alternativa a la opción --file de la línea de comandos.
load("/workspace/mongo/scripts/01-primer-contacto.js")
```

**Segunda ejecución:** ejecuta nuevamente `mongosh --file` y comprueba
que no duplica `SCRIPT-001`. La colección `products` puede contener también
`LAB-001`, si realizaste antes la inserción manual de 5.4. Ambas formas de
trabajar sobre MongoDB —consola interactiva y archivo versionado— son
entregables diferentes de esta sección.

**Registro en Git:**

```bash
# Desde la raíz del repositorio, en el host.
git add mongo/scripts/01-primer-contacto.js
git status --short

# Opcional: primer commit cuando también hayas revisado los Compose
# y los demás archivos de la sección.
# git add compose.yaml compose.multi.yaml docker-image-scripts/ \
#   .gitignore .dockerignore .env.example
# git commit -m "lab: entorno Docker y primer script de mongosh"
```

### 5.6. Persistencia y respaldos

Un volumen con nombre conserva el directorio de datos gestionado por MongoDB.
No es equivalente a `mongodump`: copiar archivos internos mientras el
servidor escribe no garantiza por sí solo un respaldo consistente. Para el
laboratorio se utiliza `mongodump` y se guarda el resultado en un bind mount
visible desde el host; más adelante se practicarán restauración, estrategias
de respaldo y las consideraciones de despliegue real.

```bash
# Parar y eliminar SOLO el contenedor A: el volumen sigue existiendo.
docker compose -f compose-a.yaml down
docker compose -f compose-a.yaml up -d

# Conectar otra vez a A y comprobar que LAB-001 continúa presente.
docker compose -f compose-a.yaml exec mongodb \
  mongosh --username labadmin --authenticationDatabase admin \
  --password

# Dentro de mongosh:
# use inventory
# db.products.findOne({ sku: "LAB-001" })

# Salir de mongosh ANTES de ejecutar los siguientes comandos de shell.
# Realizar dump usando credenciales ya presentes dentro del contenedor.
docker compose -f compose-a.yaml exec mongodb sh -lc \
  'mongodump --username "$MONGO_INITDB_ROOT_USERNAME" \
   --password "$MONGO_INITDB_ROOT_PASSWORD" \
   --authenticationDatabase admin \
   --db inventory --out /backups/inventory-dump'

# Ver archivos de respaldo de A desde el host.
find mongo/backups/single -maxdepth 3 -type f

# B tiene su propio directorio físico de respaldos.
docker compose -f compose-b.yaml exec mongodb sh -lc \
  'mongodump --username "$MONGO_INITDB_ROOT_USERNAME" \
   --password "$MONGO_INITDB_ROOT_PASSWORD" \
   --authenticationDatabase admin \
   --db inventory --out /backups/inventory-dump'
find mongo/backups/multi -maxdepth 3 -type f
```

**Seguridad:** estos comandos de dump reciben contraseñas por argumento
dentro del contenedor, por simplicidad del laboratorio. No es un patrón para
entornos multiusuario o producción. Usa cuentas de respaldo, permisos
mínimos y mecanismos de secretos apropiados cuando lleguemos a seguridad.

**Destrucción deliberada:** `docker compose down -v` elimina también los
volúmenes asociados al proyecto. Úsalo solo si quieres reinicializar desde
cero y no necesitas los datos. Cambiar `MONGO_INITDB_ROOT_PASSWORD` en `.env`
**no** modifica la contraseña del usuario ya creado en un volumen anterior.

## 6. Diagnóstico de errores que ocurrieron en esta sección

| Síntoma | Causa habitual | Comprobación y resolución |
|---|---|---|
| `EUNSUPPORTEDPROTOCOL patch:` | `npm install` no interpreta los parches de Yarn | Clonar la rama utilizada y ejecutar `corepack yarn install` |
| Build termina y Mongo Express no arranca | Script aún usa `node_modules/mongo-express/app.js` | Inspeccionar el script **dentro** de la imagen; ejecutar `/opt/mongo-express/app.js` |
| `mongo-express entered FATAL state` | Supervisor agotó reinicios por error en Node | Revisar `docker compose logs` y la línea `exec node` |
| `MongoDB todavía no está listo` indefinidamente | BD no disponible o credenciales erróneas | Ver `.env`, volúmenes previos y logs de MongoDB |
| `Connection refused` al abrir web | Node no escucha en 8081 o no se publicó el puerto | Revisar logs, procesos y `ports:` |
| URI a `127.0.0.1` falla en B | El loopback apunta al contenedor web | Utilizar nombre de servicio `mongodb:27017` |
| Nueva contraseña no funciona | Usuario root ya existe en volumen | Autenticar con contraseña original o cambiarla dentro de MongoDB |
| `bind: address already in use` | Puertos del host ocupados | Cambiar puertos de `.env`, mantener puertos internos |
| `docker build .` genera imagen sin nombre | Falta `-t` o build fuera de Compose | Usar `docker compose build` o `docker build -t nombre -f ... .` |

**Verificación de ruta, paso a paso, sin suposiciones:**

```bash
# 1) Ver lo que hay en el disco del host.
tail -n 8 docker-image-scripts/start-mongo-express.sh

# 2) Ver exactamente qué comando COPY utilizará el Dockerfile.
grep '^COPY ' docker-image-scripts/Dockerfile

# 3) Reconstruir y recrear, sin borrar volúmenes.
docker compose -f compose-a.yaml build --no-cache
docker compose -f compose-a.yaml up -d --force-recreate

# 4) Leer el script que está REALMENTE en el contenedor.
docker compose -f compose-a.yaml exec mongodb \
  tail -n 8 /usr/local/bin/start-mongo-express.sh

# 5) Verificar que el archivo de Node existe donde apunta el script.
docker compose -f compose-a.yaml exec mongodb \
  ls -l /opt/mongo-express/app.js

# 6) Comprobar que Supervisor invoque ese mismo script.
docker compose -f compose-a.yaml exec mongodb \
  grep -A 12 '^\[program:mongo-express\]' \
  /etc/supervisor/conf.d/lab.conf

# 7) Revisar solo los últimos eventos sin imprimir .env.
docker compose -f compose-a.yaml logs --tail=100
```

### 6.1. Comandos de consulta y limpieza

No mezcles el borrado de imágenes, contenedores, volúmenes y caché. Una
construcción fallida puede dejar capas en la caché de BuildKit sin haber
producido imagen final. Para una compilación manual con nombre y Dockerfile
fuera de la raíz, utiliza `-f` y **conserva el punto final** como contexto.

```bash
# Construcción manual equivalente a la declarada por Compose.
docker build -f docker-image-scripts/Dockerfile \
  -t mongo-db-and-express-fasttrack:1.0 .

# Imágenes existentes, incluidas las que no tienen etiqueta.
docker image ls -a

# Contenedores de ambas variantes.
docker compose -f compose-a.yaml ps
docker compose -f compose-b.yaml ps

# Inspeccionar nombres de los volúmenes de cada proyecto.
docker volume ls

# Detener A sin borrar datos.
docker compose -f compose-a.yaml down

# Detener B sin borrar datos.
docker compose -f compose-b.yaml down

# Eliminar imágenes colgantes no utilizadas (no elimina volúmenes).
docker image prune

# Limpiar caché de construcción no utilizada.
docker builder prune

# ¡DESTRUCTIVO! Elimina volúmenes del proyecto que el comando gestiona.
# Ejecutar solo cuando se haya confirmado que no se necesitan los datos.
# docker compose -f compose-a.yaml down -v
# docker compose -f compose-b.yaml down -v
```

### 6.2. Comprobación de entregables del syllabus

Antes de cerrar la sección, revisa desde la raíz del repositorio:

```bash
# Los dos elementos exigidos explícitamente por nombre.
test -f compose-a.yaml && echo '[OK] compose-a.yaml'
test -f compose-b.yaml && echo '[OK] compose-b.yaml'
test -f .gitignore && echo '[OK] .gitignore'

# Estructura y script JavaScript con un archivo tangible.
test -d mongo/scripts && echo '[OK] mongo/scripts/'
test -f mongo/scripts/01-primer-contacto.js && \
  echo '[OK] primer script de mongosh'

# Comprobar que Git omite los secretos.
git check-ignore .env

# Listar el primer script sin imprimir contraseñas.
ls -lh mongo/scripts/01-primer-contacto.js
```

Completa el criterio funcional ejecutando §5.5 y comprobando que
`db.products.findOne({ sku: "SCRIPT-001" })` devuelve un documento.
Si el archivo está ausente, el apartado §5.5 contiene su código completo.

### 6.3. Lista de cierre literal de `00-syllabus.md`

Marca cada punto solo después de ejecutar el comando o comprobar su salida:

- [ ] `compose-a.yaml` y `compose-b.yaml` válidos con `docker compose -f ... config --quiet`.
- [ ] `.gitignore` versionado; `.env` ignorado por `git check-ignore`.
- [ ] Estructura inicial creada y abierta desde la raíz en VS Code.
- [ ] `mongo/scripts/01-primer-contacto.js` presente y leído por `mongosh`.
- [ ] `inventory.products` contiene el documento `SCRIPT-001`.
- [ ] Un `down` seguido de `up -d` conserva el documento por el volumen.

Los últimos dos puntos verifican la funcionalidad de los entregables,
aunque los nombres exigidos por el syllabus son los cuatro anteriores.

## 7. Ejercicio individual (15–20 minutos)

Sin seguir literalmente los comandos anteriores, realiza estas tareas:

1. Deja A y B ejecutándose a la vez. Verifica que cada una publique los
   puertos asignados y que ambas interfaces web sean accesibles.
2. Cambia **solo** el puerto web externo de B de `8083` a `8084` en `.env`,
   recrea B y explica por qué Mongo Express conserva `8081` internamente.
3. Inserta un producto diferente en A y en B. Muestra que no se cruzan los
   documentos. Haz `down` y `up` de B sin `-v` y verifica persistencia.
4. Simula el error de ruta antigua **sin comprometer los datos**: compara el
   resultado de `ls /opt/mongo-express/app.js` con la ruta inexistente
   `ls /opt/mongo-express/node_modules/mongo-express/app.js`; explica por qué
   el build podía pasar y el proceso Node fallar al iniciar.
5. Ejecuta `01-primer-contacto.js` en A y B con `mongosh --file`,
   repite la ejecución y verifica que `SCRIPT-001` no se duplica.
6. Genera un `mongodump` separado de cada instancia y comprueba que aparece
   en el subdirectorio correcto. No restaures ni elimines volúmenes aún.

**Criterios de aceptación:** ambos proyectos corren simultáneamente,
MongoDB autentica en A y B, las interfaces web responden, los datos de A y
B son independientes, sobreviven a `down`/`up`, el script versionado
funciona en ambas y cada dump queda en la carpeta correspondiente.

## 8. Preguntas tipo entrevista y respuestas esperadas

**¿Dockerfile y Compose hacen lo mismo?** No. El Dockerfile construye la
imagen; Compose define servicios, imágenes o builds, puertos, variables,
redes y volúmenes para ejecutarlas.

**¿Por qué una imagen por servicio suele simplificar la operación?** Permite
reiniciar, registrar, actualizar y aislar procesos con ciclos de vida
independientes. A agrupa procesos por un objetivo didáctico.

**¿Qué cambia entre `127.0.0.1` de A y `mongodb` de B?** En A ambas
aplicaciones comparten red. En B tienen redes de contenedor separadas y se
encuentran mediante el DNS de Compose.

**¿`depends_on` garantiza que MongoDB ya está disponible?** Solo con
`condition: service_healthy` espera inicialmente el healthcheck declarado;
no sustituye reintentos ni gestiona automáticamente todas las desconexiones
posteriores.

**¿Por qué `docker compose down` normalmente no elimina los documentos?**
Porque los datos viven en volúmenes con nombre; `down -v` sí elimina los
volúmenes administrados por el proyecto.

**¿Se puede copiar `/data/db` mientras `mongod` está escribiendo y llamarlo
backup?** No es una estrategia fiable por sí sola. Usa herramientas y
procedimientos consistentes, como `mongodump` para este laboratorio.

**¿Por qué Yarn y no npm en A?** El proyecto descargado contiene
especificaciones `patch:` de Yarn; npm no puede procesarlas directamente.
Corepack utiliza el Yarn declarado por el repositorio.

**¿Qué hace `exec` al final del script?** Sustituye Bash por Node.js en el
mismo proceso y permite que Supervisor administre directamente la aplicación.

## 9. Resumen de continuidad

Al cerrar esta sección conserva: los cuatro archivos originales con sus
rutas corregidas en `docker-image-scripts/` y `compose.yaml`; la variante B
en `compose.multi.yaml`; `.env.example` y `.env` local; los respaldos
separados; y `mongo/scripts/01-primer-contacto.js`, ejecutado en ambas
variantes, con la colección `inventory.products` y el primer documento.

Para el siguiente chat basta informar qué variante dejaste encendida y los
puertos del host. La siguiente sección del syllabus es **«BSON, CRUD y operadores»**
(1 h 15 min). Se realizará en otro chat, reutilizando la base y el
primer producto creados aquí, sin repetir la instalación de Docker.

### Referencias de consulta

- [Docker: Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Docker Compose: referencia](https://docs.docker.com/reference/compose-file/)
- [Docker: persistencia y volúmenes](https://docs.docker.com/engine/storage/volumes/)
- [MongoDB: MongoDB Database Tools / mongodump](https://www.mongodb.com/docs/database-tools/mongodump/)
- [Mongo Express: repositorio](https://github.com/mongo-express/mongo-express)
- [Corepack: documentación](https://nodejs.org/api/corepack.html)

---

**Nota de validación:** la compilación exitosa comunicada de A corresponde al
Dockerfile y los scripts suministrados por el alumno. Los cambios de
organización, los healthchecks y la variante B son material de esta edición;
no se ha ejecutado Docker desde este entorno de generación. Antes de usarlos,
valida ambos Compose en tu máquina con:
```bash
docker compose -f compose-a.yaml config --quiet
docker compose -f compose-b.yaml config --quiet
```


---

## Control final de alcance (contrastado con `00-syllabus.md`)

**Obligatorio según `00-syllabus.md`:** repositorio Git abierto
en VS Code, `compose-a.yaml` y `compose-b.yaml`, `.gitignore`, MongoDB 8.0 y Mongo Express
funcionando, comprensión de la red y los montajes, acceso por Bash y
`mongosh`, primera base/colección/documento y primer JavaScript
versionado ejecutado desde un archivo.

**Ampliación opcional solicitada:** comparar el Dockerfile de un solo
contenedor con dos servicios oficiales, ejecutar ambas variantes en
paralelo, inspeccionar Supervisor y Yarn, generar backups de laboratorio
y diagnosticar problemas de build y arranque.

La siguiente sección del syllabus debe desarrollarse en otro chat.
