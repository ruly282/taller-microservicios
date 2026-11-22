# 4. Docker

**Meta:** que cada servicio corra en su propio contenedor y que todo se levante con un solo comando.

Si no terminaste el bloque 3: `./punto-de-control.sh 4`

En el proyector se hace todo lo del menú. Lo de pedidos te toca a ti.

## En el proyector

### Paso 0. Libera los puertos

Detén el menú y pedidos con **Ctrl+C**: ahora van a correr adentro de Docker. SQL Server puede seguir arriba.

### Paso 1. Dockerfile del menú

Crea el archivo `menu/Dockerfile`:

```dockerfile
# Etapa 1: compilar con el SDK de .NET
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS compilar
WORKDIR /src

# Primero solo el proyecto, para que Docker guarde los paquetes en caché
COPY Menu.csproj .
RUN dotnet restore

# Luego el código
COPY . .
RUN dotnet publish -c Release -o /app --no-restore

# Etapa 2: solo lo necesario para correr (una imagen mucho más chica)
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=compilar /app .

ENV ASPNETCORE_HTTP_PORTS=5000
EXPOSE 5000
ENTRYPOINT ["dotnet", "Menu.dll"]
```

Son dos etapas: en la primera se compila con el SDK completo, y a la imagen final solo pasa lo compilado con lo mínimo para correrlo.

### Paso 2. El menú en `compose.yaml`

Al final de `compose.yaml` borra el comentario del bloque 4 y en su lugar pega esto. Cuida la sangría: `menu` va a la misma altura que `sqlserver`.

```yaml
  # Servicio de menú (C#). Adentro de Docker, la base se llama "sqlserver", no "localhost".
  menu:
    build: ./menu
    environment:
      ConnectionStrings__MenuDb: "Server=sqlserver,1433;Database=MenuDb;User Id=sa;Password=${SA_PASSWORD};TrustServerCertificate=True"
    ports:
      - "5000:5000"
    depends_on:
      sqlserver:
        condition: service_healthy
```

- Adentro de Docker, los servicios se encuentran por su nombre: la base es `sqlserver`, ya no `localhost`.
- La configuración entra por variables de entorno (`environment`). El código no se toca.
- `depends_on` hace que el menú espere a que SQL Server esté listo.

Levanta solo el menú:

```bash
docker compose up -d --build menu
```

La primera vez tarda un par de minutos, porque construye la imagen. Mientras, empieza tu turno. Cuando termine, manda **Todos los productos** de `menu.http`: ahora te responde el contenedor.

## Tu turno

En pareja, como en el bloque 1.

### Reto 1. Dockerfile de pedidos

Crea `pedidos/Dockerfile`. Se parece al del menú, pero con una sola etapa:

1. Imagen base: `node:24-slim`.
2. Carpeta de trabajo: `/app`.
3. Copia solo `package.json` y `package-lock.json` e instala con `npm ci`. Así Docker guarda las dependencias en caché.
4. Copia el resto del código y compílalo con `npm run build`, que pasa el TypeScript a JavaScript.
5. El servicio escucha en el puerto que diga la variable `PORT`: ponla en 3000 y expón ese puerto.
6. Arranca con `node dist/index.js`.

<details>
<summary>Ver la solución (primero inténtalo)</summary>

```dockerfile
FROM node:24-slim
WORKDIR /app

# Primero solo las dependencias, para que Docker las guarde en caché
COPY package.json package-lock.json ./
RUN npm ci

# Luego el código, y se compila de TypeScript a JavaScript
COPY . .
RUN npm run build

ENV PORT=3000
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

</details>

### Reto 2. Pedidos en `compose.yaml`

Abajo de `menu`, agrega el servicio `pedidos`:

- Se construye con lo que hay en `./pedidos` y publica el puerto 3000.
- Recibe tres variables de entorno:
  - `DB_SERVER`: ¿cómo se llama la base adentro de Docker?
  - `DB_PASSWORD`: la misma `${SA_PASSWORD}` que usa la base.
  - `MENU_URL`: ¿cómo se llama el menú adentro de Docker? Escucha en el puerto 5000.
- Espera a que SQL Server esté listo (`service_healthy`) y a que el menú haya arrancado (`service_started`).

Pista: tiene la misma forma que el servicio `menu`.

<details>
<summary>Ver la solución (primero inténtalo)</summary>

```yaml
  # Servicio de pedidos (Node.js). Al menú lo encuentra por su nombre: http://menu:5000
  pedidos:
    build: ./pedidos
    environment:
      DB_SERVER: sqlserver
      DB_PASSWORD: ${SA_PASSWORD}
      MENU_URL: http://menu:5000
    ports:
      - "3000:3000"
    depends_on:
      sqlserver:
        condition: service_healthy
      menu:
        condition: service_started
```

</details>

**Para pensar:** si en `MENU_URL` pusieras `http://localhost:5000`, ¿qué respondería pedidos y por qué?

## Otra vez en el proyector

### Paso 3. Levanta todo

```bash
docker compose up -d --build
docker compose ps
```

Deben aparecer tres servicios: `sqlserver`, `menu` y `pedidos`.

Para ver lo que dice cada uno: `docker compose logs menu` o `docker compose logs pedidos`.

## Pruébalo

Corre `./revisar.sh 4`: revisa que estén los tres contenedores y que todo responda desde Docker. Los mismos archivos `.http` también funcionan, porque ahora Docker publica los puertos 5000 y 3000.

Para apagar todo: `docker compose down`.
