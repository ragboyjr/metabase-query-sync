RSpec.describe MetabaseQuerySync::MetabaseCredentials do
  it 'can create credentials' do
    when_the_credentials_are_created {
      MetabaseQuerySync::MetabaseCredentials.new(host: 'host', user: 'user', pass: 'pass')
    }
    then_the_credentials_match'host', 'user', 'pass'
  end

  it 'can create from env' do
    given_the_following_env_is_set({
      'METABASE_QUERY_SYNC_HOST' => 'host',
      'METABASE_QUERY_SYNC_USER' => 'user',
      'METABASE_QUERY_SYNC_PASS' => 'pass',
    })
    when_the_credentials_are_created {
      MetabaseQuerySync::MetabaseCredentials.from_env
    }
    then_the_credentials_match 'host', 'user', 'pass'
  end

  def when_the_credentials_are_created
    # @type [MetabaseQuerySync::MetabaseCredentials]
    @credentials = yield
  end

  def then_the_credentials_match(host, user, pass)
    expect([@credentials.host, @credentials.user, @credentials.pass]).to eq([host, user, pass])
  end
end
