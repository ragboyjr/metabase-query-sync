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

    # @return [MetabaseQuerySync::IR::Query]
    def to_ir(database_ids_to_name, card_ids_to_pulse_names)
      raise "No database found by database id: (#{database_id})" unless database_ids_to_name[database_id]
      raise "No pulse found for card id: (#{id})" unless card_ids_to_pulse_names[id]
      MetabaseQuerySync::IR::Query(
        name: name,
        description: description,
        sql: dataset_query.native.query,
        database: database_ids_to_name[database_id],
        pulse: card_ids_to_pulse_names[id]
      )
    end

    # @param query [MetabaseQuerySync::IR::Query]
    # @return [Card]
    def from_ir(id, database_names_to_ids, query)
      database_id = database_names_to_ids[query.database.downcase]
      raise "No database found by database name: (#{query.database})" unless database_id
      new(
        id: id,
        name: query.name,
        description: query.description,
        database_id: database_id,
        query_type: 'native',
        display: 'table',
        visualization_settings: {},
        dataset_query: DatasetQuery.native(sql: query.sql, database_id: database_id)
      )
    end
  end
end