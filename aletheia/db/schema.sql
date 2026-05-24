CREATE TABLE IF NOT EXISTS klines (
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

CREATE TABLE IF NOT EXISTS data_quality_reports (
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

CREATE TABLE IF NOT EXISTS strategy_runs (
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

CREATE TABLE IF NOT EXISTS simulated_trades (
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