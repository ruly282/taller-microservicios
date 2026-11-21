#!/usr/bin/env bash
# Te lleva al inicio de un bloque con todo lo anterior ya funcionando.
# Uso:
#   ./punto-de-control.sh 3       inicio del bloque 3
#   ./punto-de-control.sh final   el proyecto terminado
#   ./punto-de-control.sh extra   el proyecto terminado más RabbitMQ
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Uso: ./punto-de-control.sh <1|2|3|4|final|extra>"
  exit 1
fi

case "$1" in
  1|2|3|4) rama="bloque-$1" ;;
  final)   rama="final" ;;
  extra)   rama="extra-rabbitmq" ;;
  *) echo "No existe el punto de control '$1'. Usa 1, 2, 3, 4, final o extra."; exit 1 ;;
esac

# Guarda lo que llevabas, por si después lo quieres recuperar
if [ -n "$(git status --porcelain)" ]; then
  git stash push --include-untracked --message "mi avance antes de $rama" > /dev/null
  echo "Tu avance quedó guardado. Para verlo: git stash list"
fi

git fetch --quiet origin "$rama"
git checkout --quiet -B "$rama" "origin/$rama"

echo "Listo: estás en el punto de control '$rama'."
echo "Si tenías algo corriendo (dotnet run o npm run dev), detenlo con Ctrl+C y vuelve a correrlo."
