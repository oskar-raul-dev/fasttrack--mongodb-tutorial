# MongoDB Fast Track — Syllabus

## Perfil objetivo

Tutorial práctico para un desarrollador Senior Java con experiencia en:

- Java
- Spring Boot
- APIs REST
- SQL
- Docker
- Git
- Maven
- pruebas automatizadas

No se dedicará tiempo a explicar fundamentos de Java, Maven, Spring Boot, REST o Docker salvo cuando sean necesarios para entender una particularidad de MongoDB.

## Duración máxima

12 horas.

## Metodología

- Una sección por chat.
- Proyecto incremental.
- Construcción manual del repositorio desde VS Code.
- Uso de Docker Compose.
- Ejercicios prácticos.
- Preguntas de entrevista.
- Comparaciones con SQL cuando ayuden.
- Uso de W3Schools MongoDB como referencia rápida.
- Uso de documentación oficial de MongoDB para temas de drivers, rendimiento, administración y modelado.

## Proyecto del curso

Sistema pequeño de inventario con:

- productos
- atributos heterogéneos
- bodegas
- stock por bodega
- movimientos de inventario
- reservas
- consultas analíticas
- API REST
- operaciones concurrentes

## Sección 01 — Entorno Docker y primera conexión

Duración: 45 min

### Temas

- Estructura del repositorio Git.
- VS Code.
- Docker Compose.
- MongoDB 8.0.
- Mongo Express.
- Redes Docker.
- Volúmenes.
- Bind mounts.
- Persistencia frente a backup.
- `mongod`.
- `mongosh`.
- Bash dentro del contenedor.
- Primera base de datos.
- Primera colección.
- Primer documento.
- Ejecución de scripts JavaScript almacenados en el repositorio.

### Entregables

- `compose.yaml`
- `.gitignore`
- estructura inicial del proyecto
- primer script de `mongosh`

---

## Sección 02 — BSON, CRUD y operadores

Duración: 1 h 15 min

### Temas

- BSON.
- `ObjectId`.
- Strings, números, booleanos y fechas.
- Documentos anidados.
- Arreglos.
- `insertOne()`.
- `insertMany()`.
- `find()`.
- `findOne()`.
- Proyecciones.
- Ordenación.
- Limitación y paginación.
- Conteos.
- Operadores de comparación:
  - `$eq`
  - `$ne`
  - `$gt`
  - `$gte`
  - `$lt`
  - `$lte`
  - `$in`
  - `$nin`
- Operadores lógicos:
  - `$and`
  - `$or`
  - `$not`
  - `$nor`
- `updateOne()`.
- `updateMany()`.
- `replaceOne()`.
- Operadores de actualización:
  - `$set`
  - `$unset`
  - `$inc`
  - `$push`
  - `$pull`
- `deleteOne()`.
- `deleteMany()`.
- Equivalencias conceptuales con SQL.

### Entregables

- dataset inicial
- scripts CRUD
- ejercicios de filtros y actualizaciones

---

## Sección 03 — Modelado documental

Duración: 1 h 15 min

### Temas

- Diseño basado en patrones de acceso.
- Embedding.
- Referencias.
- Desnormalización.
- Duplicación controlada.
- Relaciones uno a uno.
- Relaciones uno a muchos.
- Relaciones muchos a muchos.
- Arreglos dentro de documentos.
- Atributos heterogéneos.
- Stock embebido o referenciado.
- Límites de tamaño de documento.
- Validación con `$jsonSchema`.
- Atomicidad a nivel de documento.
- Introducción a transacciones multidocumento.
- Cuándo MongoDB es mejor opción que una base relacional.
- Cuándo no lo es.

### Entregables

- modelo documental del inventario
- colecciones:
  - `products`
  - `warehouses`
  - `stock_movements`
- validación de esquema
- ADR breve con decisiones de modelado

---

## Sección 04 — Consultas avanzadas y Aggregation Framework

Duración: 1 h 15 min

### Temas

- Consultas sobre documentos anidados.
- Consultas sobre arrays.
- `$elemMatch`.
- Aggregation Pipeline.
- `$match`.
- `$project`.
- `$sort`.
- `$group`.
- Acumuladores.
- `$unwind`.
- `$lookup`.
- `$facet`.
- Comparación con:
  - `JOIN`
  - `GROUP BY`
  - subqueries
- Pipelines compuestos.
- Optimización básica de pipelines.

### Entregables

- inventario por bodega
- productos con bajo stock
- valor monetario del inventario
- resumen por categoría
- consultas con arrays y documentos anidados

