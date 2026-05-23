module Aletheia
  class Safety
    class ConfigurationError < StandardError; end

    def self.verify!(config, risk_config = nil)
      new(config, risk_config).verify!
    end

    def initialize(config, risk_config = nil)
      @config = config
      @risk_config = risk_config
    end

    def verify!
      check_boolean_strict!('mode', 'dry_run', true)
      check_boolean_strict!('mode', 'trading_enabled', false)
      check_boolean_strict!('mode', 'paper_trading_enabled', false)
      check_boolean_strict!('mode', 'human_confirmation_required', true)
      
      check_boolean_strict!('allowed_markets', 'futures', false)
      check_boolean_strict!('allowed_markets', 'margin', false)
      check_boolean_strict!('allowed_markets', 'leverage', false)
      
      check_boolean_strict!('execution', 'withdrawals_allowed', false)
      check_boolean_strict!('execution', 'enabled', false)

      verify_risk_config! if @risk_config
      
      true
    end

    private

    def check_boolean_strict!(*keys, expected_value)
      actual_value = @config.fetch(*keys)
      
      unless actual_value == expected_value
        key_path = keys.join('.')
        raise ConfigurationError, "Error de seguridad: '#{key_path}' DEBE ser #{expected_value}, pero es #{actual_value.inspect}"
      end
    end

    def verify_risk_config!
      check_risk_boolean_strict!('kill_switch', 'enabled', true)
      check_risk_boolean_strict!('kill_switch', 'trading_allowed', false)
      check_risk_integer_max!('risk_limits', 'max_open_positions', 1)
    end

    def check_risk_boolean_strict!(*keys, expected_value)
      actual_value = @risk_config.fetch(*keys)

      unless actual_value == expected_value
        key_path = keys.join('.')
        raise ConfigurationError, "Error de seguridad: '#{key_path}' DEBE ser #{expected_value}, pero es #{actual_value.inspect}"
      end
    end

    def check_risk_integer_max!(*keys, max_value)
      actual_value = @risk_config.fetch(*keys)

      unless actual_value.is_a?(Integer) && actual_value <= max_value
        key_path = keys.join('.')
        raise ConfigurationError, "Error de seguridad: '#{key_path}' DEBE ser un entero <= #{max_value}, pero es #{actual_value.inspect}"
      end
    end
  end
end
