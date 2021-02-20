class MetabaseQuerySync::Config
  attr_reader :credentials, :path, :root_collection_id

  # @param credentials [MetabaseQuerySync::MetabaseCredentials]
  # @param path [String]
  # @param root_collection_id [Integer]
  def initialize(credentials, path, root_collection_id)
    @credentials = credentials
    @path = path
    @root_collection_id = root_collection_id
  end
end