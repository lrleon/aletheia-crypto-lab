# Plan técnico de trabajo — Laboratorio prudente de trading algorítmico con Binance

## 0. Propósito

Este documento propone un plan de trabajo por fases para construir un laboratorio prudente de análisis de mercados cripto con datos de Binance, principalmente para `BTC/USDT` y `ETH/USDT`.

El objetivo inicial no es operar automáticamente, sino aprender, descargar datos, validar calidad, estudiar patrones, hacer backtesting, simular, generar alertas y refinar hipótesis. La ejecución real, si algún día se habilita, debe ser la última fase y permanecer bajo confirmación humana estricta.

El proyecto debe privilegiar:

- trading Spot únicamente;
- preservación de capital;
- explicabilidad;
- bajo tamaño de posición;
- pocas operaciones;
- bitácora completa;
- aprendizaje documentado;
- capacidad de pausa inmediata;
- automatización gradual, reversible y supervisada.

---

## 1. Respuesta corta: ¿por dónde empezar?

Empezaría por un MVP muy pequeño:

1. Crear el repositorio y la estructura base.
2. Definir configuración segura en modo solo lectura.
3. Descargar velas históricas oficiales de Binance para `BTCUSDT` y `ETHUSDT`.
4. Guardarlas en SQLite.
5. Validar calidad de datos.
6. Generar un primer reporte estadístico simple.
7. Solo después, implementar una estrategia mínima y hacer backtesting.

No empezaría por AI, ni por arbitraje, ni por ejecución de órdenes. Esas partes son atractivas, pero pueden inducir complejidad prematura. El primer objetivo debe ser tener datos confiables y saber si el sistema puede detectar errores.

### Primer hito realista

```text
Hito inicial:
Poder ejecutar un comando Ruby que descargue velas BTCUSDT/1h desde Binance,
las guarde en SQLite, valide duplicados/faltantes y genere un reporte Markdown
de calidad de datos.
```

---

## 2. Principios no negociables

- Solo Spot.
- Sin futures.
- Sin margin.
- Sin apalancamiento.
- Sin martingala.
- Sin copy trading.
- Sin señales externas opacas.
- Sin ejecución real en las primeras fases.
- Sin claves con permiso de retiro.
- Sin automatización completa.
- Dry-run por defecto.
- Kill switch obligatorio antes de cualquier módulo operativo.
- Máximo una posición abierta en fases iniciales.
- Tamaño pequeño de posición, por ejemplo 25–100 USDT.
- Las estrategias deben poder explicar por qué entrar y, sobre todo, por qué no entrar.

---

## 3. Software base recomendado

## 3.1 Sistema operativo

Recomendado:

- Linux, idealmente Ubuntu 24.04 o similar.
- Git.
- Make.
- SQLite CLI.
- Docker opcional, no obligatorio al inicio.

No recomiendo comenzar con Kubernetes, colas distribuidas o microservicios. Para este proyecto, al inicio, un proceso local bien probado vale más que una arquitectura sofisticada.

### Paquetes del sistema sugeridos

```bash
sudo apt update
sudo apt install -y \
  git curl wget unzip jq make cmake g++ sqlite3 libsqlite3-dev \
  pkg-config build-essential
```

---

## 3.2 Ruby

Ruby será el lenguaje principal del sistema.

Uso recomendado:

- descarga de datos;
- orquestación;
- almacenamiento;
- validación;
- backtesting inicial;
- motor de estrategias;
- motor de riesgo;
- alertas;
- reportes;
- eventual conexión restringida a Binance Spot.

### Librerías Ruby recomendadas

#### Núcleo del proyecto

```ruby
# Gemfile inicial sugerido
source "https://rubygems.org"

gem "binance-connector-ruby" # Conector oficial/liviano para API pública Binance
gem "sqlite3"                # Persistencia local
gem "sequel"                 # Capa sencilla para DB; alternativa: ActiveRecord
gem "dotenv"                 # Variables de entorno locales
gem "dry-configurable"       # Configuración limpia
gem "dry-validation"         # Validación de estructuras y contratos
gem "oj"                     # JSON rápido
gem "rubyzip"                # Leer ZIPs de data.binance.vision
gem "csv"                    # CSV estándar
gem "logger"                 # Logging base

group :development, :test do
  gem "rspec"
  gem "rubocop"
  gem "simplecov"
end
```

#### HTTP / WebSocket

Opciones:

```ruby
gem "faraday"                # HTTP simple y conocido
gem "websocket-client-simple" # WebSocket simple para prototipos
```

Más adelante se podría evaluar:

```ruby
gem "async"
gem "async-http"
gem "async-websocket"
```

La recomendación inicial es no complicarse con concurrencia avanzada. Primero, descarga histórica por REST o archivos públicos; después, WebSocket para monitoreo.

---

## 3.3 R

R debe usarse como laboratorio estadístico, no como núcleo operacional.

Uso recomendado:

- exploración de retornos;
- visualización;
- volatilidad;
- drawdowns;
- distribución de retornos;
- análisis de sensibilidad;
- comparación de estrategias;
- reportes exploratorios;
- prototipos de modelos estadísticos.

### Librerías R recomendadas

```r
install.packages(c(
  "tidyverse",
  "data.table",
  "DBI",
  "RSQLite",
  "duckdb",
  "arrow",
  "lubridate",
  "xts",
  "zoo",
  "quantmod",
  "TTR",
  "PerformanceAnalytics",
  "ggplot2",
  "rmarkdown",
  "renv"
))
```

Uso por paquete:

| Paquete | Uso |
|---|---|
| `data.table` | Procesamiento rápido local de datos tabulares |
| `DBI` / `RSQLite` | Leer la base SQLite generada por Ruby |
| `duckdb` | Consultas analíticas locales si los datos crecen |
| `arrow` | Lectura/escritura Parquet en fases posteriores |
| `xts` / `zoo` | Series temporales financieras |
| `quantmod` | Prototipado financiero y visualización |
| `TTR` | Indicadores técnicos clásicos |
| `PerformanceAnalytics` | Métricas de riesgo, retorno y drawdown |
| `rmarkdown` | Reportes reproducibles |
| `renv` | Reproducibilidad del entorno R |

### Qué no pondría en R al principio

No pondría en R:

- conexión principal a Binance;
- motor de ejecución;
- orquestación del sistema;
- lógica final de riesgo;
- estado operativo.

R debe ayudar a pensar y analizar; Ruby debe mantener el sistema organizado y operativo.

---

## 3.4 C++

C++ debe reservarse para módulos donde realmente aporte.

Uso recomendado:

- búsqueda de ciclos de arbitraje;
- algoritmos de grafos;
- simulaciones intensivas;
- cálculo masivo de escenarios;
- optimización;
- procesamiento de order books si el volumen crece mucho.

No usaría C++ para:

- descarga simple de datos;
- lectura básica de CSV;
- generación de reportes;
- lógica de configuración;
- prototipos iniciales de estrategias.

### Librerías C++ recomendadas

```text
C++20 o C++23
CMake
nlohmann/json
SQLiteCpp o libsqlite3 directo
LEMON Graph Library o Boost.Graph
Catch2 o GoogleTest
fmt
spdlog
```

