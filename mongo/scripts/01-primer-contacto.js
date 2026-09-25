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
