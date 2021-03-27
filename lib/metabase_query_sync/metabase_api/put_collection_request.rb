class MetabaseQuerySync::MetabaseApi
  class PutCollectionRequest < ApiRequest
    has :id, :name, :description, :archived
    attribute :color, MetabaseQuerySync::Types::Strict::String.default('#509EE3'.freeze)
    attribute :parent_id, MetabaseQuerySync::Types::Strict::Integer.optional.default(nil)

    # TODO: implement collections
    # # @param collection [Collection]
    # def self.from_collection(collection)
    #   new(collection.to_h)
    # end
  end
end