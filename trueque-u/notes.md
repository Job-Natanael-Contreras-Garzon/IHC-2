# Evaluación Heurística de Usabilidad (IHC)
> *"Puede funcionar y todavía ser difícil de usar. Una heurística convierte una impresión en una decisión que podemos mejorar."*

---

## 🎯 1. Fundamentos de la Evaluación Heurística

- **¿Qué es una heurística?**: Es una regla general o principio de usabilidad reconocido para inspeccionar una interfaz.
- **Propósito**: Evaluar interfaces con criterios técnicos objetivos y compartidos, superando la retroalimentación subjetiva (*"me gusta"* / *"no me gusta"*).
- **Ciclo de acción**: **Encontrar** $\rightarrow$ **Priorizar** $\rightarrow$ **Mejorar**.
- **Preguntas clave de inspección**:
  - ¿Dónde apareció la confirmación?
  - ¿Está claro si la acción terminó?
  - ¿Se puede deshacer o cancelar?

---

## 🔟 2. Las 10 Heurísticas de Nielsen (H1 - H10)

### Bloque A: Comprensión y Estado
> *¿Sé qué está pasando y entiendo el lenguaje?*

* **H1: Visibilidad del estado del sistema**
  * La interfaz informa de manera oportuna, clara y visible qué está ocurriendo y cuál fue el resultado de cada acción.
* **H2: Relación entre el sistema y el mundo real**
  * La interfaz utiliza palabras, frases, conceptos y secuencias lógicas comprensibles para el usuario, siguiendo convenciones del mundo real.

---

### Bloque B: Control y Coherencia
> *¿Puedo corregir una decisión y encuentro patrones conocidos?*

* **H3: Control y libertad del usuario**
  * La persona cuenta con salidas de emergencia claras: puede cancelar, volver atrás, deshacer o salir de una acción iniciada por error sin frustración.
* **H4: Consistencia y estándares**
  * Las mismas palabras, iconos, estados y controles mantienen idéntico significado y comportamiento en toda la aplicación.

---

### Bloque C: Reducción de Carga Cognitiva y Errores
> *¿La interfaz evita el error y reduce lo que debo recordar?*

* **H5: Prevención de errores**
  * El diseño previene la aparición de problemas antes de que ocurran mediante restricciones, confirmaciones en acciones destructivas y diseño a prueba de fallos.
* **H6: Reconocer antes que recordar**
  * Las opciones, elementos y datos necesarios se mantienen visibles o accesibles cuando el usuario debe tomar una decisión, minimizando la memoria de trabajo.

---

### Bloque D: Eficiencia y Foco
> *¿La tarea es eficiente sin llenar la pantalla de ruido?*

* **H7: Flexibilidad y eficiencia de uso**
  * La interacción resulta intuitiva para principiantes y ofrece atajos/aceleradores para usuarios experimentados que buscan avanzar rápido.
* **H8: Diseño estético y minimalista**
  * Cada elemento visible compite por la atención. La información irrelevante o excesiva satura la pantalla y dificulta encontrar la acción principal.

---

### Bloque E: Resiliencia y Asistencia
> *¿Puedo resolver problemas y orientarme cuando algo falla?*

* **H9: Reconocer, diagnosticar y recuperarse de errores**
  * Los mensajes de error explican el problema en lenguaje humano simple (sin códigos crípticos de backend), indican la causa y ofrecen una salida o solución concreta.
* **H10: Ayuda y documentación**
  * Cuando se requiere asistencia, esta es fácil de localizar, concisa, contextualizada y enfocada directamente en completar la tarea.

---

## 📐 3. Leyes Complementarias de UX / IHC

* **Ley de Fitts**: El tiempo necesario para alcanzar un objetivo depende de la distancia y el tamaño del botón/área interactiva. *(Botones clave grandes y cercanos).*
* **Ley de Hick**: El tiempo que toma tomar una decisión se incrementa logarítmicamente con el número y complejidad de opciones disponibles. *(Evitar sobrecargar al usuario con demasiadas opciones).*

