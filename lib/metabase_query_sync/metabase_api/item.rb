require 'dry-struct'

class MetabaseQuerySync::MetabaseApi
  class Item < Model
    attribute :id, MetabaseQuerySync::Types::Strict::Integer
    attribute :name, MetabaseQuerySync::Types::Strict::String
    attribute :description, MetabaseQuerySync::Types::Strict::String.optional
    attribute :model, MetabaseQuerySync::Types::Strict::String

    def card?
      model == 'card'
    end
    def collection?
      model == 'collection'
    end
    def pulse?
      model == 'pulse'
    end
  end
end