class MetabaseQuerySync::MetabaseCredentials
  attr_reader :host, :user, :pass

  def initialize(host:, user:, pass:)
    @host = host
    @user = user
    @pass = pass
  end

  def self.from_env(host: nil, user: nil, pass: nil, env: ENV)
    self.new(
      host: host || env['METABASE_QUERY_SYNC_HOST'],
      user: user || env['METABASE_QUERY_SYNC_USER'],
      pass: pass || env['METABASE_QUERY_SYNC_PASS'],
    )
  end
end