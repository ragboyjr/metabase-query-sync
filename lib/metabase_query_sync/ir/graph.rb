module MetabaseQuerySync::IR
  class Graph
    # @param collections [Array<Collection>]
    # @param pulses [Array<Pulse>]
    # @param queries [Array<Query>]
    def initialize(collections, pulses, queries)
      @collections = collections
      @pulses = pulses
      @queries = queries
    end

    # @return [Query, nil]
    def query_by_name(name)
      @queries.filter { |query| query.name.downcase == name.downcase }.first
    end

    # @param query [Query]
    # @return [Pulse]
    def query_pulse(query)
      raise 'todo'
    end
  end
end