RSpec.describe IR::Graph do
  context 'manages queries' do
    def given_a_graph(collections: [], pulses: [], queries: [])
      @graph = described_class.new(collections, pulses, queries)
    end

    def query(name:, description: nil, slug: nil, database:'Local', pulse: 'Pulse', collection: nil, sql: 'select * from orders')
      IR::Query.new(name: name, description: description, slug: slug || name.downcase, database: database, pulse: pulse, collection: collection, sql: sql)
    end

    def when_the_graph
      @result = yield @graph
    end

    def then_the_result_matches(result)
      expect(@result).to eql(result)
    end

    context 'finding queries by name' do
      before() do
        given_a_graph(queries: [query(name: 'All Orders'), query(name: 'Late Orders')])
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
  end
end
