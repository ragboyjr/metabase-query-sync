require 'dry-struct'

class MetabaseQuerySync::MetabaseApi::Collection < Dry::Struct::Value
  attribute :id, MetabaseQuerySync::Types::Strict::Integer
  attribute :archived, MetabaseQuerySync::Types::Strict::Bool
  attribute :slug, MetabaseQuerySync::Types::Strict::String
  attribute :name, MetabaseQuerySync::Types::Strict::String
  attribute :location, MetabaseQuerySync::Types::Strict::String
  attribute :description, MetabaseQuerySync::Types::Strict::String
end