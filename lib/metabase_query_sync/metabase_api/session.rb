class MetabaseQuerySync::MetabaseApi
  # @!method id
  #   @return [String]
  class Session < Model
    attribute :id, MetabaseQuerySync::Types::Strict::String
  end
end
