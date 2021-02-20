require 'dry-struct'
require 'dry-schema'

class MetabaseQuerySync::IR::Model < Dry::Struct
  transform_keys &:to_sym

  def self.string
    MetabaseQuerySync::Types::Strict::String
  end

  def self.integer
    MetabaseQuerySync::Types::Strict::Integer
  end

  def self.bool
    MetabaseQuerySync::Types::Strict::Bool
  end

  def self.array
    MetabaseQuerySync::Types::Strict::Array
  end

  def self.validate_with_schema(&schema_def)
    define_singleton_method :from_h do |h|
      result = Dry::Schema.JSON(&schema_def).(h)
      raise "Invalid hash provided: #{result.errors.to_h}" if result.failure?
      new(h)
    end
  end
end