require 'yaml'

module Aletheia
  class Config
    attr_reader :data

    def initialize(file_path)
      raise "Archivo de configuración no encontrado: #{file_path}" unless File.exist?(file_path)

      @data = YAML.load_file(file_path)
    end

    def fetch(*keys)
      keys.reduce(@data) { |acc, key| acc.is_a?(Hash) ? acc[key.to_s] : nil }
    end
  end
end
