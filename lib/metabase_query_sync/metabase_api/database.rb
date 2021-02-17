require 'dry-struct'

class MetabaseQuerySync::MetabaseApi::Database < Dry::Struct::Value
  attribute :id, MetabaseQuerySync::Types::Strict::Integer
  attribute :name, MetabaseQuerySync::Types::Strict::String
end