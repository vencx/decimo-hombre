# Plan: recordatorio de citas por correo
## Requisitos
- R1: 24 h antes de cada cita se envía un correo de recordatorio.
- R2: si el cliente cancela, no se envía nada.
- R3: nunca se envían dos recordatorios para la misma cita.
## Diseño
- Un cron cada hora busca citas entre 23 y 24 h en el futuro y envía el correo.
- Al enviar se marca `recordada=true`.
## Verificación
- Crear una cita a 24 h y mirar que llegue el correo.
