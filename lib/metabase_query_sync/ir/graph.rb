require 'dry-struct'
require 'set'

module MetabaseQuerySync::IR
  # @!method collections
  #   @return [Array<Collection>]
  # @!method queries
  #   @return [Array<Card>]
  # @!method pulses
  #   @return [Array<Pulse>]
  class Graph < Dry::Struct
    attribute :collections, MetabaseQuerySync::Types::Strict::Array.of(Collection)
    attribute :pulses, MetabaseQuerySync::Types::Strict::Array.of(Pulse)
    attribute :queries, MetabaseQuerySync::Types::Strict::Array.of(Query)

    def initialize(attributes)
      super(attributes)
      assert_traversal
    end

    # create a struct from a heterogeneous collection of collection, pulse, or queries
    # @return [Graph]
    def self.from_items(items)
      new(items.reduce({collections: [], pulses: [], queries: []}) do |acc, item|
        case item
        when Collection
          acc[:collections] << item
        when Pulse
          acc[:pulses] << item
        when Query
          acc[:queries] << item
        else
          raise "Unexpected type provided from items (#{item.class}), expected instances of only Collection, Pulse, or Query"
        end
        acc
      end)
    end

    # @return [Array<Query>]
    def queries_by_pulse(pulse_id)
      queries.filter { |query| query.pulse == pulse_id }
    end

    private

    def assert_traversal
      pulse_ids = pulses.map(&:id).to_set
      queries.each do |q|
        raise "No pulse (#{q.pulse}) found for query (#{q.name})" unless pulse_ids === q.pulse
      end
    end

    # @param a [String]
    # @param b [String]
    def strcmp(a, b)
      a.downcase == b.downcase
    end
  end
end