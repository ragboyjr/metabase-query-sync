class MetabaseQuerySync::MetabaseApi
  class Card < Model
    KEY = "card"

    class DataSetQuery < Model
      attribute :type, MetabaseQuerySync::Types::Strict::String
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
    attribute :query_type, MetabaseQuerySync::Types::Strict::String
    attribute :display, MetabaseQuerySync::Types::Strict::String
    attribute :visualization_settings, MetabaseQuerySync::Types::Strict::Hash
    attribute :dataset_query, DataSetQuery
  end
end