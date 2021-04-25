require 'dry-schema'

module MetabaseQuerySync::IR
  class Query < Model
    attribute :id, string
    attribute :name, string
    attribute :description, string.optional.default(nil)
    attribute :sql, string
    attribute :database, string
    attribute :pulse, string.optional.default(nil)
    attribute :alert, string.optional.default(nil)
    attribute :collection, string.optional.default(nil)

    def initialize(attributes)
      super(attributes)
      assert_pulse_or_alert
    end

    def assert_pulse_or_alert
      raise "Query (#{name}) must contain a pulse or alert." if pulse == nil and alert == nil
    end

    validate_with_schema do
      required(:id).filled(:string)
      required(:name).filled(:string)
      required(:sql).filled(:string)
      required(:database).filled(:string)
      optional(:pulse).filled(:string)
      optional(:alert).filled(:string)
      optional(:description).filled(:string)
      optional(:collection).filled(:string)
    end
  end
end