Uso por librería:

| Librería | Uso |
|---|---|
| `nlohmann/json` | Intercambio simple Ruby ↔ C++ |
| `LEMON` | Grafos, caminos mínimos, ciclos, optimización combinatoria |
| `Boost.Graph` | Alternativa muy potente para grafos |
| `SQLiteCpp` | Acceso cómodo a SQLite desde C++ si hiciera falta |
| `Catch2` | Pruebas unitarias modernas |
| `fmt` / `spdlog` | Formato y logging |

### Integración Ruby/C++ inicial

Mantenerla deliberadamente simple:

```text
Ruby genera input JSON/CSV
        ↓
Ruby invoca ejecutable C++
        ↓
C++ procesa grafos/arbitraje/simulaciones
        ↓
C++ devuelve JSON
        ↓
Ruby guarda resultados y genera reportes
```

Ejemplo:

```bash
ruby bin/build_arbitrage_graph --snapshot latest --output tmp/graph.json
./cpp/build/arbitrage_scan tmp/graph.json > tmp/arbitrage_result.json
ruby bin/import_arbitrage_result tmp/arbitrage_result.json
```

---

## 4. Datos que se deben descargar

## 4.1 Datos históricos principales

Fuente inicial recomendada:

- Binance Public Data / Data Collection.

Datos:

```text
spot/monthly/klines/BTCUSDT/1h
spot/monthly/klines/BTCUSDT/4h
spot/monthly/klines/BTCUSDT/1d
spot/monthly/klines/ETHUSDT/1h
spot/monthly/klines/ETHUSDT/4h
spot/monthly/klines/ETHUSDT/1d
```

Opcional:

```text
spot/monthly/klines/BTCUSDT/15m
spot/monthly/klines/ETHUSDT/15m
```

No comenzaría con `1m` ni con tick data. La tentación de ir a granularidad fina puede llevar a sobreoperar y a problemas de performance antes de entender el mercado.

### Rango inicial sugerido

Para backtesting inicial:

```text
BTCUSDT: 2021-01-01 hasta hoy
ETHUSDT: 2021-01-01 hasta hoy
```

Luego se puede ampliar hacia atrás, pero 2021 en adelante ya incluye regímenes interesantes: mercado alcista, caídas fuertes, lateralidad, recuperación y volatilidad elevada.

---

## 4.2 Datos actuales por REST

Endpoints útiles:

| Endpoint | Uso |
|---|---|
| `/api/v3/klines` | Velas históricas o recientes |
| `/api/v3/depth` | Order book por niveles |
| `/api/v3/ticker/bookTicker` | Mejor bid/ask para spread rápido |
| `/api/v3/ticker/24hr` | Estadísticas 24h |
| `/api/v3/aggTrades` | Trades agregados |
| `/api/v3/exchangeInfo` | Reglas de símbolos, filtros, precisión, mínimos |

Uso inicial recomendado:

1. Klines para completar datos recientes.
2. bookTicker para spread actual.
3. exchangeInfo para validar mínimos de orden y precisión.
4. depth solo cuando se estudie slippage o arbitraje.

---

## 4.3 Datos para arbitraje

Para estudiar arbitraje se necesitan más pares, pero no necesariamente para operar.

Activos base iniciales para grafo:

```text
USDT
BTC
ETH
BNB
SOL
USDC
FDUSD
```

Pares iniciales candidatos:

```text
BTCUSDT
ETHUSDT
ETHBTC
BNBUSDT
BNBBTC
BNBETH
SOLUSDT
SOLBTC
SOLETH
USDCUSDT
BTCUSDC
ETHUSDC
FDUSDUSDT
BTCFDUSD
ETHFDUSD
```

Estos pares deben validarse dinámicamente con `exchangeInfo`, porque no conviene asumir que todos están activos, líquidos o disponibles en la región.

### Datos mínimos para arbitraje teórico

- Bid actual.
- Ask actual.
- Cantidad disponible en best bid/ask.
- Profundidad del libro para varios niveles.
- Comisión estimada por par.
- Slippage estimado por tamaño.
- Restricciones de tamaño mínimo y step size.
- Latencia estimada.
- Timestamp de cada dato.

---

## 4.4 Datos que NO descargaría al inicio

No descargaría inicialmente:

- tick data completo;
- todos los pares de Binance;
- order book histórico masivo;
- altcoins ilíquidas;
- datos de futures;
- datos de margin;
- datos externos opacos.

Motivo: aumentan mucho la complejidad y pueden distraer del aprendizaje principal.

---

# 5. Distribución de responsabilidades por lenguaje

## 5.1 Ruby como columna vertebral

Ruby debe encargarse de:

- CLI del proyecto;
- configuración;
- cliente Binance;
- descarga de datos;
- validación;
- almacenamiento SQLite;
- definición de estrategias;
- backtesting inicial;
- motor de riesgo;
- alertas;
- reportes Markdown;
- integración con R y C++;
- bitácora;
- eventual capa de ejecución Spot restringida.

## 5.2 R como laboratorio estadístico

R debe encargarse de:

- exploración visual;
- análisis estadístico;
- comparación de estrategias;
- análisis de distribución de retornos;
- evaluación de drawdown;
- análisis por régimen;
- reportes investigativos;
- hipótesis preliminares.

## 5.3 C++ como acelerador selectivo

C++ debe encargarse de:

- escaneo de ciclos de arbitraje;
- algoritmos de grafos;
- simulaciones intensivas;
- optimización;
- procesamiento masivo cuando Ruby sea insuficiente.

## 5.4 Regla de decisión

```text
Si se puede hacer claro y suficientemente rápido en Ruby, hacerlo en Ruby.
Si es análisis estadístico exploratorio, hacerlo en R.
Si es un algoritmo intensivo y bien delimitado, hacerlo en C++.
```

---

# 6. Estructura recomendada del repositorio

```text
crypto-binance-lab/
  README.md
  ROADMAP.md
  Gemfile
  .ruby-version
  .env.example
  .gitignore

  bin/
    download_klines
    validate_klines
    analyze_market
    run_backtest
    generate_report
    monitor_market
    scan_arbitrage

  config/
    app.yml
    symbols.yml
    risk.yml
    strategies.yml

  db/
    schema.sql
    migrations/

  data/
    raw/
    processed/
    external/

  lib/
    crypto_lab.rb
    crypto_lab/binance/
    crypto_lab/storage/
    crypto_lab/validation/
    crypto_lab/analysis/
    crypto_lab/indicators/
    crypto_lab/strategies/
    crypto_lab/backtesting/
    crypto_lab/risk/
    crypto_lab/alerts/
    crypto_lab/arbitrage/
    crypto_lab/reporting/

  r/
    renv.lock
    notebooks/
    reports/
    scripts/

  cpp/
    CMakeLists.txt
    arbitrage/
      CMakeLists.txt
      src/
      include/
      tests/

  docs/
    architecture.md
    data_model.md
    data_sources.md
    risk_policy.md
    strategy_template.md
    backtesting_policy.md
    arbitrage.md
    execution_policy.md
    learning_log.md

  reports/
    data_quality/
    market_analysis/
    backtests/
    risk/
    arbitrage/

  logs/

  journal/
    YYYY-MM-DD.md

  spec/
```

