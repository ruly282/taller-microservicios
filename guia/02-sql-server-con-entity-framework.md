# 2. SQL Server con Entity Framework

**Meta:** que el menú guarde sus productos en SQL Server, sin escribir SQL a mano.

Si no terminaste el bloque 1, en la terminal **comandos**: `./punto-de-control.sh 2`

## Paso 1. SQL Server en Docker

En la carpeta principal del proyecto (no adentro de `menu`) se crea el archivo `compose.yaml`, con el servicio `sqlserver`. Cuida la sangría: en YAML los espacios importan.

En la terminal **comandos**:

```bash
docker compose up -d
docker compose ps
```

Repite `docker compose ps` hasta que diga **healthy**, unos 30 segundos. SQL Server corre en un contenedor: no se instaló nada.

## Paso 2. Instala Entity Framework

En la terminal **menu**, detén el servicio con Ctrl+C y escribe:

```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 10.0.15
```

Va con `--version` porque la versión más nueva es para .NET 11, y tu proyecto es de .NET 10. Fíjate en `menu.csproj`: ahí quedó el paquete.

## Paso 3. La base de datos en código

En `menu/Program.cs`:

- Hasta arriba, el `using` de Entity Framework.
- En `Producto`, el precio con 2 decimales, como `DECIMAL(10, 2)` en SQL Server.
- Abajo de `Producto`, la clase `MenuDb`, que representa la base. Su tabla es `Productos`.
- Los 4 productos se pasan de la lista a la base: se meten la primera vez que se crea la tabla. La lista ya no se usa.

## Paso 4. Conecta el menú con la base

En `menu/Program.cs`:

- La cadena de conexión: dónde está SQL Server, qué base usar y con qué usuario.
- Al arrancar, que se creen la base y la tabla si todavía no existen.

La contraseña va en el código solo para no complicarnos en el taller. En una empresa va en un gestor de secretos.

## Paso 5. Las rutas, ahora con la base

Las 4 rutas usan la base en lugar de la lista:

- Cada ruta recibe la base como parámetro, y ASP.NET Core se la da. A eso se le llama inyección de dependencias.
- `async` y `await`: mientras espera a la base, el servidor puede atender otras peticiones.
- `Add` y `Remove` solo preparan el cambio. `SaveChangesAsync` es lo que lo manda a SQL Server.
- El `Id` ya lo pone SQL Server.

## Pruébalo

**Predice:** la base y la tabla todavía no existen. ¿Qué crees que pase cuando arranque el menú?

En la terminal **menu**: `dotnet run`. En la terminal vas a ver el SQL que Entity Framework escribe por ti: `CREATE DATABASE`, `CREATE TABLE`, `INSERT`...

Manda **Todos los productos** y **Agregar un producto**. Luego reinicia el menú y vuelve a pedir todos: ahora el producto nuevo sí sigue ahí.

## Revisa tu bloque

Con el menú corriendo, en la terminal **comandos**:

```bash
./revisar.sh 2
```
