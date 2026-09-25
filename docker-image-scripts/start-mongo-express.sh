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
