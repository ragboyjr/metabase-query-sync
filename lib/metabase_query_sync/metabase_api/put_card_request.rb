class MetabaseQuerySync::MetabaseApi
  class PutCardRequest < Model
    attribute :id, MetabaseQuerySync::Types::Strict::Integer.optional.default(nil)
    attribute :name, MetabaseQuerySync::Types::Strict::String
    attribute :description, MetabaseQuerySync::Types::Strict::String.optional.default(nil)
    attribute :display, MetabaseQuerySync::Types::Strict::String.default('table'.freeze)
    attribute :visualization_settings, MetabaseQuerySync::Types::Strict::Hash.default({}.freeze)
    attribute :collection_id, MetabaseQuerySync::Types::Strict::Integer.optional
    attribute :archived, MetabaseQuerySync::Types::Strict::Bool.default(false)
    attribute :dataset_query, Card::DataSetQuery

    def self.native(sql:, database_id:, **kwargs)
      new(dataset_query: Card::DataSetQuery.native(sql: sql, database_id: database_id), **kwargs)
    end
  end
end