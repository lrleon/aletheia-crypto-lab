require 'net/http'
require 'uri'
require 'zip'
require 'csv'
require 'date'
require 'fileutils'
require 'logger'

module Aletheia
  module Binance
    class PublicDataDownloader
      BASE_URL = 'https://data.binance.vision'

      # download_proc: optional callable(url, dest_path) -> true/false
      # Useful for testing without real HTTP calls.
      def initialize(tmp_dir:, download_proc: nil, logger: Logger.new($stdout))
        @tmp_dir       = tmp_dir
        @download_proc = download_proc
        @logger        = logger
        FileUtils.mkdir_p(tmp_dir)
      end

      # Returns array of kline hashes or nil if unavailable.
      def monthly_klines(symbol:, interval:, year:, month:)
        path     = monthly_zip_path(symbol, interval, year, month)
        url      = "#{BASE_URL}/#{path}"
        zip_file = File.join(@tmp_dir, File.basename(path))

        @logger.info("Descargando #{url}")

        success = download_file(url, zip_file)
        unless success
          @logger.warn("No disponible: #{url}")
          return nil
        end

        klines = extract_and_parse(zip_file, symbol: symbol, interval: interval)
        klines
      rescue => e
        @logger.error("Error en monthly_klines #{symbol}/#{interval} #{year}-#{'%02d' % month}: #{e.message}")
        nil
      ensure
        File.delete(zip_file) if zip_file && File.exist?(zip_file)
      end

      private

      def monthly_zip_path(symbol, interval, year, month)
        filename = "#{symbol}-#{interval}-#{year}-#{'%02d' % month}.zip"
        "data/spot/monthly/klines/#{symbol}/#{interval}/#{filename}"
      end

      def download_file(url, dest_path)
        if @download_proc
          @download_proc.call(url, dest_path)
        else
          default_download(url, dest_path)
        end
      end

      def default_download(url, dest_path)
        uri      = URI(url)
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          File.binwrite(dest_path, response.body)
          true
        else
          false
        end
      end

      def extract_and_parse(zip_path, symbol:, interval:)
        now_ms = (Time.now.to_f * 1000).to_i
        klines = []

        Zip::File.open(zip_path) do |zip|
          zip.each do |entry|
            next unless entry.name.end_with?('.csv')

            csv_content = entry.get_input_stream.read.force_encoding('UTF-8')
            CSV.parse(csv_content) do |row|
              next if row[0].nil? || row[0] =~ /\D/

              kline = parse_csv_row(row, symbol: symbol, interval: interval,
                                        now_ms: now_ms)
              klines << kline if kline
            end
          end
        end

        klines
      end

      def parse_csv_row(row, symbol:, interval:, now_ms:)
        return nil if row.size < 11

        {
          symbol:                 symbol,
          interval:               interval,
          open_time:              row[0].to_i,
          open:                   row[1].to_f,
          high:                   row[2].to_f,
          low:                    row[3].to_f,
          close:                  row[4].to_f,
          volume:                 row[5].to_f,
          close_time:             row[6].to_i,
          quote_asset_volume:     row[7].to_f,
          number_of_trades:       row[8].to_i,
          taker_buy_base_volume:  row[9].to_f,
          taker_buy_quote_volume: row[10].to_f,
          source:                 'public_data',
          downloaded_at:          now_ms
        }
      end
    end
  end
end