---

## Sección 05 — Índices y rendimiento

Duración: 45 min

### Temas

- Índices simples.
- Índices compuestos.
- Índices únicos.
- Índices multikey.
- Índices TTL.
- `createIndex()`.
- `dropIndex()`.
- `getIndexes()`.
- `explain("executionStats")`.
- `COLLSCAN`.
- `IXSCAN`.
- documentos examinados.
- documentos retornados.
- selectividad.
- orden de campos en índices compuestos.
- impacto de índices sobre escrituras.

### Entregables

- índices reales del proyecto
- comparación antes/después
- análisis con `explain()`

---

## Sección 06 — CLI y herramientas operativas

Duración: 1 h

### Herramientas

- `mongosh`
- `mongoimport`
- `mongoexport`
- `mongodump`
- `mongorestore`
- `bsondump`
- `mongostat`
- `mongotop`

### Temas

- ejecución de scripts desde terminal
- importación JSON
- importación CSV
- exportación JSON
- exportación CSV
- backups BSON
- backups comprimidos
- restauración
- inspección de BSON
- observación de actividad
- recuperación después de borrar datos
- servicio auxiliar `mongo-tools` en Docker Compose

### Entregables

- scripts de importación
- scripts de exportación
- backup
- restore
- prueba real de recuperación

---

## Sección 07 — MongoDB con Node.js y TypeScript

Duración: 2 h

### Temas

- driver oficial `mongodb`
- `MongoClient`
- `MongoDatabase`
- `MongoCollection`
- connection pool
- ciclo de vida de conexiones
- tipado TypeScript
- `ObjectId`
- serialización
- repositorios
- CRUD
- agregaciones
- manejo de errores
- restricciones únicas
- actualizaciones atómicas
- reserva de inventario
- pruebas de integración

### Alcance

No explicar:

- fundamentos de Node.js
- fundamentos de TypeScript
- REST
- Express básico
- async/await básico

### Entregables

- API REST
- contenedor Node.js
- endpoints de productos
- endpoints de inventario
- reserva de stock
- tests
- archivo `.http` o colección equivalente

---

## Sección 08 — MongoDB con Java Core

Duración: 1 h 15 min

### Temas

- driver oficial síncrono
- `mongodb-driver-sync`
- `MongoClient`
- `MongoDatabase`
- `MongoCollection`
- `Document`
- POJOs
- codecs
- BSON
- filtros
- proyecciones
- actualizaciones
- agregaciones
- operaciones atómicas
- manejo de errores
- gestión de conexiones
- comparación con el driver Node.js

### Alcance

No explicar:

- creación de proyecto Maven
- sintaxis Java
- POO
- JUnit básico
- estructura estándar de proyecto

### Entregables

- aplicación Java de consola
- consultas de productos
- registro de movimientos
- reserva atómica
- pruebas JUnit

---

## Sección 09 — Spring Boot y Spring Data MongoDB

Duración: 1 h 45 min

### Temas

- `spring-boot-starter-data-mongodb`
- configuración de conexión
- `@Document`
- `@Id`
- `@Field`
- `@Indexed`
- documentos embebidos
- `MongoRepository`
- query methods
- `@Query`
- `MongoTemplate`
- `Criteria`
- `Query`
- `Update`
- Aggregation API
- actualizaciones atómicas
- concurrencia
- `@Version`
- tests con Testcontainers

### Alcance

No explicar:

- cómo crear un proyecto Spring Boot
- Maven
- controladores REST básicos
- services básicos
- dependency injection
- estructura estándar por capas

Solo indicar qué componentes crear y concentrarse en MongoDB y Spring Data.

### Entregables

- API Spring Boot
- documentos mapeados
- repositorios
- consultas con `MongoTemplate`
- agregaciones
- reserva de inventario
- tests de integración

---

## Sección 10 — Simulacro de entrevista técnica

Duración: 45 min

### Desafío

Implementar una reserva segura de inventario.

### Requisitos

- validar cantidad
- impedir stock negativo
- manejar concurrencia
- idempotencia
- historial de movimientos
- índice adecuado
- pruebas
- explicación de decisiones técnicas

### Preguntas de revisión

- embedding vs referencias
- MongoDB vs SQL
- atomicidad por documento
- transacciones
- índices compuestos
- arrays e índices multikey
- `MongoRepository` vs `MongoTemplate`
- `Document` vs POJO
- `ObjectId`
- connection pooling
- manejo de fallos de conexión
- backup y restore

## Duración total

12 horas máximo.