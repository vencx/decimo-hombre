# Décimo hombre · Tenth man

*[Read in English](README.md)*

> Cuando nueve están de acuerdo, el décimo tiene la obligación de buscar por qué están equivocados.

Plugin de Claude Code para **revisión adversaria de planes, specs y diseños** por un **auditor aislado**: otra sesión de Claude con `/advisor` (Fable por defecto) que solo ve el documento y un brief, nunca tu conversación. Corre **en la nube** (Claude Code web, repo privado en GitHub) o **en local** (sesión de `claude` aparte en tmux).

Dos skills, el mismo motor: **`decimo-hombre`** (español) y **`tenth-man`** (inglés).

## Por qué otra skill de revisión
Casi todas las de «abogado del diablo» critican dentro de la misma sesión, y el crítico hereda los puntos ciegos de quien escribió el plan. Esta:
- **Aísla al auditor**: sesión aparte, sin contexto compartido.
- **Escanea datos personales y secretos** antes de que algo salga de tu máquina (teléfonos, correos, IDs de WhatsApp, cadenas tipo clave y tus propias regex); no sigue si el escaneo no da 0.
- **Entrega un artefacto auditable**: `revision.md` en su propia rama, cerrado con un commit `LISTO:`/`BLOQUEADO:`. El silencio nunca cuenta como hecho.
- **Esquiva problemas reales que medimos**: el slash command va solo, un mensaje entre sesiones no arranca una sesión en la nube (`claude -p "<prompt>" --cloud <id>` sí), una carpeta nueva pide aceptar el diálogo de confianza, y las copias dentro de `~/.claude` no se suben.

## Instalar
```
/plugin marketplace add vencx/decimo-hombre
/plugin install decimo-hombre@decimo-hombre
```
Requisitos: Claude Code con `/advisor`, `tmux`, `git`, `python3`; para la nube, además `gh` con sesión iniciada y Claude Code web.

## Usar
Pídele a Claude: *«décimo hombre a este plan: docs/plans/checkout-v2.md, en la nube»*. Escribe el brief desde una plantilla (requisitos · técnico · diseño de agente), prepara la copia limpia, lanza al auditor, espera el commit y trae `revision.md` junto a tu plan.

Lo privado de cada usuario (dónde queda la revisión, a quién se avisa, regex extra de datos personales) va en `~/.claude/docs/decimo-hombre-anexo.md`, que nunca forma parte del plugin.

## Licencia
MIT
