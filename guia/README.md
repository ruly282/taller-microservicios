# Guía del taller

| Bloque | Hora | Qué vas a hacer |
| --- | --- | --- |
| [0. Antes de empezar](00-antes-de-empezar.md) | 10:00 | Abres tu Codespace |
| [1. API REST en C#](01-api-rest-en-csharp.md) | 10:15 | Creas el servicio de menú con ASP.NET Core |
| [2. SQL Server con Entity Framework](02-sql-server-con-entity-framework.md) | 11:00 | El menú guarda sus productos en una base de datos |
| Descanso | 11:45 | |
| [3. Pedidos en Node.js](03-pedidos-en-nodejs.md) | 11:55 | Creas el servicio de pedidos, que le pregunta al menú |
| Cierre | 12:45 | Lo que sigue y preguntas |

## Cómo va el taller

El proyecto empieza vacío. En el proyector se escribe todo el código paso a paso, explicando qué hace cada parte, y tú lo vas escribiendo igual en tu Codespace. Al terminar cada paso se prueba.

Esta guía no trae el código: trae los pasos, para que sepas en cuál vamos, en qué archivo va cada cosa y cómo probarla. Solo vienen los comandos de la terminal, porque son largos.

- **Escríbelo tú, siguiendo el proyector:** así se te queda.
- **Predice:** antes de correr algo se pregunta qué crees que va a pasar. Piénsalo antes de verlo.
- **Revisa tu bloque:** al final de cada uno corre `./revisar.sh` con el número del bloque, por ejemplo `./revisar.sh 1`. Le hace peticiones a tus servicios y te dice qué ya funciona y qué no.

Si te dan post-its, pega el verde en tu monitor cuando te funcione y el rojo si te atoraste.

En este proyecto el autocompletado con IA viene apagado: la idea es que el código lo escribas tú.

## Si te atoras

Levanta el post-it rojo y te ayudamos. Si de plano te quedaste atrás, al empezar el siguiente bloque puedes brincar a una versión donde todo lo anterior ya funciona:

```bash
./punto-de-control.sh 3
```

Cambia el `3` por el número del bloque que vas a empezar. Lo que llevabas no se pierde: queda guardado y lo ves con `git stash list`.

## Lo que vas a construir

El backend de una cafetería con dos microservicios:

- **menu**, en C#: dice qué productos hay y cuánto cuestan.
- **pedidos**, en Node.js con TypeScript: recibe pedidos, le pregunta al menú si cada producto existe y cuánto cuesta, y guarda el pedido.

Cada servicio tiene su propia base de datos dentro del mismo SQL Server, que corre en Docker.
