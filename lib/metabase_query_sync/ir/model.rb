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

  def self.from_h(h)
    raise 'not implemented'
  end

  protected

  def self.validate_with_schema(&schema_def)
    # @type [Dry::Schema::Result]
    def self.from_h(h)
      result = Dry::Schema.JSON(&schema_def).(h)
    end
    raise "Invalid hash provided: #{result.errors.to_h}" if result.failure?
    new(h)
  end
end