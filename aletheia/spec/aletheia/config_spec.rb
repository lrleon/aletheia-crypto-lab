require_relative '../../lib/aletheia'

RSpec.describe Aletheia::Config do
  let(:config_path) { 'config/app.yml' }

  describe '#initialize' do
    it 'carga el archivo de configuración correctamente' do
      config = described_class.new(config_path)
      expect(config.data).to be_a(Hash)
    end
  end

  describe '#fetch' do
    let(:config) { described_class.new(config_path) }

    it 'verifica que existen símbolos BTCUSDT y ETHUSDT' do
      symbols = config.fetch('symbols')
      expect(symbols).to include('BTCUSDT', 'ETHUSDT')
    end

    it 'verifica que existen intervalos 1h, 4h, 1d' do
      intervals = config.fetch('intervals')
      expect(intervals).to include('1h', '4h', '1d')
    end
  end
end
