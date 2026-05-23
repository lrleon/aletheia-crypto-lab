require_relative '../../lib/aletheia'

RSpec.describe Aletheia::Safety do
  let(:base_config) do
    {
      'mode' => {
        'dry_run' => true,
        'trading_enabled' => false,
        'paper_trading_enabled' => false,
        'human_confirmation_required' => true
      },
      'allowed_markets' => {
        'futures' => false,
        'margin' => false,
        'leverage' => false
      },
      'execution' => {
        'withdrawals_allowed' => false,
        'enabled' => false
      }
    }
  end

  let(:config_mock) { instance_double(Aletheia::Config) }
  let(:risk_config) do
    {
      'risk_limits' => {
        'max_open_positions' => 1
      },
      'kill_switch' => {
        'enabled' => true,
        'trading_allowed' => false,
        'alerts_allowed' => true
      }
    }
  end

  let(:risk_mock) { instance_double(Aletheia::Config) }

  before do
    allow(config_mock).to receive(:fetch) do |*keys|
      keys.reduce(base_config) { |acc, key| acc[key.to_s] }
    end

    allow(risk_mock).to receive(:fetch) do |*keys|
      keys.reduce(risk_config) { |acc, key| acc[key.to_s] }
    end
  end

  describe '.verify!' do
    it 'pasa cuando la configuración es segura (configuración de ejemplo)' do
      expect { described_class.verify!(config_mock) }.not_to raise_error
    end

    it 'falla si trading_enabled se pone en true' do
      base_config['mode']['trading_enabled'] = true
      expect { described_class.verify!(config_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'mode\.trading_enabled' DEBE ser false/)
    end

    it 'falla si dry_run se pone en false' do
      base_config['mode']['dry_run'] = false
      expect { described_class.verify!(config_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'mode\.dry_run' DEBE ser true/)
    end

    it 'falla si futures se pone en true' do
      base_config['allowed_markets']['futures'] = true
      expect { described_class.verify!(config_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'allowed_markets\.futures' DEBE ser false/)
    end

    it 'falla si margin se pone en true' do
      base_config['allowed_markets']['margin'] = true
      expect { described_class.verify!(config_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'allowed_markets\.margin' DEBE ser false/)
    end

    it 'falla si leverage se pone en true' do
      base_config['allowed_markets']['leverage'] = true
      expect { described_class.verify!(config_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'allowed_markets\.leverage' DEBE ser false/)
    end

    it 'falla si withdrawals_allowed se pone en true' do
      base_config['execution']['withdrawals_allowed'] = true
      expect { described_class.verify!(config_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'execution\.withdrawals_allowed' DEBE ser false/)
    end

    it 'falla si execution.enabled se pone en true' do
      base_config['execution']['enabled'] = true
      expect { described_class.verify!(config_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'execution\.enabled' DEBE ser false/)
    end

    it 'verifica el kill switch cuando se entrega configuracion de riesgo' do
      expect { described_class.verify!(config_mock, risk_mock) }.not_to raise_error
    end

    it 'falla si kill_switch.trading_allowed se pone en true' do
      risk_config['kill_switch']['trading_allowed'] = true
      expect { described_class.verify!(config_mock, risk_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'kill_switch\.trading_allowed' DEBE ser false/)
    end

    it 'falla si max_open_positions supera 1' do
      risk_config['risk_limits']['max_open_positions'] = 2
      expect { described_class.verify!(config_mock, risk_mock) }.to raise_error(Aletheia::Safety::ConfigurationError, /'risk_limits\.max_open_positions' DEBE ser un entero <= 1/)
    end
  end
end
