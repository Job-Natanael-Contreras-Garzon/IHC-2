const { estaReservado } = require("./reglasObjeto");

describe("Restricción: objeto reservado", () => {
  test("un objeto reservado está bloqueado", () => {
    const objeto = { estado: "reservado" };
    const resultado = estaReservado(objeto);
    expect(resultado).toBe(true);
  });

  test("un objeto disponible no está bloqueado", () => {
    const objeto = { estado: "disponible" };
    const resultado = estaReservado(objeto);
    expect(resultado).toBe(false);
  });
});
