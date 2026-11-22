using Microsoft.EntityFrameworkCore;

namespace Menu;

// El "contexto" de Entity Framework: representa la base de datos del menú.
public class MenuDb : DbContext
{
    public MenuDb(DbContextOptions<MenuDb> opciones) : base(opciones) { }

    // Cada DbSet es una tabla. Esta se llama Productos.
    public DbSet<Producto> Productos => Set<Producto>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Datos con los que arranca la tabla la primera vez
        modelBuilder.Entity<Producto>().HasData(
            new Producto { Id = 1, Nombre = "Café americano", Precio = 30 },
            new Producto { Id = 2, Nombre = "Capuchino", Precio = 45 },
            new Producto { Id = 3, Nombre = "Burrito de machaca", Precio = 60 },
            new Producto { Id = 4, Nombre = "Coyota", Precio = 25 });
    }
}
