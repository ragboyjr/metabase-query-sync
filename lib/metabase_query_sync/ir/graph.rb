require 'dry-struct'
require 'set'

module MetabaseQuerySync::IR
  class Graph < Dry::Struct
    attr_reader :extra

    attribute :collections, MetabaseQuerySync::Types::Strict::Array.of(Collection)
    attribute :pulses, MetabaseQuerySync::Types::Strict::Array.of(Pulse)
    attribute :queries, MetabaseQuerySync::Types::Strict::Array.of(Query)

    def initialize(attributes)
      super(attributes)
      assert_traversal
    end

    def with_extra(extra)
      @extra = extra
      self
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

    # @return [Query, nil]
    def query_by_name(name)
      queries.filter { |query| query.name.downcase == name.downcase }.first
    end

    # @return [Pulse, nil]
    def pulse_by_name(name)
      pulses.filter { |pulse| pulse.name.downcase == name.downcase }.first
    end

    private

    def assert_traversal
      pulse_names = pulses.map(&:name).map(&:downcase).to_set
      queries.each do |q|
        raise "No pulse (#{q.pulse}) found for query (#{q.name})" unless pulse_names === q.pulse.downcase
      end
    end
  end
end