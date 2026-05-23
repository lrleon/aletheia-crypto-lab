# Politica de Riesgo

El sistema funciona bajo el principio de riesgo minimo y conservacion de capital. Aletheia es un laboratorio de investigacion, no un bot autonomo para ganar dinero.

## Alcance de Fase 0

En Fase 0 no hay ejecucion real, paper trading ni sugerencias operativas. El objetivo es definir limites antes de escribir codigo que pueda inducir decisiones financieras.

## Limites iniciales

- Mercado permitido: Spot.
- Mercados prohibidos: futures, margin y cualquier forma de leverage.
- Retiros por API: prohibidos.
- Maximo de posiciones abiertas en fases iniciales: 1.
- Tamano maximo de posicion configurado: 100 USDT.
- Perdida diaria maxima configurada: 10 USDT.
- Perdida semanal maxima configurada: 25 USDT.
- Maximo de perdidas consecutivas configurado: 2.

Estos limites son techos conservadores para simulacion o fases futuras. No autorizan ejecucion real.

## Kill switch

El kill switch inicia habilitado en `config/risk.yml`:

- `kill_switch.enabled: true`
- `kill_switch.trading_allowed: false`
- `kill_switch.alerts_allowed: true`

Si hay errores no controlados, configuracion ambigua, datos sospechosos o dudas sobre el estado operativo, el sistema debe asumir trading deshabilitado.

## Orden de seguridad

Antes de cualquier alerta o sugerencia futura, el flujo debe ser:

```text
observe -> validate -> simulate -> risk check -> report -> review
```

No se debe saltar directamente de una senal a una orden.

## Confirmacion humana

Toda operacion real futura, si llega a existir, debe requerir confirmacion humana explicita y no persistente. La configuracion no puede eliminar este requisito.
