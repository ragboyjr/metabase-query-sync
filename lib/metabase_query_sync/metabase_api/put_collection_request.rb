class MetabaseQuerySync::MetabaseApi
  class PutCollectionRequest < Model
    attribute :id, MetabaseQuerySync::Types::Strict::Integer.optional.default(nil)
    attribute :name, MetabaseQuerySync::Types::Strict::String
    attribute :color, MetabaseQuerySync::Types::Strict::String.default('#509EE3'.freeze)
    attribute :description, MetabaseQuerySync::Types::Strict::String.optional.default(nil)
    attribute :parent_id, MetabaseQuerySync::Types::Strict::Integer.optional.default(nil)
    attribute :archived, MetabaseQuerySync::Types::Strict::Bool.default(false)

    # @param collection [Collection]
    def self.from_collection(collection)
      new(collection.to_h)
    end
  end
end