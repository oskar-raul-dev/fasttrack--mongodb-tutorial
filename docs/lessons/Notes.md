# Sección 1

## Borrado de todo lo creado por docker

Borrar:

- Contenedor.
- Imagen.
- Volúnenes.


- Detiene y elimina contenedor, red y volúmenes definidos en `compose.yaml`
```bash
docker compose down -v
```

- Elimina la imagen construida
```bash
docker rmi -f mongo-db-and-express-fasttrack:1.0
```

- Como además quedaron volúmenes huérfanos de los nombres anteriores del proyecto, bórralos aparte:
```bash
docker volume rm \
  tutorial-fastractk-mongo-db_mongo_config \
  tutorial-fastractk-mongo-db_mongo_data \
  tutorial-fastrack-mongodb_mongo_config \
  tutorial-fastrack-mongodb_mongo_data
```

- Verifica que no quede nada suelto (debería dar vacío):
```bash
docker ps -a | grep -i mongo
docker volume ls | grep -i mongo
docker images | grep -i mongo
``` 

## Inicio de sesión mongosh

docker compose -f compose.yaml exec mongodb \
  mongosh --username labadmin --authenticationDatabase admin \
  --password

El password es el que está en el archivo `.env`

##  dentro de la shell mongosh

```bash
db # Objeto global con la BD
   # Como comando muestra la BD activa
   # La BD activa por defecto es db
```
  
```bash
use <nombre bd> # seleccionar bd
```bash

```bash
show dbs # Listar bd 
```bash


