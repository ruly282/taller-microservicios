import express from "express";
import sql from "mssql";
import { obtenerPool, prepararBase } from "./db";

const app = express();
app.use(express.json());

app.get("/", (_req, res) => {
  res.send("Servicio de pedidos funcionando");
});

// TODO bloque 3: POST /pedidos
//   1. Validar que vengan el cliente y al menos un producto (si no, 400)
//   2. Preguntarle al menú por cada producto con buscarProducto
//      (si no existe, 400; si el menú no responde, 503)
//   3. Calcular el total con los precios del menú
//   4. Guardar el pedido y su detalle en UNA transacción y responder 201

// Todos los pedidos (ya viene hecho)
app.get("/pedidos", async (_req, res) => {
  const pool = await obtenerPool();
  const resultado = await pool.request().query(`
    SELECT Id AS id, Cliente AS cliente, Total AS total, Fecha AS fecha
    FROM Pedidos
    ORDER BY Id DESC
  `);
  res.json(resultado.recordset);
});

// Un pedido con su detalle (ya viene hecho)
app.get("/pedidos/:id", async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) {
    res.status(400).json({ error: "El id debe ser un número" });
    return;
  }

  const pool = await obtenerPool();
  const pedido = await pool.request()
    .input("id", sql.Int, id)
    .query("SELECT Id AS id, Cliente AS cliente, Total AS total, Fecha AS fecha FROM Pedidos WHERE Id = @id");

  if (pedido.recordset.length === 0) {
    res.status(404).json({ error: `No existe el pedido ${id}` });
    return;
  }

  const detalle = await pool.request()
    .input("id", sql.Int, id)
    .query(`
      SELECT ProductoId AS id, Nombre AS nombre, Cantidad AS cantidad, PrecioUnitario AS precio
      FROM PedidoDetalle
      WHERE PedidoId = @id
    `);

  res.json({ ...pedido.recordset[0], productos: detalle.recordset });
});

const puerto = Number(process.env.PORT ?? 3000);

async function iniciar() {
  await prepararBase();
  app.listen(puerto, () => {
    console.log(`Servicio de pedidos escuchando en http://localhost:${puerto}`);
  });
}

iniciar().catch((error) => {
  console.error("No se pudo iniciar el servicio de pedidos:", error);
  process.exit(1);
});
