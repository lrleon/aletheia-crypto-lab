require 'net/http'
require 'uri'
require 'json'
require 'logger'

module Aletheia
  module Binance
    class RestClient
      BASE_URL  = 'https://api.binance.com'
      MAX_LIMIT = 1000

      INTERVAL_MS = {
        '1m'  =>        60_000,
        '3m'  =>       180_000,
        '5m'  =>       300_000,
        '15m' =>       900_000,
        '30m' =>     1_800_000,
        '1h'  =>     3_600_000,
        '2h'  =>     7_200_000,
        '4h'  =>    14_400_000,
        '6h'  =>    21_600_000,
        '8h'  =>    28_800_000,
        '12h' =>    43_200_000,
        '1d'  =>    86_400_000,
        '3d'  =>   259_200_000,
        '1w'  =>   604_800_000,
        '1M'  => 2_592_000_000
      }.freeze

      # http_adapter: optional callable(url_string, params_hash) -> parsed_json_array
      # Useful for testing without real HTTP calls.
      def initialize(base_url: BASE_URL, http_adapter: nil, logger: Logger.new($stdout))
        @base_url = base_url
        @http_adapter = http_adapter
        @logger       = logger
      end

      # Fetches up to MAX_LIMIT klines for a single page.
      def klines(symbol:, interval:, start_time: nil, end_time: nil, limit: MAX_LIMIT)
        params = {
          symbol:   symbol,
          interval: interval,
          limit:    [[limit, MAX_LIMIT].min, 1].max
        }
        params[:startTime] = start_time if start_time
        params[:endTime]   = end_time   if end_time

        raw = http_get('/api/v3/klines', params)
        parse_klines(raw, symbol: symbol, interval: interval)
      end

      # Fetches all klines in [start_time, end_time] with automatic pagination.
      def klines_range(symbol:, interval:, start_time:, end_time:)
        return [] if start_time > end_time

        all           = []
        current_start = start_time
        step_ms       = interval_ms(interval)

        loop do
          batch = klines(symbol: symbol, interval: interval,
                         start_time: current_start, end_time: end_time)
          break if batch.empty?

          all.concat(batch)
          last_open = batch.last[:open_time]

          break if last_open >= end_time
          break if batch.size < MAX_LIMIT

          current_start = last_open + step_ms
          sleep(0.15) # polite rate-limiting
        end

        all
      end

      private

      def http_get(path, params)
        if @http_adapter
          @http_adapter.call("#{@base_url}#{path}", params)
        else
          default_http_get("#{@base_url}#{path}", params)
        end
      end

      def default_http_get(url, params)
        uri       = URI(url)
        uri.query = URI.encode_www_form(params) unless params.empty?

        response = Net::HTTP.get_response(uri)

        unless response.is_a?(Net::HTTPSuccess)
          raise "HTTP #{response.code}: #{response.body[0, 200]}"
        end

        JSON.parse(response.body)
      end

      def parse_klines(raw, symbol:, interval:)
        now_ms = (Time.now.to_f * 1000).to_i

        raw.map do |k|
          {
            symbol:                  symbol,
            interval:                interval,
            open_time:               k[0].to_i,
            open:                    k[1].to_f,
            high:                    k[2].to_f,
            low:                     k[3].to_f,
            close:                   k[4].to_f,
            volume:                  k[5].to_f,
            close_time:              k[6].to_i,
            quote_asset_volume:      k[7].to_f,
            number_of_trades:        k[8].to_i,
            taker_buy_base_volume:   k[9].to_f,
            taker_buy_quote_volume:  k[10].to_f,
            source:                  'rest',
            downloaded_at:           now_ms
          }
        end
      end

      def interval_ms(interval)
        INTERVAL_MS.fetch(interval) do
          raise ArgumentError, "Intervalo desconocido: #{interval}"
        end
      end
    end
  end
end
