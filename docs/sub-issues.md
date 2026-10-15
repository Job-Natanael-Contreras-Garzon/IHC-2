# Sub-issues de la evaluación heurística (padre: #6)

Crea estos 10 issues **en este orden y antes de hacer `git push`**: los commits ya dicen `Fixes #7` … `Fixes #16`, así que cada issue debe quedar con el número indicado. Etiqueta sugerida: `documentation`. Si el número que asigna GitHub no coincide, avisa para ajustar los mensajes de commit.

Cuando existan, puedes vincularlos al #6 desde el issue padre (*Add sub-issue*) o dejar la mención `Padre: #6` que ya traen.

| # | Heurística | Severidad | Commit |
|:-:|---|---|---|
| #7 | H5 | 3 (Mayor) | `5ab5194` |
| #8 | H3 | 4 (Crítico) | `1fd8aae` |
| #9 | H7 | 4 (Crítico) | `59a672f` |
| #10 | H1 | 2 (Menor) | `597fdc6` |
| #11 | H2 | 1 (Cosmético) | `4ab1b0e` |
| #12 | H4 | 2 (Menor) | `70bd0ee` |
| #13 | H5 | 2 (Menor) | `abc2471` |
| #14 | H8 | 1 (Cosmético) | `8574907` |
| #15 | H9 | 2 (Menor) | `2b19740` |
| #16 | H10 | 2 (Menor) | `a769104` |

---

## Issue #7

**Título:** `[H5][Sev 3] Reservar una publicación no pide confirmación`

**Cuerpo:**

> **Heurística:** H5 · **Severidad:** 3 (Mayor)
> **Pantalla / flujo:** Feed de publicaciones → botón «Reservar»
> **Padre:** #6
>
> ### Problema
> Al tocar «Reservar» la reserva se envía de inmediato (aparece el spinner y luego «Reservado por ti»). No hay diálogo de confirmación, por lo que un toque accidental aparta el objeto de otras personas. «Completar intercambio» sí pide confirmación, así que el flujo es inconsistente.
>
> ### Evidencia (antes)
> `trueque-u/app/lib/pantallas/pantalla_feed_publicaciones.dart:L138-L170` (`_reservar` llama a la API sin confirmar) · `trueque-u/app/lib/widgets/tarjeta_feed.dart:L285-L290` · capturas `docs/evidencias/H5_antes_01_feed_boton_reservar.png`, `H5_antes_02_reserva_inmediata_sin_dialogo.png`
>
> ### Corrección
> Mostrar `confirmarAccion(...)` antes de reservar, con el título del objeto y el aviso de que se podrá cancelar.

---

## Issue #8

**Título:** `[H3][Sev 4] No existe salida para cancelar una reserva`

**Cuerpo:**

> **Heurística:** H3 · **Severidad:** 4 (Crítico)
> **Pantalla / flujo:** Feed de publicaciones → publicación reservada por mí
> **Padre:** #6
>
> ### Problema
> Quien reservó por error queda atrapado: el botón «Descartar reserva» está comentado y solo queda «Completar intercambio». El backend ya soporta liberar la reserva (`PUT /:id/disponible`).
>
> ### Evidencia (antes)
> `trueque-u/app/lib/widgets/tarjeta_feed.dart:L232-L255` (botón comentado en L243-L252) · `trueque-u/app/lib/widgets/tarjeta_mi_publicacion.dart:L227-L236` · backend `trueque-u/backend/src/controllers/reservas.controlador.js:L80-L143` · captura `docs/evidencias/H3-H7_antes_01_reservado_sin_cancelar_ni_contacto.png`
>
> ### Corrección
> Reactivar «Cancelar reserva» en la tarjeta de quien reservó, con confirmación y mensaje de resultado.

---

## Issue #9

**Título:** `[H7][Sev 4] Quien reserva no tiene forma de contactar al dueño`

**Cuerpo:**

