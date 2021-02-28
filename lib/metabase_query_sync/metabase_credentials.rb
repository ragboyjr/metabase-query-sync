class MetabaseQuerySync::MetabaseCredentials
  attr_reader :host, :user, :pass

  def initialize(host:, user:, pass:)
    raise "Metabase credentials for host, user, pass must not be empty)" if host == nil || user == nil || pass == nil
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