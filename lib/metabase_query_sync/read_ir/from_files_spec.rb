require 'fileutils'

RSpec.describe MetabaseQuerySync::ReadIR::FromFiles do
  include IRFactory

  before do
    Dir[__dir__ + '/__spec__/*']
      .filter { |f| File.basename(f) != '.gitignore' }
      .each { |f| FileUtils.rm_rf(f) }
  end

  # @param contents [String]
  def given_a_file_with_contents(name, contents)
    file_path = __dir__ + '/__spec__/' + name
    dir = File.dirname(file_path)
    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end
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

  def given_an_hourly_pulse()
    given_a_file_with_contents 'hourly.pulse.yaml', <<-'YAML'
---
name: Hourly
alerts:
  - type: slack
    slack: { channel: '#alerts' }
    schedule:
      type: hourly
YAML
  end

  def hourly_pulse
    pulse(name: 'Hourly', alerts: [
      pulse_alert do |a|
        a.slack '#alerts'
        a.hourly
      end
    ])
  end

  it 'can read from files' do
    given_a_file_with_contents 'low-volume-orders.query.yaml', <<-'YAML'
--- 
name: Low Volume Orders In Last 4 Hours
database: Local
pulse: hourly
sql: |
  SELECT IF(COUNT(*) < 500, 'Low Volume Detected', null) FROM orders WHERE created_at > NOW() - INTERVAL 4 HOUR
YAML
    given_an_hourly_pulse

    when_the_ir_is_read
    then_the_imported_graph_matches IR::Graph.new(
      collections: [],
      pulses: [hourly_pulse],
      queries: [
        query(id: 'low-volume-orders', name: 'Low Volume Orders In Last 4 Hours', database: 'Local', pulse: 'hourly', sql: "SELECT IF(COUNT(*) < 500, 'Low Volume Detected', null) FROM orders WHERE created_at > NOW() - INTERVAL 4 HOUR\n")
      ]
    )
  end

  it 'allows ids to be set explicitly' do
    given_a_file_with_contents 'not-used.query.yaml', <<-'YAML'
--- 
id: test-id
name: Test
database: Local
pulse: hourly
sql: select 1
YAML
    given_an_hourly_pulse
    when_the_ir_is_read

    then_the_imported_graph_matches(IR::Graph.new(
      collections: [],
      pulses: [hourly_pulse],
      queries: [
        query(id: 'test-id', name: 'Test', database: 'Local', pulse: 'hourly', sql: "select 1")
      ]
    ))
  end

  it 'allows subfolders' do
    given_a_file_with_contents 'sales/test.query.yaml', <<-'YAML'
--- 
name: Test
database: Local
pulse: hourly
sql: select 1
YAML
    given_an_hourly_pulse
    when_the_ir_is_read
    then_the_imported_graph_matches(IR::Graph.new(
      collections: [],
      pulses: [hourly_pulse],
      queries: [
        query(id: 'sales/test', name: 'Test', database: 'Local', pulse: 'hourly', sql: "select 1")
      ]
    ))
  end
end
