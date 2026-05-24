require 'tmpdir'
require 'tempfile'
require 'zip'
require 'logger'
require_relative '../../../lib/aletheia/binance/public_data_downloader'

RSpec.describe Aletheia::Binance::PublicDataDownloader do
  let(:null_log) { Logger.new(File::NULL) }
  let(:tmp_dir)  { Dir.mktmpdir('aletheia_dl_test') }

  after { FileUtils.remove_entry(tmp_dir) }

  # Construye un ZIP en memoria que contiene un CSV de velas Binance
  def build_zip_with_csv(csv_rows)
    zip_buffer = Zip::OutputStream.write_buffer do |zip|
      zip.put_next_entry('BTCUSDT-1h-2021-01.csv')
      zip.write(csv_rows.map { |r| r.join(',') }.join("\n"))
    end
    zip_buffer.string
  end

  CSV_HEADER = [
    '1609459200000', '29000.0', '29500.0', '28800.0', '29300.0', '100.0',
    '1609462799999', '2900000.0', '5000', '55.0', '1595000.0', '0'
  ].freeze

  CSV_ROW2 = [
    '1609462800000', '29300.0', '29800.0', '29100.0', '29600.0', '120.0',
    '1609466399999', '3520000.0', '6000', '60.0', '1752000.0', '0'
  ].freeze

  let(:zip_bytes) { build_zip_with_csv([CSV_HEADER, CSV_ROW2]) }

  describe '#monthly_klines' do
    context 'cuando el ZIP está disponible' do
      let(:dl_proc) do
        lambda do |_url, dest_path|
          File.binwrite(dest_path, zip_bytes)
          true
        end
      end

      let(:downloader) do
        described_class.new(tmp_dir: tmp_dir, download_proc: dl_proc, logger: null_log)
      end

      it 'devuelve dos velas parseadas' do
        klines = downloader.monthly_klines(symbol: 'BTCUSDT', interval: '1h',
                                           year: 2021, month: 1)
        expect(klines.size).to eq(2)
      end

      it 'rellena los campos correctos en la primera vela' do
        klines = downloader.monthly_klines(symbol: 'BTCUSDT', interval: '1h',
                                           year: 2021, month: 1)
        k = klines.first
        expect(k[:symbol]).to   eq('BTCUSDT')
        expect(k[:interval]).to eq('1h')
        expect(k[:open_time]).to  eq(1_609_459_200_000)
        expect(k[:close_time]).to eq(1_609_462_799_999)
        expect(k[:open]).to  eq(29_000.0)
        expect(k[:high]).to  eq(29_500.0)
        expect(k[:low]).to   eq(28_800.0)
        expect(k[:close]).to eq(29_300.0)
        expect(k[:volume]).to           eq(100.0)
        expect(k[:number_of_trades]).to eq(5000)
        expect(k[:source]).to eq('public_data')
      end

      it 'elimina el archivo ZIP temporal después de procesar' do
        downloader.monthly_klines(symbol: 'BTCUSDT', interval: '1h',
                                  year: 2021, month: 1)
        leftover_zips = Dir.glob(File.join(tmp_dir, '*.zip'))
        expect(leftover_zips).to be_empty
      end
    end

    context 'cuando el ZIP no está disponible (404)' do
      let(:dl_proc) { ->(_url, _dest) { false } }

      let(:downloader) do
        described_class.new(tmp_dir: tmp_dir, download_proc: dl_proc, logger: null_log)
      end

      it 'devuelve nil sin lanzar excepción' do
        result = downloader.monthly_klines(symbol: 'BTCUSDT', interval: '1h',
                                           year: 2021, month: 1)
        expect(result).to be_nil
      end
    end

    context 'cuando el download_proc lanza una excepción' do
      let(:dl_proc) { ->(_url, _dest) { raise 'Timeout' } }

      let(:downloader) do
        described_class.new(tmp_dir: tmp_dir, download_proc: dl_proc, logger: null_log)
      end

      it 'devuelve nil y no propaga la excepción' do
        result = downloader.monthly_klines(symbol: 'BTCUSDT', interval: '1h',
                                           year: 2021, month: 1)
        expect(result).to be_nil
      end
    end

    context 'cuando el CSV tiene encabezado de texto' do
      let(:csv_with_header) do
        rows = [
          ['open_time', 'open', 'high', 'low', 'close', 'volume',
           'close_time', 'quote_asset_volume', 'number_of_trades',
           'taker_buy_base_asset_volume', 'taker_buy_quote_asset_volume', 'ignore'],
          CSV_HEADER
        ]
        build_zip_with_csv(rows)
      end

      let(:dl_proc) do
        lambda do |_url, dest_path|
          File.binwrite(dest_path, csv_with_header)
          true
        end
      end

      let(:downloader) do
        described_class.new(tmp_dir: tmp_dir, download_proc: dl_proc, logger: null_log)
      end

      it 'omite la fila de encabezado y devuelve solo los datos' do
        klines = downloader.monthly_klines(symbol: 'BTCUSDT', interval: '1h',
                                           year: 2021, month: 1)
        expect(klines.size).to eq(1)
        expect(klines.first[:open_time]).to eq(1_609_459_200_000)
      end
    end
  end
end
