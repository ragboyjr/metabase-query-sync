require 'fileutils'

RSpec.describe MetabaseQuerySync::ReadIR::FromFiles do
  include IRFactory

  before do
    @file_fixtures = FileFixtures.new
    @file_fixtures.clear_files
  end

  def query_path(scope: nil, path: nil)
    path = path || @file_fixtures.fixtures_path
    scope ? "#{scope}:#{path}" : path
  end

  def when_the_ir_is_read(_query_path = nil)
    @graph = described_class.new(_query_path || query_path).()
  end

  def then_the_imported_graph_matches(graph)
    expect(@graph).to eq(graph)
  end

  def given_an_hourly_pulse(name: 'hourly.pulse.yaml')
    @file_fixtures.given_a_file_with_contents name, <<-'YAML'
---
name: Hourly
alerts:
  - type: slack
    slack: { channel: '#alerts' }
    schedule:
      type: hourly
YAML
  end

  def hourly_pulse(**attributes)
    pulse(name: 'Hourly', alerts: [
      pulse_alert do |a|
        a.slack '#alerts'
        a.hourly
      end
    ], **attributes)
  end

  it 'can read from files' do
    @file_fixtures.given_a_file_with_contents 'low-volume-orders.query.yaml', <<-'YAML'
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
    @file_fixtures.given_a_file_with_contents 'not-used.query.yaml', <<-'YAML'
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
    @file_fixtures.given_a_file_with_contents 'sales/test.query.yaml', <<-'YAML'
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

  it 'can sync from multiple paths' do
    given_an_hourly_pulse(name: 'sales/hourly.pulse.yaml')
    given_an_hourly_pulse(name: 'catalog/hourly.pulse.yaml')
    when_the_ir_is_read([
      query_path(scope: 'sales', path: File.join(@file_fixtures.fixtures_path, 'sales')),
      query_path(scope: 'catalog', path: File.join(@file_fixtures.fixtures_path, 'catalog')),
    ])
    then_the_imported_graph_matches(IR::Graph.new(
      collections: [],
      pulses: [hourly_pulse(id: 'sales/hourly'), hourly_pulse(id: 'catalog/hourly')],
      queries: []
    ))
  end

  it 'supports scoped paths' do
    given_an_hourly_pulse
    when_the_ir_is_read(query_path(scope: 'sales'))
    then_the_imported_graph_matches(IR::Graph.new(
      collections: [],
      pulses: [hourly_pulse(id: 'sales/hourly')],
      queries: [],
    ))
  end
end
