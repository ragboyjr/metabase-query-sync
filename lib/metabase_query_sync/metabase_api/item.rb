require 'dry-struct'

class MetabaseQuerySync::MetabaseApi
  class Item < Model
    attribute :id, MetabaseQuerySync::Types::Strict::Integer
    attribute :name, MetabaseQuerySync::Types::Strict::String
    attribute :description, MetabaseQuerySync::Types::Strict::String.optional.default(nil)
    attribute :model, MetabaseQuerySync::Types::Strict::String

    def card?
      model == Card::KEY
    end
    def collection?
      model == Collection::KEY
    end
    def pulse?
      model == Pulse::KEY
    end
  end
end