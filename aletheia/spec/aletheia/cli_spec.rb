require 'open3'

RSpec.describe 'CLI bin/aletheia' do
  let(:bin_path) { File.expand_path('../../bin/aletheia', __dir__) }

  it 'muestra ayuda con --help' do
    stdout, _, status = Open3.capture3("bundle exec ruby #{bin_path} --help")
    expect(status.success?).to be true
    expect(stdout).to include('Aletheia')
    expect(stdout).to include('Comandos disponibles:')
  end

  it 'falla si no se proporciona un comando válido' do
    stdout, _, status = Open3.capture3("bundle exec ruby #{bin_path}")
    expect(status.success?).to be false
    expect(stdout).to include('Uso: bin/aletheia')
  end
end
