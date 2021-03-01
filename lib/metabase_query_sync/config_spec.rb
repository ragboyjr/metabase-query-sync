RSpec.describe MetabaseQuerySync::Config do
  before :each do
    @file_fixtures = FileFixtures.new
    @file_fixtures.clear_files
  end

  def then_the_config_matches(paths:, host:, user:, pass:)
    expect(@config.paths).to eql(['a', 'b'])
    expect(@config.credentials.host).to eql('h')
    expect(@config.credentials.user).to eql('u')
    expect(@config.credentials.pass).to eql('p')
  end

  def when_the_config_is_created_from_file(filename, **attrs)
    @config = described_class.from_file(@file_fixtures.fixtures_path(filename), **attrs)
  end

  it 'can be created explicitly' do
    @config = described_class.new(
      credentials: MetabaseQuerySync::MetabaseCredentials.new(host: 'h', user: 'u', pass: 'p'),
      paths: ['a', 'b']
    )
    then_the_config_matches(paths: ['a', 'b'], host: 'h', user: 'u', pass: 'p')
  end

  it 'can be created from a file' do
    @file_fixtures.given_a_file_with_contents 'metabase-query-sync.erb.yaml', <<-'YAML'
credentials:
  host: h
  user: u
  pass: p
paths:
 - a
 - b
YAML
    when_the_config_is_created_from_file 'metabase-query-sync.erb.yaml'
    then_the_config_matches(paths: ['a', 'b'], host: 'h', user: 'u', pass: 'p')
  end


  it 'allows overrides from file creation' do
    @file_fixtures.given_a_file_with_contents 'metabase-query-sync.erb.yaml', <<-'YAML'
credentials:
  host: a
  user: b
  pass: c
paths:
 - a
 - b
YAML
    when_the_config_is_created_from_file 'metabase-query-sync.erb.yaml', host: 'h', user: 'u', pass: 'p'
    then_the_config_matches(paths: ['a', 'b'], host: 'h', user: 'u', pass: 'p')
  end

  it 'can be created from file with erb templating' do
    given_the_following_env_is_set({
      "METABASE_HOST" => 'h'
    })
    @file_fixtures.given_a_file_with_contents 'metabase-query-sync.erb.yaml', <<-'YAML'
credentials:
  host: <%= ENV["METABASE_HOST"] %>
  user: u
  pass: p
paths:
 - a
 - b
YAML
    when_the_config_is_created_from_file 'metabase-query-sync.erb.yaml'
    then_the_config_matches(paths: ['a', 'b'], host: 'h', user: 'u', pass: 'p')
  end

  it 'can load from file even if no file exists' do
    when_the_config_is_created_from_file 'metabase-query-sync.erb.yaml', paths: ['a', 'b'], host: 'h', user: 'u', pass: 'p'
    then_the_config_matches(paths: ['a', 'b'], host: 'h', user: 'u', pass: 'p')
  end
end
