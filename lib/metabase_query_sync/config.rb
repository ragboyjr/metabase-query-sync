module MetabaseQuerySync
  class Config
    attr_reader :credentials, :paths

    # @param credentials [MetabaseQuerySync::MetabaseCredentials]
    # @param paths [Array<String>]
    def initialize(credentials:, paths:)
      @credentials = credentials
      @paths = paths
    end
  end
end