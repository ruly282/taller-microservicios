# Guía del taller

| Bloque | Hora | Qué haces |
| --- | --- | --- |
| [0. Antes de empezar](00-antes-de-empezar.md) | 10:00 | Abres tu Codespace y conoces el proyecto |
| [1. API REST en C#](01-api-rest-en-csharp.md) | 10:15 | Haces el servicio de menú con ASP.NET Core |
| [2. SQL Server con Entity Framework](02-sql-server-con-entity-framework.md) | 10:55 | El menú guarda sus productos en una base de datos |
| Descanso | 11:30 | |
| [3. Servicio en Node.js con TypeScript](03-pedidos-en-nodejs.md) | 11:40 | Pedidos le pregunta al menú y guarda con una transacción |
| [4. Docker](04-docker.md) | 12:20 | Cada servicio en su contenedor y todo con un solo comando |
| [Extra: RabbitMQ](05-extra-rabbitmq.md) | En tu casa | Pedidos le avisa a cocina con mensajes |

## Cómo va cada bloque

1. **En el proyector:** se explica el tema y se programa la primera parte. Tú la vas escribiendo al mismo tiempo. Antes de correr algo se pregunta qué va a pasar: piénsalo antes de verlo.
2. **Tu turno, en pareja:** con quien tengas al lado. La guía les dice qué debe hacer el código y les da pistas, pero no el código. Platíquenlo, cada quien lo escribe en su compu y revisen el del otro. La solución viene escondida: no la abran hasta intentarlo.
3. **Revisa tu reto:** en una terminal nueva corre `./revisar.sh 1`, con el número del bloque. Le hace peticiones a tus servicios y te dice qué ya funciona y qué falta.
4. **Se resuelve juntos:** en el proyector, y todos lo prueban.

Si te dan post-its, pega el verde en tu monitor cuando termines y el rojo si necesitas ayuda.

## Si te atoras

Al inicio de cada bloque puedes brincar a una versión donde todo lo anterior ya funciona:

```bash
./punto-de-control.sh 3
```

Cambia el `3` por el número del bloque que vas a empezar. Lo que llevabas no se pierde: queda guardado y lo ves con `git stash list`.

## Lo que vas a construir

El backend de una cafetería con dos microservicios:

- **menu**, en C#: dice qué productos hay y cuánto cuestan.
- **pedidos**, en Node.js con TypeScript: recibe pedidos, le pregunta al menú si cada producto existe y cuánto cuesta, y guarda el pedido.

Cada servicio tiene su propia base de datos dentro del mismo SQL Server, y al final todo corre en Docker.
