#!/usr/bin/env bash
# Te lleva al inicio de un bloque con todo lo anterior ya funcionando.
# Uso:
#   ./punto-de-control.sh 3       inicio del bloque 3
#   ./punto-de-control.sh final   el proyecto terminado (bloque 3 completo)
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Uso: ./punto-de-control.sh <2|3|final>"
  exit 1
fi

case "$1" in
  2|3) rama="bloque-$1" ;;
  final) rama="final" ;;
  *) echo "No existe el punto de control '$1'. Usa 2, 3 o final."; exit 1 ;;
esac

cd "$(dirname "$0")"

# Guarda lo que llevabas, por si después lo quieres recuperar
if [ -n "$(git status --porcelain)" ]; then
  git stash push --include-untracked --message "mi avance antes de $rama" > /dev/null
  echo "Tu avance quedó guardado. Para verlo: git stash list"
fi

git fetch --quiet origin "$rama"
git checkout --quiet -B "$rama" "origin/$rama"

# Si ya existe el servicio de pedidos, le instala sus paquetes
if [ -f pedidos/package-lock.json ]; then
  echo "Instalando los paquetes de pedidos..."
  (cd pedidos && npm ci --silent) || echo "No se pudieron instalar. Entra a la carpeta pedidos y corre npm install."
fi

echo "Listo: estás en el punto de control '$rama'."
echo "Si tenías algo corriendo (dotnet run o npm run dev), detenlo con Ctrl+C y vuelve a correrlo."
