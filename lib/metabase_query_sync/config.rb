class MetabaseQuerySync::Config
  attr_reader :credentials, :path

  # @param [MetabaseQuerySync::MetabaseCredentials] credentials
  # @param [String] path
  def initialize(credentials, path)
    @credentials = credentials
    @path = path
  end
end