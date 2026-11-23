# 0. Antes de empezar

## Abre tu Codespace

1. En la página del repositorio: botón verde **Code** → pestaña **Codespaces** → **Create codespace on main**.
2. Se abre VS Code en el navegador. En la terminal de abajo se está preparando todo: espera a que diga **Listo, ya puedes empezar.**

No instalas nada en la computadora del laboratorio: todo corre en una máquina en la nube que ya trae .NET, Node.js y Docker.

## Qué trae el proyecto

| Carpeta o archivo | Qué es |
| --- | --- |
| `guia/` | Esta guía |
| `pruebas/` | Peticiones para probar los servicios |
| `revisar.sh` | Revisa si tu bloque ya funciona |
| `punto-de-control.sh` | Te lleva al inicio de un bloque si te atoras |

No trae código de los servicios: ese lo vas a escribir tú.

## Terminales

Vas a usar tres. Ábrelas con el **+** de la terminal y, si quieres, ponles nombre con clic derecho → **Rename**:

1. **menu**: donde corre el servicio de menú.
2. **pedidos**: donde corre el servicio de pedidos.
3. **comandos**: para Docker, `revisar.sh` y lo demás.

Las tres abren en la carpeta principal del proyecto. Para detener un servicio: **Ctrl+C**.

## Cómo vas a probar las APIs

Abre `pruebas/menu.http` o `pruebas/pedidos.http`. Arriba de cada petición vas a ver **Send Request**. Al darle clic, la respuesta sale a la derecha con su código: 200, 404, etc.
