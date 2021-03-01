require 'dry-schema'

module MetabaseQuerySync::IR
  class Query < Model
    attribute :id, string
    attribute :name, string
    attribute :description, string.optional.default(nil)
    attribute :sql, string
    attribute :database, string
    attribute :pulse, string
    attribute :collection, string.optional.default(nil)

    validate_with_schema do
      required(:id).filled(:string)
      required(:name).filled(:string)
      required(:sql).filled(:string)
      required(:database).filled(:string)
      required(:pulse).filled(:string)
      required(:pulse).filled(:string)
      optional(:description).filled(:string)
      optional(:collection).filled(:string)
    end
  end
end