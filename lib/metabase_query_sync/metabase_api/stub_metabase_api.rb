require 'dry-monads'

class MetabaseQuerySync::MetabaseApi
  class StubMetabaseApi < self
    include Dry::Monads[:result]

    attr_reader :requests

    def initialize(collections: [], pulses: [], cards: [], databases: [])
      @collections = collections
      @pulses = pulses
      @cards = cards
      @databases = databases
      @requests = []
    end

    def get_collection(id)
      find_by_id(@collections, id)
    end

    def get_card(id)
      find_by_id(@cards, id)
    end

    def get_databases
      Success(@databases)
    end

    def get_pulse(id)
      find_by_id(@pulses, id)
    end

    def put_pulse(pulse_request)
      put_req(Pulse, pulse_request, @pulses) { |pulses| @pulses = pulses }
    end

    def put_collection(collection_request)
      @requests << collection_request
      Success(collection_request)
    end

    def put_card(card_request)
      put_req(Card, card_request, @cards) { |cards| @cards = cards }
    end

    def get_collection_items(collection_id)
      get_collection(collection_id).bind do
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
    end

    private

    def find_by_id(items, id)
      item = items.find { |i| i.id == id }
      item ? Success(item) : Failure(nil)
    end

    def match_id(id)
      ->(item) { item.id == id }
    end

    def put_req(klass, req, collection)
      @requests << req
      item = klass.from_request(req)
      if item.id
        collection = collection.map { |i| i.id == item.id ? item : i }
      else
        item = item.new(id: collection.map { |i| i.id }.compact.max.to_i + 1)
        collection << item
      end
      yield collection
      Success(item)
    end
  end
end