---

# 7. Modelo de datos inicial

## 7.1 Tabla `klines`

```sql
CREATE TABLE klines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  symbol TEXT NOT NULL,
  interval TEXT NOT NULL,
  open_time INTEGER NOT NULL,
  close_time INTEGER NOT NULL,
  open NUMERIC NOT NULL,
  high NUMERIC NOT NULL,
  low NUMERIC NOT NULL,
  close NUMERIC NOT NULL,
  volume NUMERIC NOT NULL,
  quote_asset_volume NUMERIC,
  number_of_trades INTEGER,
  taker_buy_base_volume NUMERIC,
  taker_buy_quote_volume NUMERIC,
  source TEXT NOT NULL,
  downloaded_at INTEGER NOT NULL,
  is_complete INTEGER NOT NULL DEFAULT 1,
  data_quality_status TEXT NOT NULL DEFAULT 'unknown',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE(symbol, interval, open_time)
);
```

## 7.2 Tabla `data_quality_reports`

```sql
CREATE TABLE data_quality_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  symbol TEXT NOT NULL,
  interval TEXT NOT NULL,
  from_time INTEGER NOT NULL,
  to_time INTEGER NOT NULL,
  expected_count INTEGER NOT NULL,
  actual_count INTEGER NOT NULL,
  missing_count INTEGER NOT NULL,
  duplicate_count INTEGER NOT NULL,
  invalid_count INTEGER NOT NULL,
  suspicious_count INTEGER NOT NULL,
  status TEXT NOT NULL,
  report_path TEXT,
  created_at INTEGER NOT NULL
);
```

## 7.3 Tabla `strategy_runs`

```sql
CREATE TABLE strategy_runs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  strategy_name TEXT NOT NULL,
  strategy_version TEXT NOT NULL,
  symbol TEXT NOT NULL,
  interval TEXT NOT NULL,
  from_time INTEGER NOT NULL,
  to_time INTEGER NOT NULL,
  parameters_json TEXT NOT NULL,
  assumptions_json TEXT NOT NULL,
  result_json TEXT,
  status TEXT NOT NULL,
  created_at INTEGER NOT NULL
);
```

## 7.4 Tabla `simulated_trades`

```sql
CREATE TABLE simulated_trades (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  strategy_run_id INTEGER NOT NULL,
  symbol TEXT NOT NULL,
  side TEXT NOT NULL,
  entry_time INTEGER NOT NULL,
  exit_time INTEGER,
  entry_price NUMERIC NOT NULL,
  exit_price NUMERIC,
  quantity NUMERIC NOT NULL,
  quote_size NUMERIC NOT NULL,
  fees NUMERIC NOT NULL DEFAULT 0,
  slippage_estimate NUMERIC NOT NULL DEFAULT 0,
  pnl NUMERIC,
  pnl_percent NUMERIC,
  entry_reason TEXT NOT NULL,
  exit_reason TEXT,
  risk_snapshot_json TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY(strategy_run_id) REFERENCES strategy_runs(id)
);
```

---

# 8. Fases, hitos y entregables

---

## Fase 0 — Preparación y seguridad conceptual

### Objetivo

Definir límites antes de escribir código que pueda inducir decisiones financieras.

### Entregables

- `docs/risk_policy.md`
- `docs/execution_policy.md`
- `docs/security_policy.md`
- `.env.example`
- `config/risk.yml`
- `config/app.yml`

### Hitos

| Hito | Resultado esperado |
|---|---|
| 0.1 | Reglas de alcance escritas |
| 0.2 | Prohibición explícita de futures/margin/apalancamiento |
| 0.3 | Modo `dry_run: true` por defecto |
| 0.4 | Política de API keys escrita |
| 0.5 | Kill switch definido conceptualmente |

### Criterios de aceptación

- No existe código de ejecución real.
- No hay claves reales en el repositorio.
- Toda configuración operativa empieza apagada.
- El proyecto se puede pausar manualmente.

### Evaluación del aprendizaje

Preguntas:

- ¿Qué riesgos quiero evitar?
- ¿Qué significa preservar capital?
- ¿Qué condiciones me obligan a detener el proyecto?
- ¿Qué partes de la automatización podrían inducirme a sobreoperar?

---

## Fase 1 — Repositorio, entorno y CLI base

### Objetivo

Crear una base técnica limpia, reproducible y simple.

### Entregables

- Repositorio Git.
- `README.md`.
- `ROADMAP.md`.
- `Gemfile`.
- `.ruby-version`.
- CLI inicial en `bin/`.
- Configuración base en YAML.
- Primeras pruebas con RSpec.

### Hitos

| Hito | Resultado esperado |
|---|---|
| 1.1 | `bundle install` funciona |
| 1.2 | `rspec` funciona |
| 1.3 | `ruby bin/crypto_lab --help` funciona |
| 1.4 | Configuración YAML se carga correctamente |
| 1.5 | SQLite local inicializado |

### Criterios de aceptación

- Un nuevo clon del repositorio puede instalar dependencias.
- La configuración está separada del código.
- No hay dependencias innecesarias.
- Ruby puede abrir la base SQLite.

### Resultado esperado

```text
El proyecto existe, arranca y tiene una base mínima para crecer.
```

---

## Fase 2 — Descarga de datos históricos

### Objetivo

Descargar datos históricos confiables desde Binance y guardarlos localmente.

### Fuentes

1. Binance Public Data para descargas masivas.
2. Binance REST `/api/v3/klines` para completar rangos recientes o pequeños.

### Entregables

- `lib/crypto_lab/binance/public_data_downloader.rb`
- `lib/crypto_lab/binance/rest_client.rb`
- `lib/crypto_lab/storage/kline_repository.rb`
- `bin/download_klines`
- `reports/data_quality/download_log_*.md`

### Hitos

| Hito | Resultado esperado |
|---|---|
| 2.1 | Descargar `BTCUSDT/1h` |
| 2.2 | Descargar `ETHUSDT/1h` |
| 2.3 | Descargar `4h` y `1d` |
| 2.4 | Guardar en SQLite sin duplicados |
| 2.5 | Repetir descarga sin alterar datos existentes |
| 2.6 | Completar datos recientes vía REST |

### Comando deseado

```bash
ruby bin/download_klines --symbol BTCUSDT --interval 1h --from 2021-01-01 --to 2026-05-16
```

### Criterios de aceptación

- Los datos se guardan con clave única `(symbol, interval, open_time)`.
- La descarga es idempotente.
- Los errores se registran.
- No se requiere API key de trading.
- No se descargan datos de futures.

### Evaluación del aprendizaje

Preguntas:

- ¿Cómo organiza Binance sus archivos históricos?
- ¿Qué diferencia hay entre descargar ZIPs públicos y consultar REST?
- ¿Dónde aparecen problemas de timestamp?
- ¿Qué tan costoso es completar datos recientes?

---

### 2.7 Visualización mínima de velas

#### Objetivo

