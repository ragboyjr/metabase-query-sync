require 'dry-monads'

class MetabaseQuerySync::MetabaseApi
  class StubMetabaseApi < self
    include Dry::Monads[:result]

    def initialize(collections: [], pulses: [], cards: [], databases: [])
      @collections = collections
      @pulses = pulses
      @cards = cards
      @databases = databases
    end

    def get_collection(id)
      find_by_id(@collections, id)
    end

    def get_card(id)
      find_by_id(@cards, id)
    end

    def get_databases
      @databases
    end

    def get_pulse(id)
      find_by_id(@pulses, id)
    end

    def get_collection_items(collection_id)
      Success(@collections.chain(@pulses, @cards).filter do |item|
        case item
        when Collection
          item.parent_id == collection_id
        when Pulse
          item.collection_id == collection_id
        when Card
          item.collection_id == collection_id
        else
          false
        end
      end.map do |item|
        Item.new(id: item.id, name: item.name, description: item.respond_to?(:description) ? item.description : nil, model: case item
        when Collection
          Collection::KEY
        when Pulse
          Pulse::KEY
        when Card
          Card::KEY
        end)
      end)
    end

    private

    def find_by_id(items, id)
      item = items.find { |i| i.id == id }
      item ? Success(item) : Failure(nil)
    end

    def match_id(id)
      ->(item) { item.id == id }
    end
  end
end