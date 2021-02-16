RSpec.describe QueryDef::ReadQueryDefs::FromFile do
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

  def when_query_defs_are_imported
    @imported_query_defs = MetabaseQuerySync::QueryDef::ReadQueryDefs::FromFile.new(__dir__ + '/__spec__').()
  end

  # @param matchers_list [Array]
  def then_the_imported_query_defs_match(query_defs)
    expect(@imported_query_defs).to eq(query_defs)
  end

  it 'can create query defs without alerts' do
    given_a_file_with_contents 'file.yaml', <<-'YAML'
---
name: 'Test Health Check'
sql: |
  SELECT IF(COUNT(*) < 500, 'Low Volume Detected', null) FROM orders WHERE created_at > NOW() - INTERVAL 4 HOUR
YAML
    when_query_defs_are_imported
    then_the_imported_query_defs_match [
      QueryDef.new(name: "Test Health Check", sql: "SELECT IF(COUNT(*) < 500, 'Low Volume Detected', null) FROM orders WHERE created_at > NOW() - INTERVAL 4 HOUR\n")
    ]
  end
end