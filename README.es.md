# Décimo hombre · Tenth man

*[Read in English](README.md)*

> Cuando nueve están de acuerdo, el décimo tiene la obligación de buscar por qué están equivocados.

Plugin de Claude Code para **revisión adversaria de planes, specs y diseños** por un **auditor aislado**: otra sesión de Claude con `/advisor` (Fable por defecto) que solo ve el documento y un brief, nunca tu conversación. Corre **en la nube** (Claude Code web, repo privado en GitHub) o **en local** (sesión de `claude` aparte en tmux).

Dos skills, el mismo motor: **`decimo-hombre`** (español) y **`tenth-man`** (inglés).

## Por qué esta
Escribiste el plan, lo releíste y te gusta. Justo ahí está el problema: quien revisa después de haber vivido la misma conversación tiende a ver lo que tú ves, y a pasar por alto lo mismo que tú.

El décimo hombre le entrega tu documento a una sesión de Claude nueva, que no te conoce. Recibe el documento y un brief corto, nada más, y su único trabajo es encontrar dónde te equivocas.

Lo que nos importó al construirla:
- **Nada personal se escapa por descuido.** Antes de que la copia salga, se revisa en busca de teléfonos, correos, IDs de chat y cualquier cosa con pinta de clave. Si aparece algo, se detiene y te dice dónde.
- **«Hecho» significa que hay algo que leer.** La revisión llega como un archivo en su propia rama, con un commit que dice LISTO o BLOQUEADO. Una sesión callada no es una sesión que terminó.
- **Los tropiezos ya están resueltos.** Lograr que una sesión aislada de verdad arranque a trabajar, en la nube o en local, tiene trampas poco obvias. Nos caímos en ellas para que tú no tengas que hacerlo.

## Instalar
```
/plugin marketplace add vencx/decimo-hombre
/plugin install decimo-hombre@decimo-hombre
```
Requisitos: Claude Code con `/advisor`, `tmux`, `git`, `python3`; para la nube, además `gh` con sesión iniciada, Claude Code web y la GitHub App de Claude instalada en todos tus repos, para que la nube pueda subir la revisión.

## Usar
Pídele a Claude: *«décimo hombre a este plan: docs/plans/checkout-v2.md, en la nube»*. Escribe el brief desde una plantilla (requisitos · técnico · diseño de agente), prepara la copia limpia, lanza al auditor, espera el commit y trae `revision.md` junto a tu plan.

Lo privado de cada usuario (dónde queda la revisión, a quién se avisa, regex extra de datos personales) va en `~/.claude/docs/decimo-hombre-anexo.md`, que nunca forma parte del plugin.

## Licencia
MIT
