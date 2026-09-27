# Revisión adversaria de plan.md

## Veredicto
1. Plan **no listo para construir**: R2 y R3 no están garantizados por el diseño (§Diseño no filtra cancelación ni lee `recordada`).
2. Casos sin cubrir: cita movida, cron caído/solapado, bordes de la ventana y zona horaria.
3. §Verificación solo prueba el camino feliz de R1; R2, R3 y los bordes quedan sin prueba.

## Hallazgos
| # | Hallazgo | Sección / R | Gravedad | Propuesta |
|---|---|---|---|---|
| 1 | R3 no se cumple por diseño: la consulta (l.7) no filtra `recordada=false`; el flag se escribe (l.8) pero nunca se lee, y se marca *después* de enviar → dos ejecuciones solapadas o un fallo entre envío y UPDATE producen doble correo. | §Diseño l.7–8 · R3 | Alta | Reclamar antes de enviar: `UPDATE citas SET recordada=true WHERE id=$1 AND recordada=false RETURNING id` (solo envía quien obtiene fila), o tabla `recordatorios_enviados` con `UNIQUE(cita_id, fecha_hora)`. |
| 2 | R2 ausente del diseño: la consulta no excluye citas canceladas; además hay carrera si cancela entre la consulta y el envío. | §Diseño l.7 · R2 | Alta | Añadir `AND estado <> 'cancelada'` en la consulta y re-comprobar estado en el UPDATE de reclamo (mismo WHERE). |
| 3 | Cita movida: si ya se recordó y se reprograma, `recordada=true` bloquea el aviso de la nueva fecha (viola R1); si se mueve a <23 h, nunca entra en la ventana. | §Diseño l.8 · R1 | Alta | Resetear `recordada=false` al cambiar `fecha_hora`, o deduplicar por clave `(cita_id, fecha_hora)`. |
| 4 | Ventana [23,24) frágil: un cron caído o retrasado una hora pierde citas en silencio; bordes inclusivo/exclusivo sin definir → 0 o 2 disparos; citas creadas a <24 h nunca reciben aviso. | §Diseño l.7 · R1 | Media | Ventana de recuperación: `fecha_hora > now() AND fecha_hora <= now() + interval '24 h' AND recordada=false`; bordes explícitos. |
| 5 | Zona horaria no especificada: ni la TZ del cron ni el tipo de columna (`timestamptz` vs local); UTC vs America/Bogota desplaza la ventana 5 h. | §Diseño l.7 · R1 | Media | Guardar `timestamptz`, comparar contra `now()` en BD y fijar la TZ solo para formatear el correo. |
| 6 | §Verificación prueba solo R1 feliz y en el borde exacto «a 24 h»; nada para R2 (cancelar), R3 (cron doble/concurrente), cita movida ni cron caído; asserta en el buzón, no en la fila. | §Verificación l.10 · R1–R3 | Alta | Casos: cancelada → 0 correos; cron ejecutado 2 veces en paralelo → 1 correo y `recordada=true`; cita movida → 1 aviso por fecha; cita a 20 h → recibe aviso. BASE→ACTO→ASSERT sobre la tabla y el conteo de envíos. |
