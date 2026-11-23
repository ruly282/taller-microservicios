# 1. API REST en C#

**Meta:** crear desde cero el servicio de menú, con estas rutas. Por ahora los productos se guardan en memoria.

| Método | Ruta | Responde |
| --- | --- | --- |
| GET | `/productos` | Todos los productos (200) |
| GET | `/productos/{id}` | Un producto (200), o 404 si no existe |
| POST | `/productos` | Agrega uno (201), o 400 si los datos vienen mal |
| DELETE | `/productos/{id}` | Lo borra (204), o 404 si no existe |

El código lo escribes siguiendo el proyector. Todo el servicio va en un solo archivo: `menu/Program.cs`.

## Paso 1. Crea el proyecto

En la terminal **menu**:

```bash
dotnet new web -o menu
cd menu
```

Se crea la carpeta `menu` con un proyecto de ASP.NET Core vacío.

## Paso 2. Tu primera ruta

En `menu/Program.cs`: una ruta `GET /` que responde "Menú de la cafetería", y el servidor en el puerto 5000.

Córrelo en la terminal **menu** con `dotnet run`. Debe decir `Now listening on: http://localhost:5000`.

Pruébalo: abre `pruebas/menu.http` y dale **Send Request** arriba de **Inicio**.

Para detenerlo: **Ctrl+C**. Cada vez que cambies el código: Ctrl+C y otra vez `dotnet run`.

## Paso 3. El producto y la lista

Hasta abajo de `Program.cs`, la clase `Producto`, con `Id`, `Nombre` y `Precio`. Y arriba, una lista con 4 productos:

| Id | Nombre | Precio |
| --- | --- | --- |
| 1 | Café americano | 30 |
| 2 | Capuchino | 45 |
| 3 | Burrito de machaca | 60 |
| 4 | Coyota | 25 |

## Paso 4. Todos los productos

La ruta `GET /productos`. Cada ruta nueva va antes de `app.Run`.

Pruébalo: **Todos los productos**. Debe dar 200 con los 4 productos.

## Paso 5. Un producto

La ruta `GET /productos/{id}`: si el producto existe, 200; si no, 404.

**Predice:** ¿qué va a responder **Un producto que no existe**? Mándala y compara.

## Paso 6. Agregar un producto

La ruta `POST /productos`. Si falta el nombre o el precio no es mayor a 0, responde 400 y dice por qué. Si todo está bien, 201.

Pruébalo con **Agregar un producto** (201) y **Producto sin nombre** (400).

## Paso 7. Borrar un producto

La ruta `DELETE /productos/{id}`: 204 si lo borró y 404 si no existe.

Pruébalo: manda **Agregar un producto** y luego **Borrar el producto que acabas de agregar**.

## Revisa tu bloque

Con el menú corriendo, en la terminal **comandos**:

```bash
./revisar.sh 1
```

**Predice:** si agregas un producto y reinicias el menú, ¿sigue ahí? Pruébalo.
