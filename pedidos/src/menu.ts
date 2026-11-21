// Cliente del servicio de menú: aquí un microservicio le habla a otro por REST.
const MENU_URL = process.env.MENU_URL ?? "http://localhost:5000";

export interface Producto {
  id: number;
  nombre: string;
  precio: number;
}

// Regresa el producto, o null si el menú responde que no existe (404).
export async function buscarProducto(id: number): Promise<Producto | null> {
  // TODO bloque 3: pedirle al menú GET {MENU_URL}/productos/{id} con fetch
  throw new Error(`Falta programar buscarProducto (producto ${id}, menú en ${MENU_URL})`);
}
