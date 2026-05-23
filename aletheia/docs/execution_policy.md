# Politica de Ejecucion

## Alcance

Aletheia no ejecuta ordenes reales en Fase 0. Cualquier modulo futuro de ejecucion debe partir de `dry_run: true`, `trading_enabled: false` y `execution.enabled: false`.

El proyecto permite investigar, validar datos, simular, generar reportes y emitir alertas. No permite trading autonomo con dinero real.

## Reglas obligatorias

- Spot only.
- No futures.
- No margin.
- No leverage.
- No withdrawals by API.
- No autonomous real-money trading.
- No hidden execution paths.
- Human confirmation obligatoria antes de cualquier orden real futura.
- Kill switch operativo antes de cualquier capa de ejecucion futura.
- Maximo una posicion abierta en fases iniciales.
- Tamanos de posicion pequenos y definidos en configuracion.

## Estados permitidos

| Estado | Permitido en Fase 0 | Requisito |
|---|---:|---|
| Lectura de configuracion | Si | Sin secretos reales |
| Descarga de datos publicos | Futuro | Solo fuentes documentadas |
| Backtesting | Futuro | Datos validados |
| Alertas | Futuro | Risk engine previo |
| Paper trading | No en Fase 0 | Configuracion explicita futura |
| Orden real | No | Fase tardia, revision humana y kill switch |

## Confirmacion humana

Si una fase futura incorpora una ruta de orden real, debe exigir confirmacion humana explicita por cada orden. La confirmacion no puede quedar preaprobada por variable de entorno, archivo de configuracion o flag persistente.

## Fallo seguro

Ante errores de configuracion, excepciones no controladas, limites de riesgo ambiguos o estado operativo desconocido, el sistema debe asumir ejecucion deshabilitada.

