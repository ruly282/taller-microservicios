# Taller: Microservicios con .NET, Node.js y Docker

En este taller haces desde cero el backend de una cafetería con dos microservicios:

| Servicio | Tecnología | Qué hace | Puerto |
| --- | --- | --- | --- |
| `menu/` | C# con ASP.NET Core y Entity Framework | Productos y precios | 5000 |
| `pedidos/` | Node.js con TypeScript y Express | Recibe pedidos y le pregunta al menú los precios por HTTP | 3000 |

Cada uno guarda sus datos en su propia base, dentro del mismo SQL Server, que corre en Docker.

## Cómo empezar

1. En esta página, botón verde **Code** → pestaña **Codespaces** → **Create codespace on main**.
2. Espera a que la terminal diga **Listo, ya puedes empezar**. La primera vez tarda unos minutos.
3. Se abre la guía del taller, [`guia/README.md`](guia/README.md). Síguela bloque por bloque.

No hay que instalar nada: todo corre en el navegador. El proyecto empieza sin código: lo vas escribiendo en el taller.

## Revisar lo que llevas

Al terminar cada bloque, en una terminal:

```bash
./revisar.sh 1
```

Cambia el `1` por el número del bloque. Le hace peticiones a tus servicios y te dice qué ya funciona y qué falta.

## Puntos de control

Si te atoras, al empezar un bloque escribe en la terminal:

```bash
./punto-de-control.sh 3
```

Eso te lleva al inicio del bloque 3 con todo lo anterior ya funcionando. Lo que llevabas se guarda con `git stash`.

| Punto de control | Qué trae |
| --- | --- |
| `2` | El menú con datos en memoria (bloque 1 terminado) |
| `3` | El menú guardando en SQL Server con Entity Framework (bloque 2 terminado) |
| `final` | El servicio de pedidos (bloque 3 terminado) |

## Datos de desarrollo

La contraseña de SQL Server está en `compose.yaml` y en el código de los dos servicios. Es solo para el taller: en un proyecto real va en un gestor de secretos y no se sube al repositorio.
