require 'dry-struct'

class MetabaseQuerySync::MetabaseApi
  class Database < Model
    attribute :id, MetabaseQuerySync::Types::Strict::Integer
    attribute :name, MetabaseQuerySync::Types::Strict::String
  end
end