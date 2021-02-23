module MetabaseQuerySync
  class Config
    attr_reader :credentials, :path

    # @param credentials [MetabaseQuerySync::MetabaseCredentials]
    # @param path [String]
    def initialize(credentials:, path:)
      @credentials = credentials
      @path = path
    end
  end
end