Generar gráficos simples de las velas descargadas para inspección visual de continuidad, gaps, anomalías y consistencia general de los datos.

#### Entregables

- `bin/plot_klines` — CLI Ruby que extrae los datos de SQLite y llama al script R
- `r/scripts/plot_klines.R` — genera gráficos de velas en HTML interactivo
- `reports/charts/*.html` — archivos de salida para inspección en navegador

#### Hitos

| Hito | Resultado esperado |
|---|---|
| 2.7.1 | `bin/plot_klines --help` funciona |
| 2.7.2 | Exportar velas de SQLite a CSV temporal |
| 2.7.3 | `plot_klines.R` genera HTML con gráfico de velas |
| 2.7.4 | El HTML se guarda en `reports/charts/` con nombre descriptivo |
| 2.7.5 | Gaps y velas faltantes son visualmente distinguibles |

#### Criterios de aceptación

- No genera señales de compra/venta.
- No calcula estrategias.
- No induce decisiones operativas.
- Solo visualiza datos ya descargados y almacenados en SQLite.
- El gráfico muestra al menos: OHLC, volumen y eje de tiempo legible.

#### Restricciones

- R solo para visualización. Sin API secrets ni ejecución de órdenes.
- La CLI Ruby se limita a extraer datos y lanzar el script R.
- No requiere API key de Binance.

---

## Fase 3 — Validación de datos

### Objetivo

Evitar que datos defectuosos contaminen análisis y backtesting.

### Entregables

- `lib/crypto_lab/validation/kline_validator.rb`
- `lib/crypto_lab/validation/gap_detector.rb`
- `lib/crypto_lab/validation/duplicate_detector.rb`
- `bin/validate_klines`
- `reports/data_quality/*.md`

### Validaciones mínimas

- Velas faltantes.
- Velas duplicadas.
- Velas incompletas.
- Timestamps fuera de secuencia.
- `high < low`.
- `open` fuera de `[low, high]`.
- `close` fuera de `[low, high]`.
- Precios cero.
- Volumen negativo.
- Número de trades negativo.
- Intervalo inconsistente.
- Cambios sospechosos extremos.

### Hitos

| Hito | Resultado esperado |
|---|---|
| 3.1 | Detectar duplicados |
| 3.2 | Detectar gaps temporales |
| 3.3 | Detectar precios inválidos |
| 3.4 | Generar reporte Markdown |
| 3.5 | Bloquear backtesting sobre datos inválidos |

### Comando deseado

```bash
ruby bin/validate_klines --symbol BTCUSDT --interval 1h
```

### Criterios de aceptación

- Cada rango tiene estado: `valid`, `warning`, `invalid`.
- Un backtest no corre si los datos son inválidos.
- Las velas dudosas quedan marcadas, no borradas silenciosamente.

### Evaluación del aprendizaje

Preguntas:

- ¿Qué errores son comunes?
- ¿Cuántos gaps aparecen por símbolo e intervalo?
- ¿Qué problemas podrían falsear una estrategia?
- ¿Qué reglas de validación faltan?

---

## Fase 4 — Análisis exploratorio en Ruby y R

### Objetivo

Comprender los datos antes de diseñar estrategias.

### División de trabajo

Ruby:

- calcula métricas base reproducibles;
- guarda resultados;
- genera reportes simples.

R:

- analiza distribución;
- produce gráficos;
- estudia drawdowns;
- compara regímenes;
- genera reportes exploratorios.

### Indicadores iniciales

- Retornos simples.
- Retornos logarítmicos.
- Volatilidad móvil.
- Medias móviles simples y exponenciales.
- ATR.
- RSI.
- Volumen relativo.
- Rango de vela.
- Cuerpo de vela.
- Mechas.
- Drawdown.
- Máximo movimiento favorable.
- Máximo movimiento adverso.

### Entregables

- `lib/crypto_lab/analysis/returns.rb`
- `lib/crypto_lab/analysis/volatility.rb`
- `lib/crypto_lab/indicators/atr.rb`
- `lib/crypto_lab/indicators/rsi.rb`
- `r/scripts/exploratory_analysis.R`
- `r/reports/market_profile.Rmd`
- `reports/market_analysis/*.md`

### Hitos

| Hito | Resultado esperado |
|---|---|
| 4.1 | Retornos calculados |
| 4.2 | Volatilidad calculada |
| 4.3 | ATR y RSI calculados |
| 4.4 | Primer reporte RMarkdown |
| 4.5 | Comparación BTC vs ETH |
| 4.6 | Comparación 1h vs 4h vs 1d |

### Criterios de aceptación

- Los cálculos son reproducibles.
- Cada indicador tiene explicación.
- Los reportes distinguen observación de conclusión.
- No se acepta una estrategia todavía.

### Evaluación del aprendizaje

Preguntas:

- ¿BTC y ETH se comportan igual?
- ¿Qué intervalo parece menos ruidoso?
- ¿Qué volatilidad sería excesiva para operar?
- ¿Qué patrones desaparecen al cambiar de intervalo?

---

## Fase 5 — Especificación de estrategias

### Objetivo

Definir estrategias por escrito antes de codificarlas.

### Entregables

- `docs/strategy_template.md`
- `docs/strategies/conservative_momentum_v1.md`
- `docs/strategies/moderate_reversion_v1.md`
- `docs/strategies/breakout_volume_v1.md`
- `docs/strategies/market_avoidance_v1.md`

### Plantilla mínima

```markdown
# Estrategia: nombre

## Versión

## Hipótesis

## Símbolos permitidos

## Intervalos permitidos

## Condiciones de entrada

## Condiciones de salida

## Condiciones para no operar

## Riesgos conocidos

## Tamaño de posición

## Stop o invalidez

## Métricas de evaluación

## Supuestos conservadores

## Estado
```

### Familias iniciales

#### 5.1 Momentum conservador

Hipótesis:

> Si el precio muestra continuidad moderada, volumen acompañante y volatilidad no excesiva, puede existir una oportunidad de corto plazo con riesgo controlado.

#### 5.2 Reversión moderada

Hipótesis:

> Después de movimientos extendidos, puede haber rebotes, pero solo si el mercado muestra estabilización y no caída libre.

#### 5.3 Breakout con volumen

Hipótesis:

> Una ruptura de rango con volumen superior al promedio puede continuar, pero los falsos breakouts deben bloquearse con reglas de riesgo.

#### 5.4 Evitación de mercado

Hipótesis:

> Hay condiciones en las cuales no operar tiene valor positivo: volatilidad extrema, spread alto, datos dudosos, señales contradictorias o exceso de ruido.

### Hitos

| Hito | Resultado esperado |
|---|---|
| 5.1 | Plantilla de estrategia creada |
| 5.2 | Primera estrategia documentada |
| 5.3 | Reglas explícitas de no operación |
| 5.4 | Estrategia versionada |
| 5.5 | Estrategia lista para backtesting |

### Criterios de aceptación

- Ninguna estrategia se implementa sin documento.
- Cada estrategia tiene hipótesis falsable.
- Cada estrategia dice cuándo NO operar.
- Cada estrategia tiene criterios de invalidez.

### Evaluación del aprendizaje

