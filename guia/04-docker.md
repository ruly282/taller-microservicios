# 4. Docker

**Meta:** que cada servicio corra en su propio contenedor y que todo se levante con un solo comando.

Si no terminaste el bloque 3: `./punto-de-control.sh 4`

## Paso 0. Libera los puertos

Detén el menú y pedidos con **Ctrl+C**: ahora van a correr adentro de Docker. SQL Server puede seguir arriba.

## Paso 1. Dockerfile del menú

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

## Paso 2. Dockerfile de pedidos

Crea el archivo `pedidos/Dockerfile`:

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

## Paso 3. Agrégalos a `compose.yaml`

Al final de `compose.yaml` borra el comentario del bloque 4 y en su lugar pega esto. Cuida la sangría: `menu` y `pedidos` van a la misma altura que `sqlserver`.

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

- Adentro de Docker, los servicios se encuentran por su nombre: la base es `sqlserver` y el menú es `menu`, ya no `localhost`.
- La configuración entra por variables de entorno (`environment`). El código no se toca.
- `depends_on` hace que los servicios esperen a que SQL Server esté listo.

## Paso 4. Levanta todo

```bash
docker compose up -d --build
docker compose ps
```

Deben aparecer tres servicios: `sqlserver`, `menu` y `pedidos`. La primera vez tarda un par de minutos, porque construye las imágenes.

Para ver lo que dice cada uno: `docker compose logs menu` o `docker compose logs pedidos`.

## Pruébalo

Los mismos archivos `.http` funcionan igual, porque ahora Docker publica los puertos 5000 y 3000.

Para apagar todo: `docker compose down`.
