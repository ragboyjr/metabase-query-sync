require 'dry-struct'

# Holds all of the data/state that has been previously synced to metabase
module MetabaseQuerySync
  # @!method collections
  #   @return [Array<MetabaseApi::Collection>]
  # @!method cards
  #   @return [Array<MetabaseApi::Card>]
  # @!method pulses
  #   @return [Array<MetabaseApi::Pulse>]
  class MetabaseState < Dry::Struct
    attribute :collections, Types::Strict::Array.of(MetabaseApi::Collection)
    attribute :cards, Types::Strict::Array.of(MetabaseApi::Card)
    attribute :pulses, Types::Strict::Array.of(MetabaseApi::Pulse)
    attribute :databases, Types::Strict::Array.of(MetabaseApi::Database)

    # @param metabase_api [MetabaseApi]
    # @param root_collection_id [Integer]
    def self.from_metabase_api(metabase_api, root_collection_id)
      new(collections: [], cards: [], pulses: [], databases: [])
    end

    def empty?
      collections.empty? && cards.empty? && pulses.empty?
    end
  end
end