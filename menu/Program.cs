using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// SQL Server corre en Docker, aquí mismo en el Codespace
var conexion = "Server=localhost;Database=MenuDb;User Id=sa;Password=TallerCafe_2026;TrustServerCertificate=true";
builder.Services.AddDbContext<MenuDb>(opciones => opciones.UseSqlServer(conexion));

var app = builder.Build();

// Crea la base y la tabla si todavía no existen
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<MenuDb>();
    await db.Database.EnsureCreatedAsync();
}

app.MapGet("/", () => "Menú de la cafetería");

app.MapGet("/productos", async (MenuDb db) => await db.Productos.ToListAsync());

app.MapGet("/productos/{id}", async (int id, MenuDb db) =>
{
    var producto = await db.Productos.FindAsync(id);
    return producto is null ? Results.NotFound() : Results.Ok(producto);
});

app.MapPost("/productos", async (Producto nuevo, MenuDb db) =>
{
    if (string.IsNullOrWhiteSpace(nuevo.Nombre) || nuevo.Precio <= 0)
        return Results.BadRequest(new { error = "Falta el nombre o el precio no es válido" });

    db.Productos.Add(nuevo);
    await db.SaveChangesAsync();
    return Results.Created($"/productos/{nuevo.Id}", nuevo);
});

app.MapDelete("/productos/{id}", async (int id, MenuDb db) =>
{
    var producto = await db.Productos.FindAsync(id);
    if (producto is null) return Results.NotFound();

    db.Productos.Remove(producto);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

app.Run("http://localhost:5000");

class Producto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";

    [Precision(10, 2)]
    public decimal Precio { get; set; }
}

// La base de datos del menú. Cada DbSet es una tabla.
class MenuDb(DbContextOptions<MenuDb> opciones) : DbContext(opciones)
{
    public DbSet<Producto> Productos => Set<Producto>();

    // Los productos con los que arranca la tabla
    protected override void OnModelCreating(ModelBuilder modelo)
    {
        modelo.Entity<Producto>().HasData(
            new Producto { Id = 1, Nombre = "Café americano", Precio = 30 },
            new Producto { Id = 2, Nombre = "Capuchino", Precio = 45 },
            new Producto { Id = 3, Nombre = "Burrito de machaca", Precio = 60 },
            new Producto { Id = 4, Nombre = "Coyota", Precio = 25 }
        );
    }
}