Preguntas:

- ¿La estrategia es una hipótesis o un deseo?
- ¿Qué tendría que pasar para descartarla?
- ¿Cómo podría fallar?
- ¿Genera pocas señales o demasiadas?

---

## Fase 6 — Backtesting conservador

### Objetivo

Evaluar estrategias históricamente sin autoengaño.

### Entregables

- `lib/crypto_lab/backtesting/engine.rb`
- `lib/crypto_lab/backtesting/position.rb`
- `lib/crypto_lab/backtesting/portfolio.rb`
- `lib/crypto_lab/backtesting/metrics.rb`
- `lib/crypto_lab/backtesting/assumptions.rb`
- `bin/run_backtest`
- `reports/backtests/*.md`

### Supuestos obligatorios

- Comisión incluida.
- Slippage incluido.
- Spread incluido cuando aplique.
- Sin look-ahead bias.
- Sin operar velas incompletas.
- Sin ejecución perfecta.
- Máximo una posición abierta.
- Tamaño pequeño de posición.
- Resultados por año o régimen.

### Métricas mínimas

- Número de operaciones.
- Porcentaje ganador.
- Ganancia media.
- Pérdida media.
- Profit factor.
- Retorno acumulado.
- Drawdown máximo.
- Peor racha de pérdidas.
- Duración media.
- Sensibilidad a comisiones.
- Sensibilidad a slippage.
- Resultado por régimen.

### Hitos

| Hito | Resultado esperado |
|---|---|
| 6.1 | Backtest mínimo funcionando |
| 6.2 | Comisión incluida |
| 6.3 | Slippage incluido |
| 6.4 | Métricas generadas |
| 6.5 | Reporte Markdown generado |
| 6.6 | Estrategia aceptada, rechazada o devuelta a revisión |

### Comando deseado

```bash
ruby bin/run_backtest \
  --strategy conservative_momentum_v1 \
  --symbol BTCUSDT \
  --interval 4h \
  --from 2021-01-01 \
  --to 2026-05-16
```

### Criterios de aceptación

- El resultado es reproducible.
- Los supuestos están escritos en el reporte.
- El reporte incluye razones para desconfiar del resultado.
- Ganar en el pasado no basta para aceptar la estrategia.

### Evaluación del aprendizaje

Preguntas:

- ¿La estrategia depende de pocos eventos?
- ¿Muere al agregar costos?
- ¿Tiene drawdown tolerable?
- ¿Falla en ciertos años?
- ¿El resultado sigue siendo razonable bajo supuestos pesimistas?

---

## Fase 7 — Motor de riesgo

### Objetivo

Crear una capa independiente que pueda bloquear señales.

### Entregables

- `lib/crypto_lab/risk/risk_engine.rb`
- `lib/crypto_lab/risk/exposure_rules.rb`
- `lib/crypto_lab/risk/volatility_rules.rb`
- `lib/crypto_lab/risk/spread_rules.rb`
- `lib/crypto_lab/risk/liquidity_rules.rb`
- `config/risk.yml`
- `reports/risk/*.md`

### Reglas iniciales

```yaml
risk:
  max_open_positions: 1
  max_position_size_usdt: 100
  default_position_size_usdt: 50
  max_daily_trades: 1
  max_weekly_trades: 3
  max_daily_loss_usdt: 10
  max_weekly_loss_usdt: 25
  min_confidence: medium
  dry_run: true
  trading_enabled: false
```

### Evaluaciones mínimas

- Exposición total.
- Pérdida máxima estimada.
- Spread.
- Volatilidad reciente.
- Liquidez.
- Slippage.
- Correlación BTC/ETH.
- Calidad de datos.
- Frecuencia reciente de operaciones.

### Hitos

| Hito | Resultado esperado |
|---|---|
| 7.1 | Riesgo bloquea señales débiles |
| 7.2 | Riesgo bloquea volatilidad excesiva |
| 7.3 | Riesgo bloquea spread excesivo |
| 7.4 | Riesgo limita exposición |
| 7.5 | Reporte explica cada bloqueo |

### Criterios de aceptación

- Toda señal pasa por riesgo.
- El motor puede responder `allowed: false`.
- Toda negativa tiene explicación.
- Las reglas son configurables y conservadoras.

### Evaluación del aprendizaje

Preguntas:

- ¿Cuántas señales bloqueó el motor?
- ¿Qué regla fue más importante?
- ¿El sistema evita operaciones malas?
- ¿Qué límite debe endurecerse?

---

## Fase 8 — Alertas históricas y alertas offline

### Objetivo

Probar cómo se verían las alertas sin operar ni monitorear en vivo.

### Entregables

- `lib/crypto_lab/alerts/alert.rb`
- `lib/crypto_lab/alerts/generator.rb`
- `lib/crypto_lab/alerts/renderer.rb`
- `bin/generate_historical_alerts`
- `reports/alerts/*.md`

### Tipos de alerta

- `possible_entry`
- `possible_exit`
- `risk_warning`
- `volatility_warning`
- `spread_warning`
- `data_quality_warning`
- `strategy_deviation`
- `do_not_trade`

### Formato mínimo

```json
{
  "type": "possible_entry",
  "symbol": "BTCUSDT",
  "interval": "4h",
  "price": 65000.0,
  "strategy": "conservative_momentum_v1",
  "conditions_met": [],
  "risks": [],
  "confidence": "medium",
  "recommendation": "manual_review",
  "explanation": "..."
}
```

### Hitos

| Hito | Resultado esperado |
|---|---|
| 8.1 | Alertas históricas generadas |
| 8.2 | Alertas clasificadas |
| 8.3 | Alertas bloqueadas por riesgo |
| 8.4 | Frecuencia de alertas medida |
| 8.5 | Revisión manual de muestra |

### Criterios de aceptación

- Las alertas no son excesivas.
- Las alertas explican razones y riesgos.
- Hay alertas explícitas de “no operar”.
- El reporte mide si las alertas inducirían sobreoperación.

### Evaluación del aprendizaje

Preguntas:

- ¿Las alertas aportan claridad?
- ¿Son demasiadas?
- ¿Cuántas terminarían mal?
- ¿Cuántas operaciones se evitarían?

---

## Fase 9 — Paper trading

### Objetivo

Simular operación viva sin dinero real.

### Entregables

- `lib/crypto_lab/paper_trading/account.rb`
- `lib/crypto_lab/paper_trading/order.rb`
- `lib/crypto_lab/paper_trading/execution_simulator.rb`
- `lib/crypto_lab/paper_trading/ledger.rb`
- `bin/run_paper_trading`
- `reports/paper_trading/weekly_*.md`

### Simulación mínima

- Balance USDT simulado.
- Posición BTC/ETH simulada.
- Órdenes limit simuladas.
- Órdenes no ejecutadas.
- Comisiones.
- Slippage.
- Registro de decisión humana.

### Hitos

| Hito | Resultado esperado |
|---|---|
| 9.1 | Cuenta simulada creada |
| 9.2 | Primera orden limit simulada |
| 9.3 | Orden no ejecutada registrada |
| 9.4 | Salida simulada registrada |
| 9.5 | Reporte semanal generado |

