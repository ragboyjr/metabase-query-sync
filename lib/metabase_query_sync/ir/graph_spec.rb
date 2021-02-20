RSpec.describe IR::Graph do
  include IRFactory

  context 'finding graph items' do
    def given_a_graph(collections: [], pulses: [pulse(name: 'Test Pulse')], queries: [])
      @graph = graph(collections: collections, pulses: pulses, queries: queries)
    end

    def when_the_graph
      @result = yield @graph
    end

    def then_the_result_matches(result)
      expect(@result).to eql(result)
    end

    context 'finding queries by name' do
      before do
        given_a_graph(queries: [query(name: 'All Orders')])
      end

      it 'returns query on soft name match' do
        when_the_graph { |graph| graph.query_by_name('all orders') }
        then_the_result_matches(query(name: 'All Orders'))
      end

      it 'returns nil if no match' do
        when_the_graph { |graph| graph.query_by_name('unknown name') }
        then_the_result_matches(nil)
      end
    end

    context "finding pulses by name" do
      before do
        given_a_graph(pulses: [pulse(name: 'Hourly')])
      end

      it 'returns query on soft name match' do
        when_the_graph { |graph| graph.pulse_by_name('hourly') }
        then_the_result_matches(pulse(name: 'Hourly'))
      end

      it 'returns nil if no match' do
        when_the_graph { |graph| graph.pulse_by_name('unknown name') }
        then_the_result_matches(nil)
      end
    end

    context 'creating from a collection of items' do
      it 'throws if invalid item is provided' do
        expect {
          described_class.from_items([1])
        }.to raise_error(RuntimeError, 'Unexpected type provided from items (Integer), expected instances of only Collection, Pulse, or Query')
      end

      it 'creates a graph otherwise' do
        res = described_class.from_items([
          query(name: 'Query 1', pulse: 'Pulse 1'),
          pulse(name: 'Pulse 1'),
          pulse(name: 'Pulse 2'),
          query(name: 'Query 2', pulse: 'Pulse 2'),
        ])

        expect(res).to eq(IR::Graph.new(collections: [], pulses: [
          pulse(name: 'Pulse 1'),
          pulse(name: 'Pulse 2'),
        ], queries: [
          query(name: 'Query 1', pulse: 'Pulse 1'),
          query(name: 'Query 2', pulse: 'Pulse 2'),
        ]))
      end
    end

    it 'enforces valid graph traversal' do
      expect {
        described_class.new(collections: [], pulses: [], queries: [
          query(name: 'Test Query', pulse: 'Test Pulse'),
        ])
      }.to raise_error(RuntimeError, 'No pulse (Test Pulse) found for query (Test Query)')
    end

    it "storing extra info doesn't affect equality comparison" do
      graph_without_extra = graph(queries: [query(name: 'test')])
      graph_with_extra = graph(queries: [query(name: 'test')]).with_extra([1,2,3])
      expect(graph_without_extra).to eq(graph_with_extra)
    end
  end
end
