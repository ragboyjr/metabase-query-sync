RSpec.describe IR::Query do
  include IRFactory
  it 'ensures either pulse or alert is set' do
    expect do
      query(name: 'Test', pulse: nil, alert: nil)
    end.to raise_error(RuntimeError, "Query (Test) must contain a pulse or alert.")
  end
end
