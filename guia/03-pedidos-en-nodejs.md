# 3. Pedidos en Node.js

**Meta:** crear desde cero el servicio de pedidos, en Node.js con TypeScript. Recibe un pedido, le pregunta al menú por HTTP cuánto cuesta cada producto y lo guarda en su propia base.

| Método | Ruta | Responde |
| --- | --- | --- |
| GET | `/pedidos` | Todos los pedidos (200) |
| POST | `/pedidos` | Guarda el pedido (201), 400 si viene mal o 503 si el menú no responde |

Si no terminaste el bloque 2, en la terminal **comandos**: `./punto-de-control.sh 3`

Todo el servicio va en un solo archivo: `pedidos/index.ts`.

## Paso 1. Ten arriba lo de antes

Pedidos va a necesitar a SQL Server y al menú:

1. En la terminal **comandos**, `docker compose ps` debe decir **healthy**. Si no aparece nada: `docker compose up -d`.
2. En la terminal **menu**, el menú corriendo con `dotnet run`.

## Paso 2. Crea el proyecto

En la terminal **pedidos**, una línea a la vez:

```bash
mkdir pedidos
cd pedidos
npm init -y
npm pkg set type=module scripts.dev="tsx watch index.ts"
npm install express mssql
npm install -D tsx @types/express @types/mssql @types/node
```

- `npm init -y` crea `package.json`, la ficha del proyecto.
- `npm pkg set` le dice que use `import` y le agrega el script `dev`: `tsx` corre TypeScript directo y reinicia el servicio cada vez que guardas.
- `express` es el servidor web y `mssql` habla con SQL Server.
- Con `-D` van las que solo se usan para programar: `tsx` y los tipos, para que el editor te ayude con TypeScript.

## Paso 3. La configuración de TypeScript

Adentro de `pedidos`, el archivo `tsconfig.json`. Le dice al editor cómo revisar tu código: TypeScript moderno, en modo estricto y con los tipos de Node.js.

## Paso 4. La base de pedidos

En `pedidos/index.ts`:

- La conexión a SQL Server.
- Que cree la base `PedidosDb` y su tabla `Pedidos` si todavía no existen. Es T-SQL normal.

Las columnas van en minúsculas (`id`, `cliente`, `total`, `fecha`) para que el JSON salga igual que el del menú.

## Paso 5. El servidor y la lista de pedidos

En `pedidos/index.ts`: Express, la ruta `GET /pedidos` y, hasta abajo, el servidor en el puerto 3000.

Córrelo en la terminal **pedidos**:

```bash
npm run dev
```

Debe decir `Pedidos escuchando en el puerto 3000`. Abre `pruebas/pedidos.http` y manda **Todos los pedidos**: sale `[]`, todavía no hay ninguno.

Desde aquí ya no tienes que reiniciar: cada vez que guardas, se reinicia solo.

## Paso 6. Recibir un pedido

La ruta `POST /pedidos`, en 4 partes:

1. **Valida lo que llegó:** sin cliente, sin productos o con una cantidad menor a 1, responde 400.
2. **Le pregunta al menú por cada producto** con `fetch`. Si el menú no contesta: 503. Si contesta que el producto no existe: 400.
3. **Calcula el total** con el precio que da el menú, nunca con uno que mande el cliente.
4. **Guarda el pedido** con parámetros, para que nadie pueda meter SQL en el nombre del cliente (inyección SQL). Responde 201 con el pedido guardado.

Mientras escribes, la terminal de pedidos se llena de errores: es normal. Se reinicia con cada guardado y se arregla al terminar el paso.

## Pruébalo

Manda, de `pruebas/pedidos.http`:

1. **Hacer un pedido:** 201 y un total de 120, porque son 2 × 30 + 1 × 60.
2. **Producto que no existe en el menú:** 400.
3. **Cantidad en 0:** 400.
4. **Predice:** si el menú no está corriendo, ¿qué le responde pedidos al cliente? Detén el menú con Ctrl+C en su terminal y vuelve a mandar **Hacer un pedido**. Después vuelve a arrancar el menú.

## Revisa tu bloque

Con el menú y pedidos corriendo, en la terminal **comandos**:

```bash
./revisar.sh 3
```

**Para pensar:** la base del menú está en el mismo SQL Server. ¿Por qué pedidos le pregunta los precios al menú por HTTP en lugar de leer su tabla directo?

## Para seguir practicando en tu casa

Si quieres ver el proyecto terminado: `./punto-de-control.sh final`.

- En el menú, una ruta `PUT /productos/{id}` para cambiar el precio.
- En pedidos, `GET /pedidos/{id}` para ver un solo pedido.
- Guardar también qué productos llevó cada pedido, en otra tabla, y hacerlo con una transacción para que se guarde todo o nada.
- Meter cada servicio en su propio contenedor, con un `Dockerfile`, y levantar todo junto con Docker Compose.
- Que pedidos le avise a una cocina de cada pedido nuevo con mensajes, por ejemplo con RabbitMQ.
