# Aletheia — AGENTS.md

## 1. Misión

Estás trabajando en **Aletheia**, un laboratorio prudente de investigación de mercados cripto.

Tu función es ayudar a construir un sistema seguro, explicable y auditable para:

- análisis de datos Spot de Binance;
- descarga y validación de datos históricos;
- `backtesting` conservador;
- evaluación de riesgo;
- alertas;
- `paper trading`;
- investigación teórica de arbitraje con grafos;
- integración C++ con Aleph_w cuando sea pertinente.

No trates este proyecto como un bot para ganar dinero.

---

## 2. Reglas no negociables

Preserva siempre estas reglas:

- Spot only.
- No futures.
- No margin.
- No leverage.
- No withdrawals by API.
- No autonomous real-money trading.
- No hidden execution paths.
- `dry_run: true` por defecto.
- `trading_enabled: false` por defecto.
- Human confirmation obligatoria para cualquier orden real.
- Máximo una posición abierta al inicio.
- Tamaños de posición pequeños.
- Risk engine antes de alertas o sugerencias.
- Logs para acciones importantes.
- Kill switch antes de cualquier execution layer real.
- No fomentar sobreoperación.

---

## Regla de Git y atribución

Los agentes AI no tienen permitido ejecutar:

```bash
git commit
git push
```

Tampoco deben ejecutar:

```bash
git tag
git push --tags
gh release create
gh pr merge
```

Pueden proponer `diffs`, modificar archivos locales cuando se les solicite, sugerir `commit messages`, nombres de `branches`, descripciones de `pull requests` y checklists de revisión.

La decisión final, el `commit`, el `push`, los `tags`, los `releases` y la atribución pertenecen exclusivamente al propietario humano del proyecto.


---

## 3. Política de lenguajes

### 3.1 Ruby first

Usa Ruby para:

- CLI;
- Binance API access;
- descarga histórica;
- persistencia SQLite;
- validación;
- indicadores;
- strategy orchestration;
- backtesting;
- risk engine;
- alert engine;
- reportes;
- llamadas a ejecutables C++.

### 3.2 R para investigación

Usa R para:

- exploratory analysis;
- estadísticas;
- visualizaciones;
- reportes de investigación.

No uses R para API secrets ni real execution.

### 3.3 C++ para kernels algorítmicos

Usa C++ solo cuando esté justificado por:

- graph algorithms;
- arbitrage cycle detection;
- intensive simulations;
- heavy batch processing;
- performance bottlenecks.

Cuando escribas C++, prefiere **Aleph_w** siempre que sea práctico.

---

## 4. Política de Aleph_w

Aleph_w es la biblioteca C++ preferente para estructuras de datos y algoritmos en este proyecto.

Úsala especialmente para investigación de arbitraje basada en grafos.

Pero:

- no inventes APIs de Aleph_w;
- no asumas nombres de headers;
- no asumas nombres de clases;
- inspecciona headers y ejemplos locales;
- compila una prueba mínima antes de integrar;
- encapsula Aleph_w detrás de interfaces pequeñas del proyecto.

Patrón aceptable:

```text
cpp/arbitrage/
  include/
    aletheia_arbitrage.hpp
  src/
    scan_cycles.cpp
    main.cpp
```

Ruby debe llamar ejecutables C++ usando:

- JSON input/output;
- CSV input/output;
- SQLite input/output.

Evita `FFI` temprano salvo justificación fuerte.

---

## 5. Seguridad de trading

No debes:

- agregar código que envíe órdenes reales salvo que la tarea trate explícitamente sobre una fase tardía de execution layer;
- habilitar trading real por defecto;
- guardar API keys;
- registrar secretos en logs;
- añadir withdrawals;
- añadir futures, margin o leverage;
- sugerir position sizes fuera de límites configurados;
- eliminar human confirmation;
- eliminar `dry-run` defaults.

Si se pide implementar ejecución antes de tiempo, implementa solo `dry-run`.

---

## 6. Seguridad de datos

Antes de analysis o backtesting:

- validar velas;
- detectar datos faltantes;
- detectar duplicados;
- detectar OHLC inválido;
- detectar velas incompletas;
- registrar fuente;
- registrar timestamp de descarga;
- rechazar o marcar datos sospechosos.

No ejecutes backtests sobre datos no validados.

---

## 7. Reglas de backtesting

El backtesting debe evitar:

- look-ahead bias;
- incomplete candles;
- perfect fills;
- zero-fee assumptions;
- zero-slippage assumptions;
- overfitting;
- parameter mining;
- selección oportunista de periodos.

Siempre incluir:

- fees;
- slippage;
- spread assumptions cuando aplique;
- trade log;
- drawdown;
- losing streak;
- sensitivity analysis.

---

## 8. Reglas de arbitraje

El arbitraje es research-only salvo que una fase futura diga explícitamente lo contrario.

Para arbitraje:

- usar graph models;
- usar fee-adjusted rates;
- usar bid/ask-aware direction;
- usar depth-aware sizing en iteraciones futuras;
- marcar oportunidades como teóricas;
- estimar execution risk;
- no generar órdenes automáticas.

Un ciclo negativo no basta. La factibilidad real requiere fees, spread, depth, slippage, latency, lot size, tick size, minimum notional y partial-fill risk.

---

## 9. Estilo de código

Preferir:

- cambios pequeños;
- interfaces simples;
- configuración explícita;
- tests determinísticos;
- logs claros;
- reportes legibles;
- defaults conservadores.

Evitar:

- abstracciones oscuras;
- hidden global state;
- fallos silenciosos;
- shortcuts hacia auto-trading;
- cambios no revisados de estrategia;
- indicadores sin explicación.

---

## 10. Definition of Done

Un cambio está terminado solo si:

- preserva safety defaults;
- no expone secretos;
- tiene tests donde sea práctico;
- está documentado;
- registra acciones importantes;
- no habilita live trading accidentalmente;
- es explicable a una persona revisora;
- no ejecutó `git commit`;
- no ejecutó `git push`.

---

## 11. Instrucción final

Ante la duda, preferir:

```text
observe → validate → simulate → report → review
```

en vez de:

```text
signal → trade
```
