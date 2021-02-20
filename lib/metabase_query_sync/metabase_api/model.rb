require 'dry-struct'
class MetabaseQuerySync::MetabaseApi::Model < Dry::Struct
  transform_keys &:to_sym

  def self.has(*args)
    args.each do |sym|
      case sym
      when :id
        attribute :id, MetabaseQuerySync::Types::Strict::Integer.optional.default(nil)
      when :archived
        attribute :archived, MetabaseQuerySync::Types::Strict::Bool.default(false)
      when :name
        attribute :name, MetabaseQuerySync::Types::Strict::String
      when :description
        attribute :description, MetabaseQuerySync::Types::Strict::String.optional.default(nil)
      when :collection_id
        attribute :collection_id, MetabaseQuerySync::Types::Strict::Integer
      else
        raise "Unexpected field for model (#{sym})"
      end
    end
  end
end