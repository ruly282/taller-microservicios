using Menu;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// Datos de ejemplo en memoria. En el bloque 2 se van a SQL Server.
var productos = new List<Producto>
{
    new() { Id = 1, Nombre = "Café americano", Precio = 30 },
    new() { Id = 2, Nombre = "Capuchino", Precio = 45 },
    new() { Id = 3, Nombre = "Burrito de machaca", Precio = 60 },
    new() { Id = 4, Nombre = "Coyota", Precio = 25 },
};

app.MapGet("/", () => "Servicio de menú funcionando");

// TODO bloque 1:
//   GET    /productos       todos los productos
//   GET    /productos/{id}  un producto, o 404 si no existe
//   POST   /productos       agrega uno; 400 si falta el nombre o el precio no es mayor a 0
//   DELETE /productos/{id}  lo borra, o 404 si no existe

app.Run();
