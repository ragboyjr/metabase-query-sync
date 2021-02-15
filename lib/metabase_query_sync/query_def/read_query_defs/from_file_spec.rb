RSpec.describe MetabaseQuerySync::QueryDef::ReadQueryDefs::FromFile do
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
  def then_the_imported_query_defs_match(matchers_list)
    expect(matchers_list.length).to eq(@imported_query_defs.length), "The number of imported queries (#{@imported_query_defs.length}) should match the number of matchers (#{matchers_list.length})."

    @imported_query_defs.zip(matchers_list).each do |(query_def, matchers)|
      Array(matchers).each { |m| m.call(query_def) }
    end
  end

  module QueryDefMatch
    def self.name(name)
      ->(qd) { expect(qd.name).to eq(name) }
    end
    def self.sql(sql)
      ->(qd) { expect(qd.sql).to eq(sql) }
    end
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
      [
        QueryDefMatch.name('Test Health Check'),
        QueryDefMatch.sql(%q{SELECT IF(COUNT(*) < 500, 'Low Volume Detected', null) FROM orders WHERE created_at > NOW() - INTERVAL 4 HOUR})
      ]
    ]
  end
end