---

## 🔍 4. Definición y Estructura de un Hallazgo de Usabilidad

> ⚠️ **Regla de oro:** Un hallazgo describe un **problema observado**, no una preferencia personal o estética arbitraria.

Para documentar formalmente un problema de usabilidad, se debe desglosar en:

| Campo | Descripción | Ejemplo Práctico |
| :--- | :--- | :--- |
| **Dónde** | Pantalla, componente o momento exacto del flujo. | Detalle de cena del viernes después de tocar "Cancelar". |
| **Qué ocurre** | Comportamiento observado del sistema o interfaz. | El estado cambia internamente, pero no aparece ninguna confirmación visual cerca del botón de acción. |
| **Consecuencia** | Impacto en el usuario y su experiencia. | La persona puede volver a pulsar el botón innecesariamente o pensar que la acción falló. |
| **Heurística** | Principio de Nielsen vulnerado. | **H1: Visibilidad del estado del sistema**. |
| **Severidad** | Nivel de criticidad para priorizar su resolución. | **3: Mayor** (frustrante, debe corregirse). |
| **Mejora propuesta**| Solución concreta y comprobable. | Mostrar badge de estado "Cancelado" inmediatamente y disparar un toast/snackbar de éxito. |

---

## 📊 5. Escala de Severidad de Nielsen

Permite priorizar qué corregir primero según el impacto:

| Nivel | Severidad | Descripción e Impacto |
| :---: | :--- | :--- |
| **0** | **No es un problema** | No afecta la usabilidad ni la experiencia. |
| **1** | **Cosmético** | Inconveniente menor; se corrige solo si sobra tiempo. |
| **2** | **Menor** | Causa ligera molestia o duda, pero el usuario puede completar la tarea. |
| **3** | **Mayor** | Problema frustrante o confuso; alta prioridad de corrección. |
| **4** | **Crítico** | Bloquea o impide completar una tarea esencial; corrección obligatoria inmediata. |

---

## 🚀 6. Tarea Práctica: Evaluación en "Trueque U"

### 🎯 Flujo Objetivo
> **"Encontrar un objeto y completar un intercambio"**
> - Recorrer la acción completa: desde el listado/búsqueda hasta el resultado final.
> - Evaluar obligatoriamente:
>   1. **Un caso permitido** (flujo exitoso).
>   2. **Un caso bloqueado** (manejo de restricciones / validaciones / errores).

---

### 📋 Pasos de la Actividad y Entregables

1. **Issue Principal en GitHub**:
   - Título: `Evaluación heurística H1-H10`.
   - Contenido: Checklist verificable con las 10 heurísticas evaluadas en el flujo.

2. **Registro de Evidencia (H1 a H10)**:
   - Para cada heurística registrar:
     - Pantalla / Estado / Flujo evaluado.
     - Explicación del análisis.
     - Captura de pantalla (guardada en `docs/evidencias/`).
     - Referencia al código fuente (`archivo.ext:Lxx-Lyy`).
   - Si **cumple**: Indicar dónde y cómo se comprobó.
   - Si **falla**: Detallar el problema, consecuencia, heurística y severidad (0-4).

3. **Identificación de Hallazgos y Corrección en Código**:
   - Registrar al menos **3 hallazgos observados** antes de seleccionar uno para implementar.
   - Crear un **sub-issue** por cada hallazgo que no cumpla.
   - Implementar la corrección en el código.
   - Vincular los commits con el número de issue correspondiente.
   - Documentar la comparativa **Antes vs. Después** (capturas y diff de código).

4. **Entrega Formal**:
   - Documento final: [docs/evaluacion-heuristica.md](file:///c:/Users/contr/Documents/Repositorios%20de%20Git/IHC-2/trueque-u/docs/evaluacion-heuristica.md)
   - Carpeta de capturas: `docs/evidencias/`
   - **Fecha y hora límite**: Jueves 15 de octubre de 2026, antes de las 18:00 hrs.
