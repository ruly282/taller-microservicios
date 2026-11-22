# 3. Servicio de pedidos en Node.js con TypeScript

**Meta:** que pedidos le pregunte al menú por REST si cada producto existe y cuánto cuesta, y que guarde el pedido con una transacción.

Si no terminaste el bloque 2: `./punto-de-control.sh 3`

En el proyector se hace la llamada al menú y la validación. Luego te toca preguntarle al menú por cada producto, y al final se hace la transacción en el proyector.

## En el proyector

### Paso 1. Ten todo corriendo

Vas a necesitar tres cosas arriba, cada una en su terminal:

1. **SQL Server:** `docker compose ps` debe decir **healthy**. Si no aparece: `docker compose up -d sqlserver`.
2. **El menú:** `cd menu` y luego `dotnet run`.
3. **Pedidos:** `cd pedidos` y luego `npm run dev`.

Pedidos debe decir `Base de datos de pedidos lista`. Con `npm run dev`, cada vez que guardas un archivo el servicio se reinicia solo.

### Paso 2. Revisa lo que ya viene hecho

- `pedidos/src/db.ts` crea la base `PedidosDb` y sus dos tablas con T-SQL. Fíjate en `CHECK (Cantidad > 0)`: la base no acepta cantidades en 0.
- `pedidos/src/index.ts` ya trae `GET /pedidos` y `GET /pedidos/:id`.

### Paso 3. Pregúntale al menú

En `pedidos/src/menu.ts`, borra la línea del `throw` y en su lugar escribe:

```ts
  const respuesta = await fetch(`${MENU_URL}/productos/${id}`);

  if (respuesta.status === 404) return null;
  if (!respuesta.ok) throw new Error(`El menú respondió ${respuesta.status}`);

  return (await respuesta.json()) as Producto;
```

Así se hablan dos microservicios: uno le hace una petición HTTP al otro, aunque estén hechos en lenguajes distintos.

### Paso 4. Recibe el pedido y valídalo

En `pedidos/src/index.ts`, agrega este `import` junto a los otros:

```ts
import { buscarProducto, Producto } from "./menu";
```

La ruta va en cuatro partes. Borra el comentario `TODO bloque 3` y en su lugar escribe la primera:

```ts
// Lo que manda el cliente al hacer un pedido
interface PedidoNuevo {
  cliente?: string;
  productos?: { id: number; cantidad: number }[];
}

app.post("/pedidos", async (req, res) => {
  const { cliente, productos } = req.body as PedidoNuevo;

  // 1. Validar lo que llegó
  if (!cliente || !Array.isArray(productos) || productos.length === 0) {
    res.status(400).json({ error: "Manda el cliente y al menos un producto" });
    return;
  }

  // Aquí van las partes 2, 3 y 4
});
```

Cada parte que sigue va donde dice `// Aquí van las partes 2, 3 y 4`, una debajo de la otra.

## Tu turno

### Reto. Pregúntale al menú por cada producto

En pareja, como en el bloque 1. Es la parte 2. Por cada producto que trae el pedido, pregúntale al menú con `buscarProducto(item.id)`:

- Si el menú no responde, `buscarProducto` lanza un error: responde 503 con `{ error: "El servicio de menú no está disponible" }`.
- Si el producto no existe, regresa `null`: responde 400 y di cuál producto no existe.
- Si existe, guárdalo junto con su cantidad en `lineas`. Esa lista se usa después para el total y para guardar el pedido.

Empieza con esta línea:

```ts
  const lineas: { producto: Producto; cantidad: number }[] = [];
```

Pistas:

- Recorre los productos con `for (const item of productos)`.
- Pon el `await buscarProducto(item.id)` dentro de un `try { ... } catch { ... }`. El 503 va en el `catch`.
- Ojo: si declaras `producto` adentro del `try`, afuera no existe. Declárala antes: `let producto: Producto | null;`
- Después de responder con `res.status(...).json(...)`, pon `return;` para que la ruta no siga.
- Para guardar en la lista: `lineas.push({ producto, cantidad: item.cantidad })`.

Para probarlo, pon por mientras `res.json(lineas);` al final de tu parte y manda **Hacer un pedido**: deben salir el café y el burrito con su precio. También puedes correr `./revisar.sh 3`: en este reto deben salir OK las primeras tres pruebas, y las demás hasta que se hagan los pasos 5 y 6. Luego borra ese `res.json(lineas);`.

<details>
<summary>Ver la solución (primero inténtalo)</summary>

```ts
  // 2. Preguntarle al menú por cada producto: un microservicio llamando a otro por REST
  const lineas: { producto: Producto; cantidad: number }[] = [];
  for (const item of productos) {
    let producto: Producto | null;
    try {
      producto = await buscarProducto(item.id);
    } catch {
      res.status(503).json({ error: "El servicio de menú no está disponible" });
      return;
    }

    if (!producto) {
      res.status(400).json({ error: `El producto ${item.id} no existe en el menú` });
      return;
    }
    lineas.push({ producto, cantidad: item.cantidad });
  }
```

