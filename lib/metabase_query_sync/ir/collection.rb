module MetabaseQuerySync::IR
  class Collection < Model
    attribute :name, string
    attribute :description, string.optional
    attribute :collection, string.optional

    validate_with_schema do
      required(:name).filled(:string)
      optional(:description).filled(:string)
      optional(:collection).filled(:string)
    end
  end
end