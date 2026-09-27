---
name: decimo-hombre
description: "Revisión adversaria de un plan, spec, diseño o documento por un auditor AISLADO (otra sesión de Claude con /advisor, sin tu contexto), en la nube o en local, sobre una copia limpia sin datos personales, con entrega auditable (commit LISTO:/BLOQUEADO:). Úsala cuando pidan «revisión adversaria», «décimo hombre», «mándalo a revisión en la nube», «que lo revise Fable/el auditor», «stress-test del plan», «busca huecos antes de construir», o tras /ce-plan antes de implementar algo caro de revertir. No es para revisar un diff de código (usa code-review) ni para pedir una segunda opinión rápida en la misma sesión."
---

# Décimo hombre

Regla del décimo hombre: cuando nueve están de acuerdo, el décimo tiene la obligación de buscar por qué están equivocados. Aquí el décimo es una sesión de Claude aparte, con un advisor fuerte, que **no comparte tu contexto**: solo ve el documento y un brief. Ese aislamiento es el valor; si revisas en tu misma sesión, heredas los mismos puntos ciegos que escribieron el plan.

## Cuándo invocarla
Vale la pena cuando equivocarse sale caro de revertir (producción, dinero, datos de clientes, migraciones, agentes que hablan solos con clientes) y el documento ya está escrito. Una por documento: requisitos y plan técnico son dos revisiones distintas.
| Flujo | Momento |
|---|---|
| Compound Engineering | Tras `/ce-brainstorm` si los requisitos son grandes o polémicos; **siempre tras `/ce-plan`**, después de la revisión rápida que ya hagas (otro modelo, un compañero, `/ce-doc-review`) y antes de `/ce-work`. Repetir si el plan se reescribe a fondo. |
| Superpowers | Tras `writing-plans` y antes de `executing-plans` / `subagent-driven-development`; opcional sobre el diseño que sale de `brainstorming`. |
| Sin framework | Sobre el PRD/spec, el RFC/ADR, el plan de migración, el system prompt de un agente o el runbook, antes del arranque del trabajo. |
No la uses para: cambios pequeños o reversibles, bugs (diagnostica primero), código ya escrito (`code-review`), ni como sustituto de una revisión rápida: el aislado encuentra lo que el contexto compartido no ve, no lo obvio.

## Modos
| Modo | Dónde corre | Cuándo |
|---|---|---|
| `nube` (por defecto) | Sesión de Claude Code en la nube, repo privado de GitHub | Revisiones largas; no ocupa tu máquina ni tu sesión |
| `local` | Sesión de `claude` aparte en tmux, en tu máquina, repo git local | Sin GitHub, o cuando la copia no debe salir de la máquina |

Mismas garantías en los dos: copia limpia, escaneo de PII = 0, `/advisor <modelo>` activo antes del prompt, mismo brief, mismo entregable.

## Anexo local
Si existe `~/.claude/docs/decimo-hombre-anexo.md`, léelo antes del paso 1: trae las reglas y rutas propias de quien usa la skill (a dónde se copia la revisión, a quién se avisa, regex extra de PII). El anexo manda sobre los valores por defecto de aquí.

## Requisito de una vez (modo nube)
Para que la nube suba la rama sola, el repo tiene que llegar CLONADO (GitHub App de Claude instalada en él). Si llega como copia empaquetada, el push da 403 y la revisión se lee en la sesión (ver «Si algo falla»). El paso 5 lo detecta: sin rama a los 30 min, lee la sesión. Sin esto, la revisión se hace pero se queda en la sesión.

## Procedimiento
1. **Elige qué va en la copia.** Solo el documento a revisar (y, si hace falta, 1–2 anexos que el documento cite como autoridad). Nada de volcados, logs ni conversaciones: el auditor no los necesita y ahí vive la PII.
2. **Escribe `BRIEF-REVISION.md`** con la plantilla que toque de `references/plantillas-brief.md` (requisitos · técnico · diseño de agente · otro). El brief dice qué ya está decidido y no se discute, qué revisar con foco numerado, y el formato de salida. Escríbelo para un lector en frío: sin «como ya sabes», con los nombres de sección reales del documento.
3. **Prepara la copia** (rechaza si el escaneo no da 0; limpia y repite, no lo saltes):
   `bash scripts/prepare_copy.sh <slug> <nube|local> <doc> BRIEF-REVISION.md`
   Imprime `DIR …` y, en nube, `REPO owner/dh-<slug>`. (`nube` y `cloud` valen igual.)
4. **Lanza** (el advisor va como slash command solo; el prompt va aparte):
   `bash scripts/launch.sh <nube|local> <DIR> "Lee y sigue entero BRIEF-REVISION.md de este repo. Entrega: revision.md en la rama nueva revision/<slug>, commit que empiece por LISTO: (o BLOQUEADO: y el motivo)<, y push si es nube>. No edites el documento revisado ni abras PR." [modelo=fable]`
   Nube: imprime `SESSION` y `VIEW <url>`; dale la URL al usuario. Local: imprime la sesión tmux.
5. **Espera el artefacto, no el silencio:**
   `bash scripts/wait_delivery.sh <nube|local> <owner/dh-slug | DIR> revision/<slug> 90` en segundo plano. Solo un commit `LISTO:`/`BLOQUEADO:` cuenta como entrega.
6. **Trae la revisión** junto al documento original (p. ej. `docs/plans/<fecha>-revision-<slug>.md`) y resume al usuario: veredicto, críticos en una línea cada uno, y cuánto trabajo pide antes de construir.

## Si algo falla
- Nube sin sesión o con error: repite el paso 4 una vez; si vuelve a fallar, ofrece el modo `local` con la misma carpeta (ya es un repo git).
- La sesión en la nube no arranca tras el paso 4: vuelve a mandar el prompt con `claude -p "<prompt>" --cloud <session_id>` desde la carpeta. No uses mensajes entre sesiones (SendMessage): llegan como texto y no la ponen a trabajar.
- El push de la nube falla con 403 («not in this session's authorized repository set»): la sesión recibió el repo como copia empaquetada y el proxy solo empuja a repos que son fuente de la sesión. La revisión SÍ está hecha: léela en la URL de la sesión o tráela con `claude --teleport <session_id>` desde la carpeta de la copia, y guárdala tú junto al plan. Medido 26-sep: `/web-setup` y la GitHub App en «All repositories» no lo evitaron en esa cuenta; el auditor no debe esquivar el 403 con otros tokens.
- 90 min sin entrega: abre la URL o `tmux attach -t dh-…` y mira qué pasó; di al usuario lo que ves, no lo que supones.

## Qué no hace
- No envía nada de clientes: si el documento solo tiene sentido con datos reales, sustitúyelos por sintéticos antes del paso 3.
- No decide por el usuario: la revisión propone; qué se acepta lo decide quien pidió el plan.
- No se usa para código ya escrito (eso es `code-review`) ni para una opinión rápida (eso cabe en la sesión).
