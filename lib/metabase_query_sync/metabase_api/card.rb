class MetabaseQuerySync::MetabaseApi
  class Card < Model
    KEY = "card"

    class DatasetQuery < Model
      attribute :type, MetabaseQuerySync::Types::Strict::String.default('native'.freeze)
      attribute :native do
        attribute :query, MetabaseQuerySync::Types::Strict::String
      end
      attribute :database, MetabaseQuerySync::Types::Strict::Integer

      def self.native(sql:, database_id:)
        new(type: 'native', native: {query: sql}, database: database_id)
      end
    end

    has :id, :archived, :name, :description, :collection_id
    attribute :database_id, MetabaseQuerySync::Types::Strict::Integer
    attribute :query_type, MetabaseQuerySync::Types::Strict::String.default('native'.freeze)
    attribute :display, MetabaseQuerySync::Types::Strict::String.default('table'.freeze)
    attribute :visualization_settings, MetabaseQuerySync::Types::Strict::Hash.default({}.freeze)
    attribute :dataset_query, DatasetQuery

    def self.native(database_id:,sql:,**kwargs)
      new(database_id: database_id, dataset_query: DatasetQuery.native(sql: sql, database_id: database_id), **kwargs)
    end

    # @param put_card_request [PutCardRequest]
    def self.from_request(put_card_request)
      new(put_card_request.to_h.merge(database_id: put_card_request.dataset_query.database))
    end
  end
end