### Criterios de aceptación

- Funciona al menos varias semanas sin dinero real.
- Registra operaciones evitadas.
- Mide disciplina, no solo PnL.
- Permite concluir que no conviene avanzar.

### Evaluación del aprendizaje

Preguntas:

- ¿El sistema ayuda a esperar?
- ¿Cuántas señales fueron ignoradas correctamente?
- ¿El paper trading genera ansiedad?
- ¿Qué diferencia aparece frente al backtesting?

---

## Fase 10 — Monitoreo en tiempo real

### Objetivo

Leer mercado vivo sin ejecutar órdenes.

### Entregables

- `lib/crypto_lab/market_monitor/rest_monitor.rb`
- `lib/crypto_lab/market_monitor/websocket_monitor.rb`
- `lib/crypto_lab/market_monitor/spread_monitor.rb`
- `bin/monitor_market`
- `reports/market_monitor/*.md`

### Datos vivos mínimos

- Último precio.
- Klines recientes.
- Best bid/ask.
- Spread.
- Profundidad básica.
- Estado de API.

### Fuentes

- REST: `/api/v3/ticker/bookTicker`.
- REST: `/api/v3/depth`.
- WebSocket: `<symbol>@kline_<interval>`.
- WebSocket: `<symbol>@bookTicker`.

### Hitos

| Hito | Resultado esperado |
|---|---|
| 10.1 | Leer bookTicker por REST |
| 10.2 | Calcular spread |
| 10.3 | Leer kline por WebSocket |
| 10.4 | Detectar vela cerrada |
| 10.5 | Generar alerta viva sin ejecución |

### Criterios de aceptación

- El sistema monitorea sin operar.
- No se hace polling agresivo.
- WebSocket se reconecta con control.
- Las alertas quedan registradas.
- Se puede pausar manualmente.

### Evaluación del aprendizaje

Preguntas:

- ¿La señal viva se parece al backtest?
- ¿El spread cambia más de lo esperado?
- ¿Cuánto ruido aparece?
- ¿El monitoreo invita a mirar demasiado la pantalla?

---

## Fase 11 — Arbitraje teórico con grafos

### Objetivo

Estudiar oportunidades teóricas de arbitraje multinivel sin operar dinero real.

Esta fase debe ser tratada como investigación, no como promesa de rentabilidad. El arbitraje real en exchanges grandes suele ser difícil porque compites contra sistemas con menor latencia, mejor infraestructura y acceso más directo al libro.

### Idea matemática

Representar activos como nodos:

```text
USDT, BTC, ETH, BNB, SOL, USDC, FDUSD, ...
```

Representar conversiones como aristas dirigidas:

```text
USDT → BTC
BTC → ETH
ETH → USDT
```

Cada arista tiene una tasa efectiva:

```text
rate_effective = rate_market * (1 - fee) * (1 - slippage_estimate)
```

Para detectar ciclos rentables se transforma cada tasa:

```text
weight = -log(rate_effective)
```

Un ciclo con suma negativa sugiere arbitraje teórico:

```text
sum(weights) < 0
```

Equivalente:

```text
product(rate_effective_i) > 1
```

### Niveles de arbitraje

#### Nivel 1 — Triangular básico

Ejemplo:

```text
USDT → BTC → ETH → USDT
```

o:

```text
USDT → ETH → BTC → USDT
```

Objetivo: entender mecánica, fees, spread y profundidad.

#### Nivel 2 — Ciclos de 4 activos

Ejemplo:

```text
USDT → BTC → BNB → ETH → USDT
```

Objetivo: estudiar si aparecen oportunidades más complejas, aunque probablemente menos ejecutables.

#### Nivel 3 — Ciclos generales de N activos

Buscar ciclos en un grafo de muchos activos líquidos.

Objetivo: investigación algorítmica, no ejecución.

#### Nivel 4 — Arbitraje con profundidad

No usar solo best bid/ask. Simular tamaño de orden recorriendo niveles del order book.

Objetivo: estimar si la supuesta oportunidad sobrevive al tamaño real.

#### Nivel 5 — Arbitraje con latencia y ejecución parcial

Agregar:

- latencia;
- cambios de precio;
- ejecución parcial;
- cancelación;
- colas del order book;
- riesgo de quedar con un activo intermedio.

Objetivo: mostrar por qué un arbitraje aparente puede ser peligroso.

### Entregables Ruby

- `lib/crypto_lab/arbitrage/symbol_universe.rb`
- `lib/crypto_lab/arbitrage/order_book_snapshot.rb`
- `lib/crypto_lab/arbitrage/graph_builder.rb`
- `bin/build_arbitrage_graph`
- `bin/scan_arbitrage`

### Entregables C++

- `cpp/arbitrage/src/arbitrage_scan.cpp`
- `cpp/arbitrage/include/graph.hpp`
- `cpp/arbitrage/include/bellman_ford.hpp`
- `cpp/arbitrage/include/cycle_extractor.hpp`
- `cpp/arbitrage/tests/`

### Algoritmos candidatos

| Problema | Algoritmo |
|---|---|
| Ciclo negativo | Bellman-Ford |
| Ciclos simples acotados | DFS con límite de profundidad |
| Muchos ciclos | Johnson para ciclos simples, con cuidado de explosión combinatoria |
| Mejor conversión entre activos | Shortest path sobre pesos `-log(rate)` |
| Arbitraje con profundidad | Simulación por niveles del order book |

### Hitos

| Hito | Resultado esperado |
|---|---|
| 11.1 | Construir grafo desde bookTicker |
| 11.2 | Detectar ciclos triangulares teóricos |
| 11.3 | Incluir fees |
| 11.4 | Incluir spread bid/ask correctamente |
| 11.5 | Incluir profundidad del order book |
| 11.6 | Incluir slippage por tamaño |
| 11.7 | Rechazar oportunidades no ejecutables |
| 11.8 | Generar reporte de arbitraje teórico |

### Criterios de aceptación

- El sistema distingue arbitraje bruto de arbitraje neto.
- Las oportunidades desaparecen si no sobreviven a fees/spread/slippage.
- Se reporta riesgo de ejecución parcial.
- No se ejecuta ninguna orden.
- El reporte puede concluir “no hay oportunidad realista”.

### Evaluación del aprendizaje

Preguntas:

- ¿Cuántas oportunidades brutas desaparecen al agregar fees?
- ¿Cuántas desaparecen al agregar spread?
- ¿Cuántas desaparecen al agregar profundidad?
- ¿Cuánto afecta la latencia?
- ¿Qué tan frecuente es quedar con un activo intermedio?
- ¿Conviene seguir investigando esto o mantenerlo como ejercicio algorítmico?

---

## Fase 12 — Sugerencias de órdenes sin ejecución

### Objetivo

Generar propuestas de operación para revisión humana, sin enviarlas a Binance.

### Entregables

- `lib/crypto_lab/orders/suggested_order.rb`
- `lib/crypto_lab/orders/order_explainer.rb`
- `bin/suggest_order`
- `reports/suggested_orders/*.md`

### Formato sugerido

