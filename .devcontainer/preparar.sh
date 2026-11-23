#!/usr/bin/env bash
# Se corre una sola vez, cuando se crea el Codespace.
# Descarga de antemano lo que se usa en el taller, para que en vivo no haya que esperar.

echo "==> Paquetes de .NET y de Node.js"
calentar=$(mktemp -d)
(
  cd "$calentar" &&
  dotnet new web -o menu > /dev/null &&
  cd menu &&
  dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 10.0.15 > /dev/null &&
  dotnet build > /dev/null
) || echo "No se pudieron descargar los paquetes de .NET; se descargarán en el taller."
(
  mkdir -p "$calentar/pedidos" && cd "$calentar/pedidos" &&
  npm init -y > /dev/null &&
  npm install express mssql > /dev/null 2>&1 &&
  npm install -D tsx @types/express @types/mssql @types/node > /dev/null 2>&1
) || echo "No se pudieron descargar los paquetes de Node.js; se descargarán en el taller."
rm -rf "$calentar"

echo "==> Esperando a que arranque Docker"
for _ in $(seq 1 30); do
  docker info > /dev/null 2>&1 && break
  sleep 2
done

echo "==> La imagen de SQL Server"
docker pull --quiet mcr.microsoft.com/mssql/server:2022-latest || echo "No se pudo descargar SQL Server; se descargará en el bloque 2."

echo "==> Listo, ya puedes empezar."
