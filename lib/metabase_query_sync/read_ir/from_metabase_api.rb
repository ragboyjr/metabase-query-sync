class MetabaseQuerySync::ReadIR

  # @!attribute metabase_api
  #   @return [MetabaseQuerySync::MetabaseApi]
  # @!attribute root_collection_id
  #   @return [Integer]
  class FromMetabaseApi < self
    # @param metabase_api [MetabaseQuerySync::MetabaseApi]
    def initialize(metabase_api, root_collection_id)
      @metabase_api = metabase_api
      @root_collection_id = root_collection_id
    end

    def call
      items = @metabase_api.get_collection_items(@root_collection_id)

      ir_items, metabase_ir_map = items
        .filter { |i| i.card? || i.pulse? }
        .reduce([[], {}]) do |(ir_items, metabase_ir_map), item|
          if item.card?
            card = @metabase_api.get_card(item.id)
            # item = MetabaseQuerySync::IR::Query()
          end
        end
      MetabaseQuerySync::IR::Graph.from_items(

      )


      raise ''
    end

    class MetabaseState
      attr_reader :database_ids_by_name, :database_names_by_id, :card_ids_to_pulse_names

      def initialize(database_ids_by_name, database_names_by_id, card_ids_to_pulse_names)
        @database_ids_by_name = database_ids_by_name
        @database_names_by_id = database_names_by_id
        @card_ids_to_pulse_names = card_ids_to_pulse_names
      end

      def self.from_models(databases, pulses)

      end

      def database_ids_by_name
        raise 'return database ids by name hash'
      end

      def database_names_by_id
        raise 'return database names by id'
      end
    end
  end
end