```json
{
  "mode": "suggestion_only",
  "symbol": "BTCUSDT",
  "side": "BUY",
  "order_type": "LIMIT",
  "suggested_price": "65000.00",
  "position_size_usdt": "50.00",
  "max_loss_estimate_usdt": "5.00",
  "strategy": "conservative_momentum_v1",
  "risk_level": "low",
  "allowed_by_risk_engine": true,
  "human_confirmation_required": true,
  "recommendation": "review_manually"
}
```

### Hitos

| Hito | Resultado esperado |
|---|---|
| 12.1 | Sugerencia generada |
| 12.2 | Riesgo puede bloquear sugerencia |
| 12.3 | Sugerencia incluye razón para no operar |
| 12.4 | Decisión humana registrada |
| 12.5 | Reporte de sugerencias aceptadas/rechazadas |

### Criterios de aceptación

- El sistema no ejecuta nada.
- La recomendación puede ser “no operar”.
- Toda sugerencia incluye invalidez y pérdida máxima estimada.
- La decisión humana queda registrada.

---

## Fase 13 — Spot Testnet / dry-run operacional

### Objetivo

Probar integración operativa en ambiente de test, sin dinero real.

### Entregables

- Cliente para Spot Testnet.
- Módulo de firma de requests.
- Pruebas de creación/cancelación de orden en testnet.
- Validación de filtros de exchange.
- Registro completo de órdenes testnet.

### Hitos

| Hito | Resultado esperado |
|---|---|
| 13.1 | Conectar a Spot Testnet |
| 13.2 | Leer balance testnet |
| 13.3 | Crear orden limit testnet |
| 13.4 | Cancelar orden testnet |
| 13.5 | Registrar ejecución o no ejecución |
| 13.6 | Probar kill switch |

### Criterios de aceptación

- Todo ocurre en testnet.
- No hay claves reales.
- No hay permisos de retiro.
- El kill switch funciona.
- Las pruebas demuestran que se puede operar y pausar.

---

## Fase 14 — Ejecución real restringida, opcional y tardía

### Objetivo

Permitir una operación real pequeña solo después de demostrar robustez.

### Condiciones previas

- Backtesting robusto.
- Paper trading estable.
- Testnet probado.
- Riesgo activo.
- Kill switch probado.
- Logs completos.
- API key separada.
- Sin retiros.
- IP restringida.
- Confirmación humana obligatoria.

### Límites iniciales

```yaml
live_trading:
  enabled: false
  require_human_confirmation: true
  allowed_market: spot
  allowed_order_types:
    - LIMIT
  max_position_size_usdt: 50
  max_open_positions: 1
  max_daily_trades: 1
  max_weekly_trades: 2
  max_daily_loss_usdt: 5
  max_weekly_loss_usdt: 15
```

### Hitos

| Hito | Resultado esperado |
|---|---|
| 14.1 | Modo real deshabilitado por defecto |
| 14.2 | Confirmación humana obligatoria |
| 14.3 | Primera orden real pequeña, si se justifica |
| 14.4 | Reporte post-operación |
| 14.5 | Decisión explícita de continuar, pausar o retroceder |

### Criterios de aceptación

- Ninguna orden real se envía automáticamente.
- Se puede pausar de inmediato.
- La operación real es pequeña.
- El reporte post-operación incluye aprendizaje.
- Si genera ansiedad, se vuelve a modo paper/alertas.

---

# 9. Plan de entregables por MVP

## MVP 1 — Datos históricos confiables

Entregables:

- Downloader Binance.
- SQLite schema.
- Inserción idempotente.
- Validador de datos.
- Reporte de calidad.

Resultado:

```text
Puedo descargar y validar datos sin operar.
```

---

## MVP 2 — Análisis exploratorio

Entregables:

- Indicadores base.
- Reportes Ruby.
- Reportes RMarkdown.
- Comparación BTC/ETH.

Resultado:

```text
Puedo entender mejor la estructura histórica del mercado.
```

---

## MVP 3 — Backtesting conservador

Entregables:

- Motor de backtesting.
- Primera estrategia.
- Métricas.
- Reporte con supuestos.

Resultado:

```text
Puedo probar hipótesis sin dinero real.
```

---

## MVP 4 — Riesgo y alertas

Entregables:

- Motor de riesgo.
- Alertas históricas.
- Alertas bloqueadas.
- Reporte de señales.

Resultado:

```text
El sistema puede decir “no operar”.
```

---

## MVP 5 — Paper trading

Entregables:

- Cuenta simulada.
- Órdenes simuladas.
- Bitácora.
- Reporte semanal.

Resultado:

```text
Puedo observar comportamiento vivo sin arriesgar capital.
```

---

## MVP 6 — Arbitraje teórico

Entregables:

- Grafo de activos.
- Detección de ciclos.
- Fees/spread/slippage.
- Reporte de oportunidades descartadas.

Resultado:

```text
Puedo estudiar arbitraje como problema algorítmico, sin asumir que es ejecutable.
```

---

## MVP 7 — Testnet

Entregables:

- Cliente testnet.
- Orden limit test.
- Cancelación test.
- Kill switch.

Resultado:

```text
Puedo probar la integración operativa sin dinero real.
```

---

# 10. Plan de aprendizaje por fase

## Después de cada fase

Registrar en `journal/YYYY-MM-DD.md`:

```markdown
# Aprendizaje YYYY-MM-DD

## Fase

## Qué intenté

## Qué funcionó

## Qué falló

## Qué aprendí

## Qué riesgo detecté

## Qué simplificaré

## Qué descartaré

## Próxima acción
```

## Preguntas permanentes

- ¿Estoy aprendiendo o buscando justificar una operación?
- ¿La complejidad está aumentando sin necesidad?
- ¿Esta estrategia opera demasiado?
- ¿Estoy considerando comisiones y slippage?
- ¿Qué puede salir mal?
- ¿Qué pasa si el mercado cambia de régimen?
- ¿Qué pasa si una orden no se ejecuta?
- ¿Qué pasa si se ejecuta parcialmente?
- ¿Qué pasa si quedo atrapado en un activo intermedio?
- ¿Este módulo reduce riesgo o solo aumenta confianza aparente?

---

# 11. Orden recomendado de implementación inmediata

## Semana 1 — Cimientos

- Crear repositorio.
- Crear `Gemfile`.
- Crear SQLite schema.
- Crear configuración YAML.
- Crear `.env.example`.
- Crear CLI mínima.
- Crear README.

## Semana 2 — Datos históricos

- Descargar BTCUSDT/1h.
- Descargar ETHUSDT/1h.
- Guardar en SQLite.
- Hacer descarga idempotente.
- Generar primer log.

## Semana 3 — Validación

- Detectar duplicados.
- Detectar gaps.
- Detectar precios inválidos.
- Generar reporte Markdown.
- Bloquear análisis si hay errores graves.

## Semana 4 — Análisis básico

- Calcular retornos.
- Calcular volatilidad.
- Calcular ATR/RSI.
- Exportar dataset a R.
- Generar primer RMarkdown.

## Semana 5 — Primera estrategia

- Documentar momentum conservador.
- Implementar reglas.
- Ejecutar backtest.
- Incluir comisión y slippage.
- Rechazar o revisar según resultado.

