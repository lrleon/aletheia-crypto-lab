require 'logger'
require_relative '../../../lib/aletheia/binance/rest_client'

RSpec.describe Aletheia::Binance::RestClient do
  let(:null_log) { Logger.new('/dev/null') }

  # Un registro de vela en formato Binance REST (12 campos)
  def raw_kline(open_time:, close_time:, open: '29000.0', high: '29500.0',
                low: '28800.0', close: '29300.0', volume: '100.0',
                quote_vol: '2900000.0', trades: '5000',
                tbbase: '55.0', tbquote: '1595000.0')
    [open_time, open, high, low, close, volume, close_time,
     quote_vol, trades, tbbase, tbquote, '0']
  end

  let(:base_open_time)  { 1_609_459_200_000 }
  let(:base_close_time) { 1_609_462_799_999 }
  let(:raw_page1) { [raw_kline(open_time: base_open_time, close_time: base_close_time)] }

  def make_adapter(pages)
    call_count = 0
    lambda do |_url, _params|
      page = pages[call_count] || []
      call_count += 1
      page
    end
  end

  describe '#klines' do
    it 'devuelve una lista de hashes con campos correctos' do
      client = described_class.new(http_adapter: make_adapter([raw_page1]),
                                   logger: null_log)
      result = client.klines(symbol: 'BTCUSDT', interval: '1h')

      expect(result.size).to eq(1)
      k = result.first
      expect(k[:symbol]).to   eq('BTCUSDT')
      expect(k[:interval]).to eq('1h')
      expect(k[:open_time]).to  eq(base_open_time)
      expect(k[:close_time]).to eq(base_close_time)
      expect(k[:open]).to  eq(29_000.0)
      expect(k[:high]).to  eq(29_500.0)
      expect(k[:low]).to   eq(28_800.0)
      expect(k[:close]).to eq(29_300.0)
      expect(k[:volume]).to           eq(100.0)
      expect(k[:number_of_trades]).to eq(5000)
      expect(k[:source]).to eq('rest')
    end

    it 'devuelve arreglo vacío si la respuesta está vacía' do
      client = described_class.new(http_adapter: make_adapter([[]]), logger: null_log)
      expect(client.klines(symbol: 'BTCUSDT', interval: '1h')).to eq([])
    end
  end

  describe '#klines_range' do
    it 'retorna resultados de una sola página cuando hay menos de MAX_LIMIT' do
      client = described_class.new(http_adapter: make_adapter([raw_page1, []]),
                                   logger: null_log)
      result = client.klines_range(
        symbol: 'BTCUSDT', interval: '1h',
        start_time: base_open_time, end_time: base_close_time
      )
      expect(result.size).to eq(1)
    end

    it 'retorna arreglo vacío si start_time > end_time' do
      client = described_class.new(http_adapter: make_adapter([]), logger: null_log)
      result = client.klines_range(
        symbol: 'BTCUSDT', interval: '1h',
        start_time: 1_000_000, end_time: 999_999
      )
      expect(result).to eq([])
    end

    it 'concatena múltiples páginas (paginación)' do
      step    = 3_600_000
      page1   = Array.new(Aletheia::Binance::RestClient::MAX_LIMIT) do |i|
        t = base_open_time + (i * step)
        raw_kline(open_time: t, close_time: t + step - 1)
      end
      page2   = [raw_kline(open_time: base_open_time + (1000 * step),
                           close_time: base_open_time + (1001 * step) - 1)]

      # Simula sleep para no ralentizar el test
      allow_any_instance_of(described_class).to receive(:sleep)

      client  = described_class.new(http_adapter: make_adapter([page1, page2, []]),
                                    logger: null_log)
      result  = client.klines_range(
        symbol: 'BTCUSDT', interval: '1h',
        start_time: base_open_time,
        end_time:   base_open_time + (1001 * step)
      )
      expect(result.size).to eq(1001)
    end
  end

  describe 'INTERVAL_MS' do
    it 'cubre todos los intervalos habituales' do
      %w[1m 3m 5m 15m 30m 1h 2h 4h 6h 8h 12h 1d 3d 1w 1M].each do |iv|
        expect(described_class::INTERVAL_MS).to have_key(iv)
      end
    end
  end

  describe 'con http_adapter que lanza error' do
    it 'propaga la excepción' do
      bad_adapter = ->(_url, _params) { raise 'HTTP 429' }
      client = described_class.new(http_adapter: bad_adapter, logger: null_log)
      expect { client.klines(symbol: 'BTCUSDT', interval: '1h') }.to raise_error('HTTP 429')
    end
  end
end
