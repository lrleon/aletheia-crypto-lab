require 'tmpdir'
require 'tempfile'
require 'logger'
require_relative '../../../lib/aletheia/storage/kline_repository'

RSpec.describe Aletheia::Storage::KlineRepository do
  let(:tmp_db)   { Tempfile.new(['klines_test', '.db']) }
  let(:null_log) { Logger.new('/dev/null') }
  let(:repo)     { described_class.new(db_path: tmp_db.path, logger: null_log) }

  after { repo.close; tmp_db.unlink }

  let(:base_kline) do
    {
      symbol:                 'BTCUSDT',
      interval:               '1h',
      open_time:              1_609_459_200_000,
      close_time:             1_609_462_799_999,
      open:                   29_000.0,
      high:                   29_500.0,
      low:                    28_800.0,
      close:                  29_300.0,
      volume:                 100.0,
      quote_asset_volume:     2_900_000.0,
      number_of_trades:       5000,
      taker_buy_base_volume:  55.0,
      taker_buy_quote_volume: 1_595_000.0,
      source:                 'test',
      downloaded_at:          1_700_000_000_000
    }
  end

  describe '#insert_batch' do
    it 'inserta una vela nueva' do
      result = repo.insert_batch([base_kline])
      expect(result[:inserted]).to eq(1)
      expect(result[:skipped]).to  eq(0)
    end

    it 'omite vela duplicada (idempotente)' do
      repo.insert_batch([base_kline])
      result = repo.insert_batch([base_kline])
      expect(result[:inserted]).to eq(0)
      expect(result[:skipped]).to  eq(1)
    end

    it 'inserta múltiples velas en un lote' do
      kline2 = base_kline.merge(open_time: base_kline[:open_time] + 3_600_000,
                                close_time: base_kline[:close_time] + 3_600_000)
      result = repo.insert_batch([base_kline, kline2])
      expect(result[:inserted]).to eq(2)
      expect(result[:skipped]).to  eq(0)
    end

    it 'maneja un lote vacío sin error' do
      result = repo.insert_batch([])
      expect(result[:inserted]).to eq(0)
      expect(result[:skipped]).to  eq(0)
    end

    it 'maneja nil sin error' do
      result = repo.insert_batch(nil)
      expect(result[:inserted]).to eq(0)
      expect(result[:skipped]).to  eq(0)
    end

    it 'usa el campo source de la vela' do
      k = base_kline.merge(source: 'public_data')
      repo.insert_batch([k])
      expect(repo.count(symbol: 'BTCUSDT', interval: '1h')).to eq(1)
    end
  end

  describe '#count' do
    before { repo.insert_batch([base_kline]) }

    it 'cuenta velas por símbolo e intervalo' do
      expect(repo.count(symbol: 'BTCUSDT', interval: '1h')).to eq(1)
    end

    it 'devuelve 0 para un símbolo inexistente' do
      expect(repo.count(symbol: 'ETHUSDT', interval: '1h')).to eq(0)
    end

    it 'filtra por from_time' do
      expect(repo.count(symbol: 'BTCUSDT', interval: '1h',
                        from_time: base_kline[:open_time])).to eq(1)
      expect(repo.count(symbol: 'BTCUSDT', interval: '1h',
                        from_time: base_kline[:open_time] + 1)).to eq(0)
    end

    it 'filtra por to_time' do
      expect(repo.count(symbol: 'BTCUSDT', interval: '1h',
                        to_time: base_kline[:open_time])).to eq(1)
      expect(repo.count(symbol: 'BTCUSDT', interval: '1h',
                        to_time: base_kline[:open_time] - 1)).to eq(0)
    end
  end

  describe '#latest_open_time' do
    it 'devuelve nil cuando no hay datos' do
      expect(repo.latest_open_time(symbol: 'BTCUSDT', interval: '1h')).to be_nil
    end

    it 'devuelve el open_time más reciente' do
      kline2 = base_kline.merge(open_time: base_kline[:open_time] + 3_600_000,
                                close_time: base_kline[:close_time] + 3_600_000)
      repo.insert_batch([base_kline, kline2])
      expect(repo.latest_open_time(symbol: 'BTCUSDT', interval: '1h')).to eq(kline2[:open_time])
    end
  end

  describe '#earliest_open_time' do
    it 'devuelve nil cuando no hay datos' do
      expect(repo.earliest_open_time(symbol: 'BTCUSDT', interval: '1h')).to be_nil
    end

    it 'devuelve el open_time más antiguo' do
      kline2 = base_kline.merge(open_time: base_kline[:open_time] + 3_600_000,
                                close_time: base_kline[:close_time] + 3_600_000)
      repo.insert_batch([base_kline, kline2])
      expect(repo.earliest_open_time(symbol: 'BTCUSDT', interval: '1h')).to eq(base_kline[:open_time])
    end
  end

  describe 'unicidad (symbol, interval, open_time)' do
    it 'no falla al insertar el mismo open_time dos veces' do
      expect { repo.insert_batch([base_kline, base_kline]) }.not_to raise_error
    end

    it 'diferencia símbolo igual con intervalo distinto' do
      kline_4h = base_kline.merge(interval: '4h')
      repo.insert_batch([base_kline, kline_4h])
      expect(repo.count(symbol: 'BTCUSDT', interval: '1h')).to eq(1)
      expect(repo.count(symbol: 'BTCUSDT', interval: '4h')).to eq(1)
    end
  end
end
