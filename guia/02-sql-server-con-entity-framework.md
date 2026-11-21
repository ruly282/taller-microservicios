# 2. SQL Server con Entity Framework

**Meta:** que el menú guarde sus productos en SQL Server sin escribir SQL a mano.

Si no terminaste el bloque 1: `./punto-de-control.sh 2`

En el proyector se levanta la base y se pasa a SQL Server la ruta de todos los productos. Las otras tres te tocan a ti.

## En el proyector

### Paso 1. Levanta SQL Server

En una terminal nueva, en la carpeta principal del proyecto:

```bash
docker compose up -d sqlserver
docker compose ps
```

Repite `docker compose ps` hasta que diga **healthy**, unos 30 segundos. SQL Server corre en un contenedor de Docker: no se instaló nada.

### Paso 2. Revisa `menu/MenuDb.cs` (ya viene hecho)

- `MenuDb` hereda de `DbContext`: representa la base de datos del menú.
- `DbSet<Producto> Productos` es la tabla `Productos`.
- `HasData` mete los 4 productos de inicio la primera vez que se crea la tabla.

### Paso 3. Ajusta `menu/Producto.cs`

Déjalo así:

```csharp
using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;

namespace Menu;

public class Producto
{
    public int Id { get; set; }

    [MaxLength(100)]
    public string Nombre { get; set; } = "";

    // Dinero: 10 dígitos en total y 2 decimales, como DECIMAL(10, 2) en SQL Server
    [Precision(10, 2)]
    public decimal Precio { get; set; }
}
```

Sin `[Precision]`, Entity Framework no sabe cuántos decimales guardar y te lo avisa con un warning.

### Paso 4. Conecta el menú con la base en `menu/Program.cs`

Arriba, junto al otro `using`:

```csharp
using Microsoft.EntityFrameworkCore;
```

Justo después de `var builder = WebApplication.CreateBuilder(args);`:

```csharp
builder.Services.AddDbContext<MenuDb>(opciones =>
    opciones.UseSqlServer(builder.Configuration.GetConnectionString("MenuDb")));
```

La cadena de conexión no está en el código, está en `appsettings.Development.json`. En el bloque 4, Docker se la va a pasar con una variable de entorno.

Justo después de `var app = builder.Build();`:

```csharp
await BaseDeDatos.PrepararAsync(app);
```

Eso crea la base y la tabla si no existen. `BaseDeDatos.cs` ya viene hecho.

### Paso 5. Todos los productos, ahora desde la base

Cambia solo la ruta de todos los productos por esta:

```csharp
app.MapGet("/productos", async (MenuDb db) =>
    await db.Productos.OrderBy(p => p.Id).ToListAsync());
```

`MenuDb db` te llega sin que lo crees: ASP.NET Core lo hace por ti. A eso se le llama inyección de dependencias.

Corre `dotnet run` y manda **Todos los productos**. En la terminal vas a ver el SQL que Entity Framework escribe por ti: `CREATE TABLE`, `SELECT`, `INSERT`...

## Tu turno

Pasa las otras tres rutas a la base:

- **Un producto:** en lugar de buscarlo en la lista, búscalo con `await db.Productos.FindAsync(id)`.
- **Agregar:** la misma validación de antes. Luego `db.Productos.Add(producto)` y `await db.SaveChangesAsync()`.
- **Borrar:** búscalo con `FindAsync`, y luego `db.Productos.Remove(producto)` y `await db.SaveChangesAsync()`.

Cuando termines, borra la lista `productos`: ya no se usa.

Pistas:

- Cada ruta recibe `MenuDb db` como un parámetro más y se vuelve `async`, igual que la del paso 5.
- `Add` y `Remove` solo preparan el cambio. `SaveChangesAsync` es lo que lo manda a SQL Server.
- Al agregar, pon `producto.Id = 0` antes del `Add`: el `Id` lo pone SQL Server.

<details>
<summary>Ver la solución (primero inténtalo)</summary>

```csharp
app.MapGet("/productos/{id:int}", async (int id, MenuDb db) =>
    await db.Productos.FindAsync(id) is Producto producto
        ? Results.Ok(producto)
        : Results.NotFound(new { error = $"No existe el producto {id}" }));

app.MapPost("/productos", async (Producto producto, MenuDb db) =>
{
    if (string.IsNullOrWhiteSpace(producto.Nombre))
        return Results.BadRequest(new { error = "El nombre es obligatorio" });
    if (producto.Precio <= 0)
        return Results.BadRequest(new { error = "El precio debe ser mayor a 0" });

    producto.Id = 0; // el Id lo pone SQL Server
    db.Productos.Add(producto);
    await db.SaveChangesAsync();
    return Results.Created($"/productos/{producto.Id}", producto);
});

app.MapDelete("/productos/{id:int}", async (int id, MenuDb db) =>
{
    var producto = await db.Productos.FindAsync(id);
    if (producto is null)
        return Results.NotFound(new { error = $"No existe el producto {id}" });

    db.Productos.Remove(producto);
    await db.SaveChangesAsync();
    return Results.NoContent();
});
```

</details>

## Pruébalo

Reinicia el servicio y manda todas las peticiones de `menu/menu.http`.

**Para pensar:** agrega un producto, detén el servicio y vuelve a correrlo. Ahora sí sigue ahí.
