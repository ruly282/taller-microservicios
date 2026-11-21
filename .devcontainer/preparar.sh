#!/usr/bin/env bash
# Se corre una sola vez, cuando se crea el Codespace.
# Deja todo descargado para que en el taller no haya que esperar.

echo "==> Paquetes de .NET"
(cd menu && dotnet restore)

echo "==> Paquetes de Node.js"
(cd pedidos && npm install)

echo "==> Esperando a que arranque Docker"
for _ in $(seq 1 30); do
  docker info > /dev/null 2>&1 && break
  sleep 2
done

echo "==> Imágenes de Docker (SQL Server y las de los Dockerfiles del bloque 4)"
for imagen in \
  mcr.microsoft.com/mssql/server:2022-latest \
  mcr.microsoft.com/dotnet/sdk:10.0 \
  mcr.microsoft.com/dotnet/aspnet:10.0 \
  node:24-slim
do
  docker pull --quiet "$imagen" || echo "No se pudo descargar $imagen; se descargará cuando se use."
done

echo "==> Listo, ya puedes empezar."
