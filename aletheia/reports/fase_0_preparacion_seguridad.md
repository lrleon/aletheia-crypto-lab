# Fase 0 - Preparacion y Seguridad Conceptual

Fecha: 2026-05-23

## Objetivo

Definir limites antes de escribir codigo que pueda inducir decisiones financieras.

## Entregables completados

| Entregable | Estado | Archivo |
|---|---|---|
| Politica de riesgo | Completado | `docs/risk_policy.md` |
| Politica de ejecucion | Completado | `docs/execution_policy.md` |
| Politica de seguridad | Completado | `docs/security_policy.md` |
| Variables de entorno de ejemplo | Completado | `.env.example` |
| Configuracion de riesgo | Completado | `config/risk.yml` |
| Configuracion de aplicacion | Completado | `config/app.yml` |

## Hitos

| Hito | Resultado |
|---|---|
| 0.1 Reglas de alcance escritas | Documentadas en README y politicas |
| 0.2 Prohibicion de futures, margin y leverage | Definida en politicas y configuracion |
| 0.3 `dry_run: true` por defecto | Definido en `config/app.yml` |
| 0.4 Politica de API keys escrita | Definida en `docs/security_policy.md` |
| 0.5 Kill switch definido conceptualmente | Definido en `docs/risk_policy.md` y `config/risk.yml` |

## Defaults de seguridad

- `dry_run: true`
- `trading_enabled: false`
- `paper_trading_enabled: false`
- `human_confirmation_required: true`
- `execution.enabled: false`
- `withdrawals_allowed: false`
- `kill_switch.enabled: true`
- `kill_switch.trading_allowed: false`

## Verificacion realizada

- Se confirmo que no existen archivos de politica faltantes para Fase 0.
- Se agregaron los archivos de configuracion pedidos por el plan tecnico.
- Se mantuvieron las variantes `.example.yml` existentes como referencia.
- `bin/aletheia doctor` verifica los defaults seguros de aplicacion y riesgo.
- El proyecto queda fijado a Ruby 3.3.10 mediante `.ruby-version`.
- No se agrego codigo de ejecucion real.
- No se agregaron secretos ni API keys reales.

## Nota de pruebas

El comando `bin/aletheia doctor` pasa con la configuracion segura. La suite `ruby -S bundle exec rake spec` pasa con Ruby 3.3.10, 14 ejemplos y 0 fallos.
