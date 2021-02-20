require 'dry-struct'

class MetabaseQuerySync::MetabaseApi
  class Collection < Model
    KEY = 'collection'

    has :id, :archived, :name, :description
    attribute :slug, MetabaseQuerySync::Types::Strict::String
    attribute :location, MetabaseQuerySync::Types::Strict::String
    attribute :parent_id, MetabaseQuerySync::Types::Strict::Integer.optional
  end
end