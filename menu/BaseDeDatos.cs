namespace Menu;

public static class BaseDeDatos
{
    // Crea la base de datos y la tabla si no existen.
    // SQL Server tarda unos segundos en arrancar, así que se intenta varias veces antes de rendirse.
    public static async Task PrepararAsync(WebApplication app)
    {
        using var scope = app.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<MenuDb>();

        for (var intento = 1; ; intento++)
        {
            try
            {
                await db.Database.EnsureCreatedAsync();
                app.Logger.LogInformation("Base de datos del menú lista");
                return;
            }
            catch (Exception ex) when (intento < 20)
            {
                app.Logger.LogWarning("SQL Server todavía no responde (intento {Intento}): {Mensaje}", intento, ex.Message);
                await Task.Delay(TimeSpan.FromSeconds(3));
            }
        }
    }
}
