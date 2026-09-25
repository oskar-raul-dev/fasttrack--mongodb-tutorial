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
