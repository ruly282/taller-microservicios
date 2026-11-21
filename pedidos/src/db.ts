import sql from "mssql";

// La configuración sale de variables de entorno (en Docker) o usa los valores de desarrollo.
const config: sql.config = {
  server: process.env.DB_SERVER ?? "localhost",
  port: Number(process.env.DB_PORT ?? 1433),
  user: process.env.DB_USER ?? "sa",
  password: process.env.DB_PASSWORD ?? "TallerCafe_2026",
  database: "PedidosDb",
  options: { encrypt: true, trustServerCertificate: true },
};

let pool: sql.ConnectionPool | undefined;

// Una sola conexión compartida (pool) para todo el servicio
export async function obtenerPool(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await new sql.ConnectionPool(config).connect();
  }
  return pool;
}

// Crea la base de datos y las tablas si no existen. Es T-SQL normal.
export async function prepararBase(): Promise<void> {
  const master = await conectarConReintentos({ ...config, database: "master" });
  await master.request().query(`
    IF DB_ID('PedidosDb') IS NULL
      CREATE DATABASE PedidosDb;
  `);
  await master.close();

  const db = await obtenerPool();
  await db.request().query(`
    IF OBJECT_ID('dbo.Pedidos') IS NULL
      CREATE TABLE dbo.Pedidos (
        Id      INT IDENTITY PRIMARY KEY,
        Cliente NVARCHAR(100) NOT NULL,
        Total   DECIMAL(10, 2) NOT NULL,
        Fecha   DATETIME2 NOT NULL DEFAULT SYSDATETIME()
      );
  `);
  await db.request().query(`
    IF OBJECT_ID('dbo.PedidoDetalle') IS NULL
      CREATE TABLE dbo.PedidoDetalle (
        Id             INT IDENTITY PRIMARY KEY,
        PedidoId       INT NOT NULL REFERENCES dbo.Pedidos(Id),
        ProductoId     INT NOT NULL,
        Nombre         NVARCHAR(100) NOT NULL,
        Cantidad       INT NOT NULL CHECK (Cantidad > 0),
        PrecioUnitario DECIMAL(10, 2) NOT NULL
      );
  `);
  console.log("Base de datos de pedidos lista");
}

// SQL Server tarda unos segundos en arrancar: se intenta varias veces antes de rendirse
async function conectarConReintentos(cfg: sql.config): Promise<sql.ConnectionPool> {
  for (let intento = 1; ; intento++) {
    try {
      return await new sql.ConnectionPool(cfg).connect();
    } catch (error) {
      if (intento >= 20) throw error;
      console.log(`SQL Server todavía no responde (intento ${intento})...`);
      await new Promise((resolver) => setTimeout(resolver, 3000));
    }
  }
}
