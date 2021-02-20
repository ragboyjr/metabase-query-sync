RSpec.describe MetabaseQuerySync::ReadIR::FromFiles do
  include IRFactory

  before do
    Dir[__dir__ + '/__spec__/*.yaml'].each { |f| File.delete(f) }
  end

  # @param contents [String]
  def given_a_file_with_contents(name, contents)
    file_path = __dir__ + '/__spec__/' + name
    File.open(__dir__ + '/__spec__/' + name, 'w') do |f|
      f.write(contents)
    end
  end

  def when_the_ir_is_read
    @graph = described_class.new(__dir__ + '/__spec__').()
  end

  def then_the_imported_graph_matches(graph)
    expect(@graph).to eq(graph)
  end

  it 'can read from files' do
    given_a_file_with_contents 'all-orders.query.yaml', <<-'YAML'
--- 
name: Low Volume Orders
database: Local
pulse: Hourly
sql: |
  SELECT IF(COUNT(*) < 500, 'Low Volume Detected', null) FROM orders WHERE created_at > NOW() - INTERVAL 4 HOUR
YAML

    given_a_file_with_contents 'hourly.pulse.yaml', <<-'YAML'
---
name: Hourly
alerts:
  - type: slack
    slack: { channel: '#alerts' }
    schedule:
      type: hourly
YAML

    when_the_ir_is_read
    then_the_imported_graph_matches IR::Graph.new(
      collections: [],
      pulses: [
        pulse(name: 'Hourly', alerts: [
          pulse_alert do |a|
            a.slack '#alerts'
            a.hourly
          end
        ]),
      ],
      queries: [
        query(name: 'Low Volume Orders', database: 'Local', pulse: 'Hourly', sql: "SELECT IF(COUNT(*) < 500, 'Low Volume Detected', null) FROM orders WHERE created_at > NOW() - INTERVAL 4 HOUR\n")
      ]
    )
  end

end
