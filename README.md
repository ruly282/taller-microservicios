# Taller: Microservicios con .NET, Node.js y Docker

Backend de una cafetería con dos microservicios:

| Servicio | Tecnología | Qué hace | Puerto |
| --- | --- | --- | --- |
| `menu/` | C# con ASP.NET Core y Entity Framework | Productos y precios | 5000 |
| `pedidos/` | Node.js con TypeScript y Express | Recibe pedidos, le pregunta al menú por REST y los guarda con una transacción | 3000 |

Los dos guardan sus datos en SQL Server, cada uno en su propia base.

## Cómo empezar

1. En esta página, botón verde **Code** → pestaña **Codespaces** → **Create codespace on main**.
2. Espera a que termine de prepararse. La primera vez tarda unos minutos.
3. Se abre la guía del taller, [`guia/README.md`](guia/README.md). Síguela bloque por bloque.

No hay que instalar nada: todo corre en el navegador.

## Puntos de control

Si te atoras, escribe en la terminal:

```bash
./punto-de-control.sh 2
```

Eso te lleva al inicio del bloque 2 con todo lo anterior ya funcionando. Lo que llevabas se guarda con `git stash`.

| Punto de control | Qué trae |
| --- | --- |
| `1` | El punto de partida |
| `2` | La API del menú funcionando con datos en memoria |
| `3` | El menú guardando en SQL Server con Entity Framework |
| `4` | El servicio de pedidos terminado |
| `final` | Todo corriendo en Docker Compose |
| `extra` | Lo anterior más RabbitMQ: pedidos le avisa a cocina de cada pedido nuevo |

## Datos de desarrollo

La contraseña de SQL Server está en `.env` y en `menu/appsettings.Development.json`. Es solo para el taller: en un proyecto real esos datos no se suben al repositorio, van en un gestor de secretos.