El precio se toma del menú, no de lo que manda el cliente. Si no, cualquiera podría pedir un burrito a 1 peso.

</details>

## Otra vez en el proyector

### Paso 5. Calcula el total

```ts
  // 3. Calcular el total con los precios que dio el menú
  const total = lineas.reduce((suma, l) => suma + l.producto.precio * l.cantidad, 0);
```

### Paso 6. Guarda el pedido con una transacción

**Antes de verla, ordénala.** Estos son los pasos de la transacción, revueltos. Platícalo con tu pareja: ¿en qué orden van?

- `commit()`: guarda todo junto
- `INSERT INTO PedidoDetalle`, una vez por cada producto
- `begin()`: abre la transacción
- `rollback()`: deshace todo si algo falla
- `INSERT INTO Pedidos`, que regresa el `Id` del pedido nuevo

<details>
<summary>Ver el orden</summary>

1. `begin()`
2. `INSERT INTO Pedidos`: va primero porque el detalle necesita su `Id`
3. `INSERT INTO PedidoDetalle`, una vez por cada producto
4. `commit()`

Si algo falla en el paso 2 o en el 3, `rollback()` deshace todo.

</details>

Ahora sí, el código:

```ts
  // 4. Guardar el pedido y su detalle en UNA transacción: se guarda todo o nada
  const pool = await obtenerPool();
  const transaccion = new sql.Transaction(pool);
  await transaccion.begin();

  try {
    const resultado = await transaccion.request()
      .input("cliente", sql.NVarChar(100), cliente)
      .input("total", sql.Decimal(10, 2), total)
      .query("INSERT INTO Pedidos (Cliente, Total) OUTPUT INSERTED.Id VALUES (@cliente, @total)");
    const pedidoId: number = resultado.recordset[0].Id;

    for (const { producto, cantidad } of lineas) {
      await transaccion.request()
        .input("pedidoId", sql.Int, pedidoId)
        .input("productoId", sql.Int, producto.id)
        .input("nombre", sql.NVarChar(100), producto.nombre)
        .input("cantidad", sql.Int, cantidad)
        .input("precio", sql.Decimal(10, 2), producto.precio)
        .query(`
          INSERT INTO PedidoDetalle (PedidoId, ProductoId, Nombre, Cantidad, PrecioUnitario)
          VALUES (@pedidoId, @productoId, @nombre, @cantidad, @precio)
        `);
    }

    await transaccion.commit();

    res.status(201).json({
      id: pedidoId,
      cliente,
      total,
      productos: lineas.map(({ producto, cantidad }) => ({
        id: producto.id,
        nombre: producto.nombre,
        cantidad,
        precio: producto.precio,
      })),
    });
  } catch (error) {
    await transaccion.rollback(); // se deshace TODO lo que se alcanzó a guardar

    // 547 = SQL Server rechazó un dato por una regla de la tabla (aquí, Cantidad > 0)
    if (error instanceof sql.RequestError && error.number === 547) {
      res.status(400).json({ error: "La base de datos rechazó el pedido: la cantidad debe ser mayor a 0" });
      return;
    }
    throw error;
  }
```

Al final borra el comentario `// Aquí van las partes 2, 3 y 4`.

- `begin()` abre la transacción. Si todos los `INSERT` salen bien, `commit()` los guarda juntos. Si alguno falla, `rollback()` los deshace todos.
- `@cliente`, `@total` y los demás son parámetros. El texto del usuario nunca se pega dentro del SQL, y así se evita la inyección SQL.

## Pruébalo

Manda las peticiones de `pedidos/pedidos.http`:

1. **Pedido de Ana:** debe dar 201 y un total de 120 (2 cafés de 30 y 1 burrito de 60).
2. **Producto que no existe:** debe dar 400.
3. **Pedido de Sofía, con cantidad en 0.** Antes de mandarlo, predice: su café sí venía bien, ¿se va a guardar? Mándalo: debe dar 400. Luego manda **Todos los pedidos**: el de Sofía no aparece, y su café tampoco quedó guardado. Eso es la transacción: todo o nada.
4. **Menú apagado.** Predice: si el menú no responde, ¿qué le contesta pedidos al cliente? Detén el menú con **Ctrl+C** en su terminal y vuelve a mandar el pedido de Ana: debe dar 503. Después vuelve a arrancar el menú.

Al final corre `./revisar.sh 3`: repite estas pruebas, menos la del menú apagado.

**Para pensar:** sin la transacción, ¿qué habría quedado guardado del pedido de Sofía?
