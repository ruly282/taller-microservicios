import express from "express";
import sql from "mssql";

// El servicio de menú, al que le vamos a preguntar los precios
const MENU_URL = "http://localhost:5000";

const config = {
  server: "localhost",
  user: "sa",
  password: "TallerCafe_2026",
  options: { trustServerCertificate: true },
};

// Pedidos tiene su propia base de datos: la crea, con su tabla, si todavía no existe
const master = await new sql.ConnectionPool(config).connect();
await master.query("IF DB_ID('PedidosDb') IS NULL CREATE DATABASE PedidosDb");
await master.close();

const db = await new sql.ConnectionPool({ ...config, database: "PedidosDb" }).connect();
await db.query(`
  IF OBJECT_ID('Pedidos') IS NULL
    CREATE TABLE Pedidos (
      id INT IDENTITY PRIMARY KEY,
      cliente NVARCHAR(100) NOT NULL,
      total DECIMAL(10, 2) NOT NULL,
      fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    )
`);

const app = express();
app.use(express.json());

app.get("/pedidos", async (req, res) => {
  const resultado = await db.query("SELECT * FROM Pedidos ORDER BY id DESC");
  res.json(resultado.recordset);
});

app.post("/pedidos", async (req, res) => {
  const { cliente, productos } = req.body;
  if (!cliente || !productos || productos.length === 0) {
    res.status(400).json({ error: "Falta el cliente o los productos" });
    return;
  }

  let total = 0;
  for (const item of productos) {
    if (!item.cantidad || item.cantidad < 1) {
      res.status(400).json({ error: "La cantidad debe ser 1 o más" });
      return;
    }

    // Aquí un microservicio le pregunta a otro por HTTP
    const respuesta = await fetch(`${MENU_URL}/productos/${item.id}`).catch(() => null);
    if (!respuesta) {
      res.status(503).json({ error: "El menú no responde" });
      return;
    }
    if (!respuesta.ok) {
      res.status(400).json({ error: `No existe el producto ${item.id}` });
      return;
    }

    const producto = await respuesta.json();
    total += producto.precio * item.cantidad;
  }

  const resultado = await db.request()
    .input("cliente", cliente)
    .input("total", total)
    .query("INSERT INTO Pedidos (cliente, total) OUTPUT INSERTED.* VALUES (@cliente, @total)");

  res.status(201).json(resultado.recordset[0]);
});

app.listen(3000, () => {
  console.log("Pedidos escuchando en el puerto 3000");
});
