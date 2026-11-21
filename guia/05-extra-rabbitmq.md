# Extra: RabbitMQ

Para practicar en tu casa. Hasta ahora, pedidos le habla al menú y espera su respuesta. Con mensajes es distinto: pedidos deja un aviso en una cola y sigue con lo suyo, y otro servicio lo atiende cuando puede.

En este extra hay un tercer servicio, **cocina**, que no tiene API: solo escucha la cola `pedidos-nuevos` de RabbitMQ. Cada vez que se guarda un pedido, cocina se entera y lo "prepara".

## Córrelo

```bash
./punto-de-control.sh extra
docker compose up -d --build
docker compose logs -f cocina
```

Haz un pedido desde `pedidos/pedidos.http` y mira cómo aparece en los logs de cocina. Para salir de los logs: **Ctrl+C**.

El panel de RabbitMQ está en el puerto 15672: búscalo en la pestaña **Ports** de VS Code. Entras con el usuario `taller` y la contraseña que está en `.env`.

## Qué revisar en el código

- `pedidos/src/avisos.ts`: así se deja un mensaje en la cola.
- `cocina/src/index.ts`: así se escucha la cola y se confirma cada mensaje con `ack`.

**Para pensar:** apaga cocina (`docker compose stop cocina`), haz dos pedidos y vuelve a prenderla (`docker compose start cocina`). ¿Qué pasa con los avisos que llegaron mientras estaba apagada?
