var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Por ahora los productos viven en memoria: se pierden al reiniciar
var productos = new List<Producto>
{
    new Producto { Id = 1, Nombre = "Café americano", Precio = 30 },
    new Producto { Id = 2, Nombre = "Capuchino", Precio = 45 },
    new Producto { Id = 3, Nombre = "Burrito de machaca", Precio = 60 },
    new Producto { Id = 4, Nombre = "Coyota", Precio = 25 }
};
var siguienteId = 5;

app.MapGet("/", () => "Menú de la cafetería");

app.MapGet("/productos", () => productos);

app.MapGet("/productos/{id}", (int id) =>
{
    var producto = productos.Find(p => p.Id == id);
    return producto is null ? Results.NotFound() : Results.Ok(producto);
});

app.MapPost("/productos", (Producto nuevo) =>
{
    if (string.IsNullOrWhiteSpace(nuevo.Nombre) || nuevo.Precio <= 0)
        return Results.BadRequest(new { error = "Falta el nombre o el precio no es válido" });

    nuevo.Id = siguienteId++;
    productos.Add(nuevo);
    return Results.Created($"/productos/{nuevo.Id}", nuevo);
});

app.MapDelete("/productos/{id}", (int id) =>
{
    var producto = productos.Find(p => p.Id == id);
    if (producto is null) return Results.NotFound();

    productos.Remove(producto);
    return Results.NoContent();
});

app.Run("http://localhost:5000");

class Producto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public decimal Precio { get; set; }
}
