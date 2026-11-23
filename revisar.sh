#!/usr/bin/env bash
# Revisa tu bloque: le hace peticiones a tus servicios y te dice qué ya funciona y qué falta.
# Uso: ./revisar.sh 1   (cambia el 1 por el número del bloque: 1, 2 o 3)
set -u
cd "$(dirname "$0")"

MENU=http://localhost:5000
PEDIDOS=http://localhost:3000
RESPUESTA=$(mktemp)
trap 'rm -f "$RESPUESTA"' EXIT
bien=0
fallas=0

revisar() {  # revisar "qué se prueba" esperado obtenido "pista si falla"
  if [ "$2" = "$3" ]; then
    echo "  OK     $1"
    bien=$((bien + 1))
  else
    if [ "$3" = "000" ]; then
      echo "  FALLA  $1: no llegó respuesta"
    elif [ -z "$3" ]; then
      echo "  FALLA  $1: la respuesta no lo trae (se esperaba $2)"
    else
      echo "  FALLA  $1: se esperaba $2 y llegó $3"
    fi
    [ -n "${4:-}" ] && echo "         Pista: $4"
    fallas=$((fallas + 1))
  fi
}

codigo() {  # codigo MÉTODO URL [JSON]: imprime el código HTTP y guarda la respuesta
  if [ $# -eq 3 ]; then
    curl -s --max-time 10 -o "$RESPUESTA" -w "%{http_code}" -X "$1" "$2" -H "Content-Type: application/json" -d "$3"
  else
    curl -s --max-time 10 -o "$RESPUESTA" -w "%{http_code}" -X "$1" "$2"
  fi
}

campo() {  # campo NOMBRE: imprime ese campo de la última respuesta
  node -e "
    try { const r = JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8')); console.log(r[process.argv[2]] ?? ''); }
    catch { console.log(''); }" "$RESPUESTA" "$1"
}

contar_pedidos() {
  curl -s --max-time 10 "$PEDIDOS/pedidos" | node -e "
    let s = ''; process.stdin.on('data', d => s += d).on('end', () => {
      try { console.log(JSON.parse(s).length); } catch { console.log('?'); } });"
}

responde() {  # responde URL "mensaje si no responde"
  if ! curl -s -o /dev/null --max-time 3 "$1"; then
    echo "  $2"
    exit 1
  fi
}

revisar_menu() {
  responde "$MENU/" "El menú no responde en el puerto 5000. ¿Lo dejaste corriendo con dotnet run?"

  revisar "Todos los productos" 200 "$(codigo GET "$MENU/productos")" \
    "¿Ya está la ruta GET /productos? ¿Reiniciaste el menú después de guardar?"
  revisar "Un producto que existe" 200 "$(codigo GET "$MENU/productos/1")" \
    "Revisa la ruta GET /productos/{id}."
  revisar "Un producto que no existe" 404 "$(codigo GET "$MENU/productos/99")" \
    "Si no existe, responde con Results.NotFound()."

  revisar "Agregar un producto" 201 "$(codigo POST "$MENU/productos" '{"nombre":"Prueba del revisor","precio":10}')" \
    "Si los datos están bien, responde con Results.Created(...)."
  local id
  id=$(campo id)
  revisar "Producto sin nombre" 400 "$(codigo POST "$MENU/productos" '{"nombre":"","precio":10}')" \
    "Revisa el nombre con string.IsNullOrWhiteSpace y responde con Results.BadRequest(...)."
  revisar "Producto con precio en 0" 400 "$(codigo POST "$MENU/productos" '{"nombre":"Sin precio","precio":0}')" \
    "Revisa que el precio sea mayor a 0."

  if [ -n "$id" ]; then
    revisar "Borrar el producto que se agregó" 204 "$(codigo DELETE "$MENU/productos/$id")" \
      "Después de quitarlo, responde con Results.NoContent()."
    revisar "Borrar un producto que ya no existe" 404 "$(codigo DELETE "$MENU/productos/$id")" \
      "Si no lo encuentras, responde con Results.NotFound()."
  else
    echo "  FALLA  Borrar: no se pudo probar porque Agregar no regresó el producto con su id"
    fallas=$((fallas + 1))
  fi
}

revisar_pedidos() {
  responde "$PEDIDOS/" "Pedidos no responde en el puerto 3000. ¿Lo dejaste corriendo con npm run dev?"

  local antes
  antes=$(contar_pedidos)
  revisar "Todos los pedidos" 200 "$(codigo GET "$PEDIDOS/pedidos")" \
    "Revisa la ruta GET /pedidos y que pedidos haya arrancado sin errores."
  revisar "Pedido sin cliente ni productos" 400 "$(codigo POST "$PEDIDOS/pedidos" '{}')" \
    "Valida que venga el cliente y al menos un producto."
  revisar "Producto que no existe en el menú" 400 "$(codigo POST "$PEDIDOS/pedidos" '{"cliente":"Revisor","productos":[{"id":99,"cantidad":1}]}')" \
    "Si el menú no responde 200 (respuesta.ok), responde 400."
  revisar "Pedido de 2 cafés y 1 burrito" 201 "$(codigo POST "$PEDIDOS/pedidos" '{"cliente":"Revisor","productos":[{"id":1,"cantidad":2},{"id":3,"cantidad":1}]}')" \
    "Si da 503, pedidos no encuentra al menú. Si da 500, mira el error en la terminal de pedidos."
  revisar "Total del pedido" 120 "$(campo total)" \
    "El total sale de los precios del menú: 2 × 30 + 1 × 60."
  revisar "Cantidad en 0" 400 "$(codigo POST "$PEDIDOS/pedidos" '{"cliente":"Revisor","productos":[{"id":1,"cantidad":1},{"id":2,"cantidad":0}]}')" \
    "Revisa la cantidad de cada producto antes de preguntarle al menú."
  revisar "El pedido con cantidad en 0 no se guardó" "$((antes + 1))" "$(contar_pedidos)" \
    "Solo se debió guardar el pedido de 2 cafés y 1 burrito."
}

case "${1:-}" in
  1|2)
    echo "==> Revisando el menú (bloque $1)"
    if [ "$1" = 2 ]; then
      if docker compose ps sqlserver 2>/dev/null | grep -q "(healthy)"; then
        echo "  OK     SQL Server está arriba"
        bien=$((bien + 1))
      else
        echo "  FALLA  SQL Server no está arriba"
        echo "         Pista: corre docker compose up -d y espera a que docker compose ps diga healthy."
        fallas=$((fallas + 1))
      fi
    fi
    revisar_menu
    ;;
  3)
    echo "==> Revisando pedidos (bloque 3)"
    responde "$MENU/" "El menú no responde en el puerto 5000 y pedidos lo necesita. Arráncalo: cd menu y dotnet run."
    revisar_pedidos
    echo "  A MANO Detén el menú con Ctrl+C y manda Hacer un pedido: debe dar 503. Luego vuelve a arrancarlo."
    ;;
  *)
    echo "Uso: ./revisar.sh <bloque>   (1, 2 o 3)"
    exit 1
    ;;
esac

echo
if [ "$fallas" -eq 0 ]; then
  echo "Todo bien: tu bloque $1 funciona."
else
  echo "Llevas $bien bien y $fallas por arreglar. Arregla la primera FALLA y vuelve a correrlo."
  exit 1
fi
