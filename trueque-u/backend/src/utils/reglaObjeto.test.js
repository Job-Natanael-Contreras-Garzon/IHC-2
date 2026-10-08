const { estaReservado } = require("./reglasObjeto");

describe("Restricción: publicación reservada", () => {
  test("una publicación reservada está bloqueada", () => {
    const publicacion = { estado_publicacion: "reservado" };
    const resultado = estaReservado(publicacion);
    expect(resultado).toBe(true);
  });

  test("una publicación disponible no está bloqueada", () => {
    const publicacion = { estado_publicacion: "disponible" };
    const resultado = estaReservado(publicacion);
    expect(resultado).toBe(false);
  });
});
