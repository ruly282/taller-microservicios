# 1. API REST en C#

**Meta:** que el servicio de menú responda estas cuatro rutas. Por ahora los productos se guardan en memoria.

| Método | Ruta | Responde |
| --- | --- | --- |
| GET | `/productos` | Todos los productos (200) |
| GET | `/productos/{id}` | Un producto (200), o 404 si no existe |
| POST | `/productos` | Agrega uno (201), o 400 si los datos vienen mal |
| DELETE | `/productos/{id}` | Lo borra (204), o 404 si no existe |

## Paso 1. Arranca el servicio

```bash
cd menu
dotnet run
```

Debe decir `Now listening on: http://localhost:5000`. Abre `menu/menu.http` y manda **Todos los productos**: sale 404, porque esa ruta todavía no existe.

Cada vez que cambies el código: **Ctrl+C** y otra vez `dotnet run`.

## Paso 2. Todos los productos

Abre `menu/Program.cs`. Ya trae una lista con 4 productos de ejemplo. Abajo de `app.MapGet("/", ...)` agrega:

```csharp
app.MapGet("/productos", () => productos);
```

ASP.NET Core convierte la lista a JSON por ti.

## Paso 3. Un producto

```csharp
app.MapGet("/productos/{id:int}", (int id) =>
    productos.FirstOrDefault(p => p.Id == id) is Producto producto
        ? Results.Ok(producto)
        : Results.NotFound(new { error = $"No existe el producto {id}" }));
```

- `{id:int}` solo acepta números.
- `Results.Ok` responde 200 y `Results.NotFound` responde 404.

## Paso 4. Agregar un producto

```csharp
app.MapPost("/productos", (Producto producto) =>
{
    if (string.IsNullOrWhiteSpace(producto.Nombre))
        return Results.BadRequest(new { error = "El nombre es obligatorio" });
    if (producto.Precio <= 0)
        return Results.BadRequest(new { error = "El precio debe ser mayor a 0" });

    producto.Id = productos.Count == 0 ? 1 : productos.Max(p => p.Id) + 1;
    productos.Add(producto);
    return Results.Created($"/productos/{producto.Id}", producto);
});
```

- El producto llega en el cuerpo de la petición, en JSON, y ASP.NET Core lo convierte a un `Producto`.
- Si los datos vienen mal se responde 400 y se explica por qué. Nunca confíes en lo que manda el cliente.
- `Results.Created` responde 201 y dice en qué ruta quedó el producto nuevo.

## Paso 5. Borrar un producto

```csharp
app.MapDelete("/productos/{id:int}", (int id) =>
{
    var producto = productos.FirstOrDefault(p => p.Id == id);
    if (producto is null)
        return Results.NotFound(new { error = $"No existe el producto {id}" });

    productos.Remove(producto);
    return Results.NoContent();
});
```

204 quiere decir "listo, y no hay nada que regresarte".

## Pruébalo

Reinicia el servicio y manda, en orden, todas las peticiones de `menu/menu.http`. Cada una dice qué código debe dar.

**Para pensar:** agrega un producto, detén el servicio y vuelve a correrlo. ¿Sigue ahí? No, porque estaba en memoria. Eso se arregla en el bloque 2.
