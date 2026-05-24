# Roadmap — Aletheia

| # | Fase | Estado |
|---|------|--------|
| 0 | Preparación y seguridad conceptual | ✅ Completa |
| 1 | Repositorio, entorno y CLI base | ✅ Completa |
| 2 | Descarga de datos históricos | ✅ Completa |
| 3 | Validación de datos | Pendiente |
| 4 | Análisis exploratorio (Ruby + R) | Pendiente |
| 5 | Especificación de estrategias | Pendiente |
| 6 | Backtesting conservador | Pendiente |
| 7 | Motor de riesgo | Pendiente |
| 8 | Alertas históricas y offline | Pendiente |
| 9 | Paper trading | Pendiente |
| 10 | Monitoreo en tiempo real | Pendiente |
| 11 | Arbitraje teórico con grafos | Pendiente |
| 12 | Sugerencias de órdenes sin ejecución | Pendiente |
| 13 | Spot Testnet / dry-run operacional | Pendiente |
| 14 | Ejecución real restringida (opcional y tardía) | Pendiente |

## Detalle por fase completada

### Fase 0 — Preparación y seguridad conceptual ✅

- `docs/risk_policy.md`
- `docs/execution_policy.md`
- `docs/security_policy.md`
- `config/app.yml` (`dry_run: true`, `trading_enabled: false`)
- `config/risk.yml` (kill switch, límites)
- `lib/aletheia/safety.rb` (verificación estricta de flags de seguridad)

### Fase 1 — Repositorio, entorno y CLI base ✅

- Repositorio Git con estructura base
- `Gemfile` con dependencias núcleo
- `db/schema.sql` (tablas `klines`, `data_quality_reports`, `strategy_runs`, `simulated_trades`)
- `bin/aletheia` con comandos `doctor`, `init_db`, `help`
- Configuración YAML separada del código
- Suite RSpec funcionando (45 tests, 0 fallos)

### Fase 2 — Descarga de datos históricos ✅

- `lib/aletheia/binance/public_data_downloader.rb` — ZIPs de data.binance.vision
- `lib/aletheia/binance/rest_client.rb` — `/api/v3/klines` con paginación automática
- `lib/aletheia/storage/kline_repository.rb` — inserción idempotente en SQLite
- `bin/download_klines` — CLI con `--symbol`, `--interval`, `--from`, `--to`
- Reporte Markdown generado en `reports/data_quality/` por cada ejecución
- No requiere API key de trading. Solo Spot.
