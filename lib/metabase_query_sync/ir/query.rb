require 'dry-schema'

module MetabaseQuerySync::IR
  class Query < Model
    attribute :name, string
    attribute :description, string.optional
    attribute :slug, string
    attribute :sql, string
    attribute :database, string
    attribute :pulse, string
    attribute :collection, string.optional

    validate_with_schema do
      required(:name).filled(:string)
      required(:slug).filled(:string)
      required(:sql).filled(:string)
      required(:database).filled(:string)
      required(:pulse).filled(:string)
      required(:pulse).filled(:string)
      optional(:description).filled(:string)
      optional(:collection).filled(:string)
    end
  end
end