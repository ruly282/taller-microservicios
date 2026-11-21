# 0. Antes de empezar

## Abre tu Codespace

1. En la página del repositorio: botón verde **Code** → pestaña **Codespaces** → **Create codespace on main**.
2. Se abre VS Code en el navegador. En la terminal de abajo se está preparando todo: espera a que diga **Listo, ya puedes empezar.**

No instalas nada en la computadora del laboratorio: todo corre en una máquina en la nube.

## Conoce el proyecto

| Carpeta o archivo | Qué es |
| --- | --- |
| `menu/` | Servicio de menú en C# |
| `pedidos/` | Servicio de pedidos en Node.js con TypeScript |
| `compose.yaml` | Los contenedores de Docker: por ahora solo SQL Server |
| `guia/` | Esta guía |

## Cómo vas a probar las APIs

Cada servicio trae un archivo `.http`: `menu/menu.http` y `pedidos/pedidos.http`. Ábrelo y arriba de cada petición vas a ver **Send Request**. Al darle clic, la respuesta sale a la derecha con su código: 200, 404, etc.

## Terminales

Vas a usar varias al mismo tiempo. Para abrir otra, dale al **+** de la terminal. Para detener un servicio, **Ctrl+C**.
