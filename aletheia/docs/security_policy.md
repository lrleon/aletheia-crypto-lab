# Politica de Seguridad

## Principios

La seguridad del proyecto se basa en minimo privilegio, configuracion explicita y fallos conservadores.

En Fase 0 no se necesitan API keys reales. Si en fases futuras se usan credenciales, deben estar fuera de Git y con permisos estrictamente necesarios.

## Secretos y API keys

- No guardar API keys reales en el repositorio.
- No registrar secretos en logs, reportes, excepciones ni salidas de CLI.
- No compartir claves entre lectura, paper trading y ejecucion futura.
- No usar claves con permiso de retiro.
- No usar claves con permisos de futures, margin o leverage.
- Preferir claves read-only para descarga o consulta de datos.

## Archivos de entorno

`.env.example` solo debe contener nombres de variables y valores vacios o seguros. Los archivos `.env` locales deben permanecer ignorados por Git.

## Configuracion segura

Toda configuracion operativa debe iniciar apagada:

- `dry_run: true`
- `trading_enabled: false`
- `paper_trading_enabled: false`
- `execution.enabled: false`
- `withdrawals_allowed: false`
- `human_confirmation_required: true`

## Logs

Los logs deben registrar acciones importantes sin incluir secretos. Cualquier mensaje relacionado con credenciales debe mencionar solo el nombre de la variable o el origen de configuracion, nunca el valor.

## Respuesta ante incidentes

Si se sospecha exposicion de credenciales:

1. Revocar la clave afectada en Binance.
2. Revisar logs y reportes locales.
3. Rotar credenciales si aplica.
4. Mantener `trading_enabled: false`.
5. Documentar el incidente en `journal/` sin incluir secretos.

