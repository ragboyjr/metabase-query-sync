require 'dry-struct'

# Holds all of the data/state that has been previously synced to metabase
module MetabaseQuerySync
  # @!method collections
  #   @return [Array<MetabaseApi::Collection>]
  # @!method cards
  #   @return [Array<MetabaseApi::Card>]
  # @!method pulses
  #   @return [Array<MetabaseApi::Pulse>]
  # @!method databases
  #   @return [Array<MetabaseApi::Database>]
  class MetabaseState < Dry::Struct
    attribute :collections, Types::Strict::Array.of(MetabaseApi::Collection)
    attribute :cards, Types::Strict::Array.of(MetabaseApi::Card)
    attribute :pulses, Types::Strict::Array.of(MetabaseApi::Pulse)
    attribute :databases, Types::Strict::Array.of(MetabaseApi::Database)

    # @param metabase_api [MetabaseApi]
    # @param root_collection_id [Integer]
    # @return [MetabaseState]
    def self.from_metabase_api(metabase_api, root_collection_id)
      items = metabase_api.get_collection_items(root_collection_id)
      if items.failure?
        raise "No root collection (id: #{root_collection_id}) found"
      end

      acc = items.value!
        .filter { |i| i.card? || i.pulse? }
        .map do |item|
          if item.card?
            metabase_api.get_card(item.id).value!
          elsif item.pulse?
            metabase_api.get_pulse(item.id).value!
          else
            raise 'Unexpected item type.'
          end
        end
        .reduce({cards: [], pulses: []}) do |acc, item|
          case item
          when MetabaseApi::Card
            acc[:cards] << item
          when MetabaseApi::Pulse
            acc[:pulses] << item
          else
            raise 'Unexpected item type.'
          end
          acc
        end

      new(collections: [], cards: acc[:cards], pulses: acc[:pulses], databases: metabase_api.get_databases.value!)
    end

    # @return self
    def with_card(card)
      new(cards: cards.concat([card]))
    end

    # @return self
    def with_pulse(pulse)
      new(pulses: pulses.concat([pulse]))
    end

    def empty?
      collections.empty? && cards.empty? && pulses.empty?
    end

    # @return [MetabaseApi::Pulse, nil]
    def pulse_by_name(name)
      pulses.filter { |p| p.name.downcase == name.downcase }.first
    end

    # @return [MetabaseApi::Card, nil]
    def card_by_name(name)
      cards.filter { |c| c.name.downcase == name.downcase }.first
    end

    def database_by_name(name)
      databases.filter { |d| d.name.downcase == name.downcase }.first
    end
  end
end