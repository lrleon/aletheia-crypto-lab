#!/usr/bin/env Rscript
# Genera gráfico interactivo de velas (OHLCV) desde CSV exportado por bin/plot_klines.
# Uso: Rscript R/scripts/plot_klines.R <csv_path> <symbol> <interval> <output_html>

suppressPackageStartupMessages({
  library(plotly)
  library(data.table)
  library(htmlwidgets)
  library(htmltools)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
  cat("Uso: Rscript plot_klines.R <csv_path> <symbol> <interval> <output_html>\n")
  quit(status = 1)
}

csv_path    <- args[1]
symbol      <- args[2]
interval    <- args[3]
output_html <- args[4]

if (!file.exists(csv_path)) {
  cat(sprintf("[ERROR] CSV no encontrado: %s\n", csv_path))
  quit(status = 1)
}

dt <- fread(csv_path, colClasses = list(
  character = c("open_time_ms", "close_time_ms"),
  numeric   = c("open", "high", "low", "close", "volume")
))

if (nrow(dt) == 0) {
  cat("[ERROR] CSV vacío. Sin datos para graficar.\n")
  quit(status = 1)
}

# Convertir timestamps (ms) a POSIXct UTC
dt[, datetime := as.POSIXct(as.numeric(open_time_ms) / 1000, origin = "1970-01-01", tz = "UTC")]
setorder(dt, datetime)

# Detectar gaps: intervalo esperado en segundos
interval_seconds <- switch(interval,
  "1m"  = 60,    "3m"  = 180,   "5m"  = 300,  "15m" = 900,
  "30m" = 1800,  "1h"  = 3600,  "2h"  = 7200, "4h"  = 14400,
  "6h"  = 21600, "8h"  = 28800, "12h" = 43200,
  "1d"  = 86400, "3d"  = 259200,"1w"  = 604800,
  NA_real_
)

gap_shapes <- list()
if (!is.na(interval_seconds) && nrow(dt) > 1) {
  diffs   <- as.numeric(diff(dt$datetime), units = "secs")
  gap_idx <- which(diffs > interval_seconds * 1.5)

  if (length(gap_idx) > 0) {
    for (i in gap_idx) {
      gap_shapes <- c(gap_shapes, list(list(
        type      = "rect",
        xref      = "x",
        yref      = "paper",
        x0        = dt$datetime[i],
        x1        = dt$datetime[i + 1],
        y0        = 0,
        y1        = 1,
        fillcolor = "rgba(255, 50, 50, 0.15)",
        line      = list(width = 0),
        layer     = "below"
      )))
    }
    cat(sprintf("[INFO] %d gap(s) detectado(s) y marcado(s) en rojo.\n", length(gap_idx)))
  }
}

# Candlestick
p_candles <- plot_ly(
  data        = dt,
  x           = ~datetime,
  open        = ~open,
  high        = ~high,
  low         = ~low,
  close       = ~close,
  type        = "candlestick",
  name        = symbol,
  increasing  = list(line = list(color = "#26a69a"), fillcolor = "#26a69a"),
  decreasing  = list(line = list(color = "#ef5350"), fillcolor = "#ef5350")
) %>%
  layout(
    yaxis  = list(title = "Precio (USDT)", fixedrange = FALSE),
    xaxis  = list(
      title        = "",
      rangeslider  = list(visible = FALSE),
      type         = "date"
    ),
    shapes = gap_shapes
  )

# Volumen
p_volume <- plot_ly(
  data   = dt,
  x      = ~datetime,
  y      = ~volume,
  type   = "bar",
  name   = "Volumen",
  marker = list(color = ifelse(dt$close >= dt$open, "rgba(38,166,154,0.6)", "rgba(239,83,80,0.6)"))
) %>%
  layout(
    yaxis = list(title = "Volumen", fixedrange = FALSE),
    xaxis = list(title = "Tiempo (UTC)", type = "date")
  )

fig <- subplot(
  p_candles, p_volume,
  nrows       = 2,
  shareX      = TRUE,
  heights     = c(0.72, 0.28),
  titleY      = TRUE
) %>%
  layout(
    title  = list(
      text = sprintf("<b>%s — %s</b>  (%s → %s UTC)",
                     symbol, interval,
                     format(min(dt$datetime), "%Y-%m-%d"),
                     format(max(dt$datetime), "%Y-%m-%d")),
      font = list(size = 15)
    ),
    legend       = list(orientation = "h", x = 0, y = -0.05),
    hovermode    = "x unified",
    plot_bgcolor  = "#1a1a2e",
    paper_bgcolor = "#16213e",
    font          = list(color = "#e0e0e0")
  ) %>%
  config(
    displayModeBar = TRUE,
    scrollZoom     = TRUE,
    toImageButtonOptions = list(format = "png", filename = sprintf("%s_%s_chart", symbol, interval))
  )

# Advertencia de gaps en el título si existen
n_gaps <- length(gap_shapes)
if (n_gaps > 0) {
  fig <- fig %>% layout(
    annotations = list(list(
      text      = sprintf("&#x26A0; %d gap(s) marcado(s) en rojo", n_gaps),
      xref      = "paper", yref  = "paper",
      x         = 1,       y     = 1.02,
      xanchor   = "right", yanchor = "bottom",
      showarrow = FALSE,
      font      = list(color = "#ff6b6b", size = 11)
    ))
  )
}

dir.create(dirname(output_html), recursive = TRUE, showWarnings = FALSE)

# htmltools::save_html no requiere pandoc y genera HTML autocontenido
save_html(fig, file = output_html)

cat(sprintf("[OK] Gráfico guardado: %s\n", output_html))
cat(sprintf("[INFO] Velas: %d | Rango: %s → %s UTC\n",
            nrow(dt),
            format(min(dt$datetime), "%Y-%m-%d %H:%M"),
            format(max(dt$datetime), "%Y-%m-%d %H:%M")))