class MetabaseQuerySync::MetabaseApi
  class PutCardRequest < Model
    has :id, :archived, :name, :description, :collection_id
    attribute :display, MetabaseQuerySync::Types::Strict::String.default('table'.freeze)
    attribute :visualization_settings, MetabaseQuerySync::Types::Strict::Hash.default({}.freeze)
    attribute :dataset_query, Card::DatasetQuery

    def self.native(sql:, database_id:, **kwargs)
      new(dataset_query: Card::DatasetQuery.native(sql: sql, database_id: database_id), **kwargs)
    end

    def self.from_card(card)
      new(card.to_h)
    end
  end
end