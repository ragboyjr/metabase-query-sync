module IRSteps
  def given_a_graph(collections: [], pulses: [pulse(name: 'Test Pulse')], queries: [])
    @graph = graph(collections: collections, pulses: pulses, queries: queries)
  end

  def read_ir
    Class.new(MetabaseQuerySync::ReadIR) do
      def initialize(graph)
        @graph = graph
      end
      def call()
        @graph
      end
    end.new(@graph)
  end
end