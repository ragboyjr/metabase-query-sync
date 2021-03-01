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

    context 'creating from a collection of items' do
      it 'throws if invalid item is provided' do
        expect {
          described_class.from_items([1])
        }.to raise_error(RuntimeError, 'Unexpected type provided from items (Integer), expected instances of only Collection, Pulse, or Query')
      end

      it 'creates a graph otherwise' do
        res = described_class.from_items([
          query(name: 'Query 1', pulse: 'pulse-1'),
          pulse(name: 'Pulse 1'),
          pulse(name: 'Pulse 2'),
          query(name: 'Query 2', pulse: 'pulse-2'),
        ])

        expect(res).to eq(IR::Graph.new(collections: [], pulses: [
          pulse(name: 'Pulse 1'),
          pulse(name: 'Pulse 2'),
        ], queries: [
          query(name: 'Query 1', pulse: 'pulse-1'),
          query(name: 'Query 2', pulse: 'pulse-2'),
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
  end
end
