require 'sqlite3'
require 'logger'

module Aletheia
  module Storage
    class KlineRepository
      SCHEMA_SQL = <<~SQL.freeze
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
      SQL

      INSERT_SQL = <<~SQL.freeze
        INSERT OR IGNORE INTO klines
          (symbol, interval, open_time, close_time, open, high, low, close,
           volume, quote_asset_volume, number_of_trades,
           taker_buy_base_volume, taker_buy_quote_volume,
           source, downloaded_at, is_complete, data_quality_status,
           created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      SQL

      def initialize(db_path:, logger: Logger.new($stdout))
        @db = SQLite3::Database.new(db_path)
        @logger = logger
        ensure_schema
      end

      def insert_batch(klines)
        return { inserted: 0, skipped: 0 } if klines.nil? || klines.empty?

        inserted = 0
        skipped  = 0
        now_ms   = (Time.now.to_f * 1000).to_i

        @db.transaction do
          stmt = @db.prepare(INSERT_SQL)
          klines.each do |k|
            stmt.execute(row_values(k, now_ms))
            if @db.changes > 0
              inserted += 1
            else
              skipped += 1
            end
          end
          stmt.close
        end

        { inserted: inserted, skipped: skipped }
      end

      def count(symbol:, interval:, from_time: nil, to_time: nil)
        sql    = 'SELECT COUNT(*) FROM klines WHERE symbol = ? AND interval = ?'
        params = [symbol, interval]

        if from_time
          sql    += ' AND open_time >= ?'
          params << from_time
        end

        if to_time
          sql    += ' AND open_time <= ?'
          params << to_time
        end

        @db.get_first_value(sql, params).to_i
      end

      def latest_open_time(symbol:, interval:)
        @db.get_first_value(
          'SELECT MAX(open_time) FROM klines WHERE symbol = ? AND interval = ?',
          [symbol, interval]
        )
      end

      def earliest_open_time(symbol:, interval:)
        @db.get_first_value(
          'SELECT MIN(open_time) FROM klines WHERE symbol = ? AND interval = ?',
          [symbol, interval]
        )
      end

      def find_range(symbol:, interval:, from_time:, to_time:)
        @db.execute(
          <<~SQL,
            SELECT open_time, open, high, low, close, volume, close_time,
                   quote_asset_volume, number_of_trades,
                   taker_buy_base_volume, taker_buy_quote_volume, source
            FROM klines
            WHERE symbol = ? AND interval = ?
              AND open_time >= ? AND open_time <= ?
            ORDER BY open_time ASC
          SQL
          [symbol, interval, from_time, to_time]
        )
      end

      def close
        @db.close
      end

      private

      def ensure_schema
        @db.execute_batch(SCHEMA_SQL)
      end

      def row_values(k, now_ms)
        [
          k[:symbol],
          k[:interval],
          k[:open_time].to_i,
          k[:close_time].to_i,
          k[:open].to_f,
          k[:high].to_f,
          k[:low].to_f,
          k[:close].to_f,
          k[:volume].to_f,
          k[:quote_asset_volume]&.to_f,
          k[:number_of_trades]&.to_i,
          k[:taker_buy_base_volume]&.to_f,
          k[:taker_buy_quote_volume]&.to_f,
          k[:source] || 'unknown',
          k[:downloaded_at] || now_ms,
          k.key?(:is_complete) ? k[:is_complete] : 1,
          k[:data_quality_status] || 'unknown',
          now_ms,
          now_ms
        ]
      end
    end
  end
end
