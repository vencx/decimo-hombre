# Plantillas de BRIEF-REVISION.md

Todas comparten cabecera y salida; cambia el bloque «Tarea». Rellena lo que va entre ‹›. Borra los focos que no apliquen y añade los propios del documento, siempre citando secciones reales.

## Cabecera común
```markdown
# Brief: revisión adversaria de ‹nombre del documento›

Repo ‹privado/local›: copia limpia, sin historia, solo con `‹fichero›`. No tienes base de datos, servidores, mensajería ni claves, y no las necesitas. Los ficheros, builds o sistemas que el documento cita viven fuera de aquí: no los busques; si un hallazgo depende de ellos, márcalo «inferido».

## Contexto
‹2–4 frases: qué es el sistema, para quién, qué busca este documento›. ‹Qué YA está decidido por el dueño y no se discute (p. ej. decisiones D‹n›, requisitos R‹n› aprobados)›: no lo discutas; revisa si el documento lo cumple.
```

## Tarea — plan de requisitos
```markdown
## Tarea
Revisión adversarial con el consejo de `/advisor`. Busca, citando sección o R/AE:
1. Requisitos que se contradicen entre sí.
2. Casos que el plan no cubre: ‹los bordes propios del dominio: quien nunca responde, responde dos veces, vuelve días después, varias peticiones en desorden…›.
3. Riesgos de que el sistema mienta, invente o actúe sin permiso a pesar de los requisitos.
4. Criterios de aceptación no verificables o que no cubren su requisito.
5. Lo que falta para pasar de plan a construcción.
```

## Tarea — plan técnico
```markdown
## Tarea
Revisión adversarial con el consejo de `/advisor`, enfocada en ‹Planning Contract, unidades U0–Un, Verification Contract›. Busca, citando sección, U o R:
1. Requisitos sin unidad que los construya, o unidades que no trazan a ningún requisito.
2. Orden y dependencias: qué se rompe si una unidad se entrega sin la siguiente; bloqueos de entrada que el resto da por resueltos.
3. Concurrencia y tiempo: relojes, duplicados, respuestas tardías o en desorden, reintentos, crons que se solapan, idempotencia.
4. Riesgos de que el sistema mienta, invente o hable cuando debía callar que el diseño no cierra con una guarda determinista.
5. Verificación: pruebas no ejecutables o que no prueban lo que dicen, pruebas que tocarían usuarios o datos reales, huecos entre la Definition of Done y los criterios de aceptación.
6. Lo que falta para que un desarrollador empiece mañana sin preguntar.
```

## Tarea — diseño de agente (bot, sesión operativa, multiagente)
```markdown
## Tarea
Revisión adversarial con el consejo de `/advisor`. Busca, citando sección:
1. Dónde el agente puede afirmar algo que no verificó, o reportar «hecho» sin evidencia de la fuente autoritativa.
2. Instrucciones que chocan entre sí o con las guardas deterministas; qué gana cuando chocan.
3. Canales entre agentes: mensajes que se pierden, se duplican o llegan a quien no es; qué pasa si un agente se reinicia a mitad.
4. Costos y bucles: qué puede disparar llamadas sin tope; qué corta el bucle.
5. Cómo se sabría que el agente está fallando en silencio, y quién se entera.
```

## Salida común (va siempre al final)
```markdown
## Salida
Un único fichero nuevo `revision.md` en la raíz: veredicto en 5 líneas; luego tabla hallazgo · sección/U/R · gravedad (crítico/alto/medio) · base (leído/inferido) · propuesta en una línea. No edites el documento revisado.

Termina con un commit en la rama nueva `revision/‹slug›` cuyo mensaje empiece por `LISTO:` (o `BLOQUEADO:` y el motivo)‹; haz push›. No abras PR.
```

Opcional (idea de robertoecf/adversarial-review): si quien pide ya tiene su propia lista de dudas, pásala como `dudas-propias.md` y pide una columna «coincide» (auditor · nosotros · ambos) para separar lo que solo vio el auditor.