## Semana 6 — Riesgo y alertas

- Implementar motor de riesgo.
- Generar alertas históricas.
- Medir frecuencia.
- Evaluar si inducen sobreoperación.

## Semana 7+ — Paper trading y arbitraje teórico

- Paper trading con alertas.
- Grafo de arbitraje teórico.
- Detección de ciclos.
- Fees/spread/slippage.
- Reporte de oportunidades descartadas.

---

# 12. Fuentes técnicas iniciales

## Binance

- Binance Spot REST Market Data Endpoints: https://developers.binance.com/docs/binance-spot-api-docs/rest-api/market-data-endpoints
- Binance Public Data: https://github.com/binance/binance-public-data
- Binance Data Collection: https://data.binance.vision/
- Binance Spot WebSocket Streams: https://developers.binance.com/docs/binance-spot-api-docs/web-socket-streams
- Binance Spot Testnet: https://developers.binance.com/docs/binance-spot-api-docs/testnet
- Binance Connector Ruby: https://github.com/binance/binance-connector-ruby

## Ruby

- RubyGems sqlite3: https://rubygems.org/gems/sqlite3
- Binance Connector Ruby: https://github.com/binance/binance-connector-ruby

## R

- CRAN quantmod: https://cran.r-project.org/web/packages/quantmod/index.html
- CRAN PerformanceAnalytics: https://cran.r-project.org/web/packages/PerformanceAnalytics/index.html
- CRAN TTR: https://cran.r-project.org/package=TTR

## C++

- LEMON Graph Library: https://lemon.cs.elte.hu/pub/doc/1.3.1/index.html
- nlohmann/json: https://nlohmann.github.io/json/

---

# 14. Pipeline de validación continua (GitHub)

## 14.1 Principio

Este proyecto es público con licencia Apache 2.0. Eso permite usar herramientas gratuitas de revisión automática que de otro modo requerirían pago. El objetivo del pipeline no es bloquear trabajo, sino detectar regresiones, inconsistencias de seguridad y errores antes de que lleguen a `main`.

Los agentes de IA (CodeRabbit, Codex, Gemini, Copilot) participan como revisores, no como aprobadores. La decisión final de merge pertenece al propietario humano.

---

## 14.2 Herramientas disponibles

| Herramienta | Rol en este proyecto | Activación |
|---|---|---|
| **GitHub Actions** | Orquestador central del pipeline | Configuración en `.github/workflows/` |
| **CodeRabbit** | Revisión automática de PRs (código, seguridad, estilo, tests faltantes) | App GitHub, gratis para repos públicos |
| **GitHub Codex** | Sugerencias de código inline en el editor y en PRs | Habilitado por cuenta GitHub |
| **Gemini Code Assist** | Revisión de PRs y sugerencias en GitHub | App GitHub Marketplace |
| **GitHub Copilot** | Autocompletado y revisión inline en IDE | Extensión IDE / GitHub subscription |

---

## 14.3 Qué puede validar el pipeline

### En cada push y PR

- **`bundle exec rspec`** — suite de tests RSpec.
- **`bundle exec rubocop`** — estilo y linting Ruby.
- Verificación de que `config/app.yml` mantiene `dry_run: true` y `trading_enabled: false`.
- Verificación de que ningún archivo staged contiene patrones de API secret.

### En PRs (revisores automáticos)

- **CodeRabbit**: revisa diff completo, identifica bugs, inconsistencias, tests faltantes y riesgos de seguridad. Comenta directamente en el PR.
- **Gemini Code Assist**: revisión adicional del diff con enfoque en correctitud y calidad.
- **Copilot**: sugerencias inline en el editor; en PRs, puede sugerir mejoras de código.

### Limitaciones deliberadas

- Ninguna herramienta de IA puede aprobar ni mergear un PR.
- Ningún workflow debe ejecutar `git commit`, `git push`, `git tag` ni crear releases.
- Los workflows no deben tener acceso a `BINANCE_API_KEY` ni `BINANCE_API_SECRET` en el entorno de CI. Las pruebas deben ser completamente offline.

---

## 14.4 Estructura de workflows propuesta

```text
.github/
  workflows/
    ci.yml           # tests + rubocop en cada push/PR
    safety_check.yml # verifica dry_run y ausencia de secrets en archivos
```

### `ci.yml` — esqueleto mínimo

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version-file: aletheia/.ruby-version
          bundler-cache: true
          working-directory: aletheia
      - name: RSpec
        run: bundle exec rake spec
        working-directory: aletheia
      - name: RuboCop
        run: bundle exec rubocop
        working-directory: aletheia
```

### `safety_check.yml` — esqueleto mínimo

```yaml
name: Safety check

on:
  push:
  pull_request:

jobs:
  safety:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verificar dry_run activo
        run: |
          grep -q "dry_run: true" aletheia/config/app.yml || \
            (echo "ERROR: dry_run no está activo" && exit 1)
      - name: Verificar trading_enabled desactivado
        run: |
          grep -q "trading_enabled: false" aletheia/config/app.yml || \
            (echo "ERROR: trading_enabled no está desactivado" && exit 1)
      - name: Buscar posibles API secrets en código fuente
        run: |
          grep -rn "BINANCE_API_KEY\s*=\s*['\"][^'\"]" aletheia/lib aletheia/bin && \
            echo "WARN: Posible secret hardcodeado" || true
```

---

## 14.5 Configuración de CodeRabbit

CodeRabbit se activa instalando la GitHub App desde [coderabbit.ai](https://coderabbit.ai) en el repositorio. Para repos públicos Apache, el tier gratuito incluye revisión de PRs ilimitada.

Archivo de configuración opcional en la raíz del repo:

```yaml
# .coderabbit.yml
language: en
reviews:
  auto_review:
    enabled: true
    drafts: false
  path_filters:
    - "aletheia/**"
    - "!aletheia/vendor/**"
    - "!aletheia/data/**"
  request_changes_workflow: false
```

Instrucción útil para CodeRabbit (en el PR o en `.coderabbit.yml`):

> Este proyecto es un laboratorio de investigación cripto Spot-only. No debe sugerir futures, margin, leverage, withdrawals ni trading autónomo. Priorizar seguridad, legibilidad y tests.

---

## 14.6 Uso responsable de IA en revisiones

Los revisores automáticos pueden:

- señalar bugs y regresiones;
- detectar código sin tests;
- sugerir mejoras de estilo;
- alertar sobre patrones de seguridad.

Los revisores automáticos **no deben**:

- aprobar un PR sin revisión humana;
- sugerir habilitar trading real;
- sugerir almacenar API keys en código;
- introducir dependencias no auditadas.

Si un agente sugiere algo que contradice las reglas del proyecto (`AGENTS.md`), la sugerencia debe ignorarse y, si es relevante, documentarse en el journal.

---

# 13. Regla final

Este proyecto debe avanzar solo si aumenta la comprensión y reduce el riesgo.

No debe convertirse en una máquina para justificar entradas frecuentes.

La mejor salida del sistema, muchas veces, debe ser:

```text
No operar.
```