> **Heurística:** H7 · **Severidad:** 4 (Crítico)
> **Pantalla / flujo:** Feed → publicación reservada por mí → coordinar la entrega
> **Padre:** #6
>
> ### Problema
> El dueño ve el WhatsApp de quien reservó, pero quien reserva no ve ningún dato ni botón para contactar al dueño. No puede coordinar la entrega, que es el objetivo central de la app. El backend solo expone el teléfono al dueño.
>
> ### Evidencia (antes)
> `trueque-u/backend/src/controllers/publicaciones.controlador.js:L14-L33` y `L92-L103` (teléfono solo al dueño) · `trueque-u/app/lib/widgets/tarjeta_feed.dart:L168-L190` y `L232-L255` (sin contacto) · referencia: `trueque-u/app/lib/widgets/tarjeta_mi_publicacion.dart:L193-L209` · captura `docs/evidencias/H3-H7_antes_01_reservado_sin_cancelar_ni_contacto.png`
>
> ### Corrección
> Backend: enviar el teléfono del autor solo a quien reservó. App: botón «WhatsApp» (un toque) en la tarjeta reservada y mensaje con el siguiente paso al reservar.

---

## Issue #10

**Título:** `[H1][Sev 2] Las acciones de «Mis publicaciones» no muestran progreso`

**Cuerpo:**

> **Heurística:** H1 · **Severidad:** 2 (Menor)
> **Pantalla / flujo:** Mis publicaciones → completar / cambiar estado / eliminar
> **Padre:** #6
>
> ### Problema
> Al completar, cambiar estado o eliminar no hay indicador de carga ni el botón se bloquea; el usuario no sabe si la acción está en curso y puede tocar dos veces. En el feed sí existe (`_accionesEnProgreso`).
>
> ### Evidencia (antes)
> `trueque-u/app/lib/pantallas/pantalla_mis_publicaciones.dart:L64-L98`, `L102-L123`, `L165-L205` · `trueque-u/app/lib/widgets/tarjeta_mi_publicacion.dart:L12-L29` y `L239-L248` · referencia correcta: `trueque-u/app/lib/widgets/tarjeta_feed.dart:L211-L222`
>
> ### Corrección
> Agregar `_accionesEnProgreso` y un parámetro `enProgreso` a la tarjeta: spinner y botones bloqueados mientras responde el servidor.

---

## Issue #11

**Título:** `[H2][Sev 1] Textos con abreviaturas y valores internos`

**Cuerpo:**

> **Heurística:** H2 · **Severidad:** 1 (Cosmético)
> **Pantalla / flujo:** Feed y Mis publicaciones (textos)
> **Padre:** #6
>
> ### Problema
> Se muestran «Ver en mis pubs», «Cambiar modo / estado» y el snackbar imprime el valor interno (`Publicación cambiada a "no disponible"`). No es el lenguaje del usuario.
>
> ### Evidencia (antes)
> `trueque-u/app/lib/widgets/tarjeta_feed.dart:L280` · `trueque-u/app/lib/widgets/tarjeta_mi_publicacion.dart:L99` · `trueque-u/app/lib/pantallas/pantalla_mis_publicaciones.dart:L109`
>
> ### Corrección
> Usar «Ver en mis publicaciones», «Cambiar estado de la publicación» y mensajes con las etiquetas legibles.

---

## Issue #12

**Título:** `[H4][Sev 2] «Completar intercambio» parece deshabilitado pero sigue activo`

**Cuerpo:**

> **Heurística:** H4 · **Severidad:** 2 (Menor)
> **Pantalla / flujo:** Mis publicaciones → «Completar intercambio»
> **Padre:** #6
>
> ### Problema
> En Mis publicaciones el botón se pinta en gris cuando no hay reserva pero sigue respondiendo al toque; en el feed el mismo botón se oculta o se deshabilita de verdad. Mismo control, dos comportamientos.
>
> ### Evidencia (antes)
> `trueque-u/app/lib/widgets/tarjeta_mi_publicacion.dart:L239-L248` · referencia: `trueque-u/app/lib/widgets/tarjeta_feed.dart:L257-L283`
>
> ### Corrección
> Deshabilitarlo realmente (`onPressed: null`) con tooltip que explique que primero debe reservarse.

---

## Issue #13

**Título:** `[H5][Sev 2] Iconos de editar y eliminar con área táctil pequeña y pegados`

**Cuerpo:**

> **Heurística:** H5 · **Severidad:** 2 (Menor)
> **Pantalla / flujo:** Mis publicaciones → iconos editar / estado / eliminar (Ley de Fitts)
> **Padre:** #6
>
> ### Problema
> Los iconos tienen `padding: EdgeInsets.zero` y `constraints: BoxConstraints()`: el área táctil queda cercana a 20 px (mínimo recomendado 48 px) y «Eliminar» está junto a «Editar». Ley de Fitts: riesgo de tocar el icono equivocado.
>
> ### Evidencia (antes)
> `trueque-u/app/lib/widgets/tarjeta_mi_publicacion.dart:L80-L94` y `L134-L141`
>
> ### Corrección
> Quitar las restricciones para recuperar el área táctil estándar de 48 px y separar la acción destructiva.

---

## Issue #14

**Título:** `[H8][Sev 1] La tarjeta repite 3 veces que está reservada`

**Cuerpo:**

> **Heurística:** H8 · **Severidad:** 1 (Cosmético)
> **Pantalla / flujo:** Feed → tarjeta de publicación reservada
> **Padre:** #6
>
> ### Problema
> Una publicación reservada muestra el estado en el chip superior, en una etiqueta inferior y en el botón («Reservado por ti» ×2, «Reservado (nombre)»). Información duplicada que compite con la acción principal.
>
> ### Evidencia (antes)
> `trueque-u/app/lib/widgets/tarjeta_feed.dart:L84-L87`, `L168-L190` y `L266-L274` · captura `docs/evidencias/H3-H7_antes_01_reservado_sin_cancelar_ni_contacto.png`
>
> ### Corrección
> Dejar el chip superior como único indicador de «Reservado por ti» y mostrar en la etiqueta solo el nombre cuando es otra persona.

---

## Issue #15

**Título:** `[H9][Sev 2] Mensajes de error con código HTTP y jerga técnica`

**Cuerpo:**

> **Heurística:** H9 · **Severidad:** 2 (Menor)
> **Pantalla / flujo:** Cualquier pantalla que llama a la API (errores)
> **Padre:** #6
>
> ### Problema
> Los errores genéricos se muestran como «Error 409: …» y la falta de conexión pregunta «¿Está encendido el backend?». El usuario no necesita códigos ni sabe qué es el backend, y no se le indica qué hacer.
>
> ### Evidencia (antes)
> `trueque-u/app/lib/servicios/cliente_api.dart:L67-L69`, `L85-L89` y `L102-L108`
>
> ### Corrección
> Quitar el código del mensaje visible (queda en el log) y redactar la causa y la salida: «Revisa tu conexión a internet e inténtalo de nuevo».

---

## Issue #16

**Título:** `[H10][Sev 2] No hay ayuda sobre cómo funciona reservar y entregar`

**Cuerpo:**

> **Heurística:** H10 · **Severidad:** 2 (Menor)
> **Pantalla / flujo:** Feed de publicaciones (ayuda contextual)
> **Padre:** #6
>
> ### Problema
> La app no explica el flujo (reservar → coordinar → entregar → completar) ni qué significa cada estado. La persona nueva debe deducirlo.
>
> ### Evidencia (antes)
> `trueque-u/app/lib/pantallas/pantalla_feed_publicaciones.dart:L349-L364` (AppBar sin ayuda); búsqueda de «ayuda» en `trueque-u/app/lib`: sin resultados
>
> ### Corrección
> Icono «?» en el AppBar del feed que abre un diálogo corto «¿Cómo funciona?» con los 4 pasos y los estados.
