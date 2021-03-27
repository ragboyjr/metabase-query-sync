class MetabaseQuerySync::CalcDiff
  class CardCalcDiff < self
    # @param req [MetabaseQuerySync::CalcDiffRequest]
    def call(req)
      [].chain(
        delete_cards(req.graph, req.metabase_state),
        add_cards(req.graph, req.metabase_state, req.root_collection_id)
      )
    end

    private

    # @param graph [IR::Graph]
    # @param metabase_state [MetabaseState]
    def delete_cards(graph, metabase_state)
      metabase_state.cards
        .filter { |card| find_graph_query(graph, id(card)) == nil }
        .map { |card| MetabaseQuerySync::MetabaseApi::PutCardRequest.from_card(card).new(archived: true) }
    end

    # @param graph [IR::Graph]
    # @param metabase_state [MetabaseState]
    # @param root_collection_id [Integer]
    def add_cards(graph, metabase_state, root_collection_id)
      graph.queries
        .map do |q|
        [q, find_api_card(metabase_state, id(q))]
      end
        .filter do |(q, card)|
        next true unless card
        card.dataset_query.native.query != q.sql ||
          card.name != api_item_name(q) ||
          card.database_id != metabase_state.database_by_name(q.database)&.id ||
          card.description != q.description
      end
        .map do |(q, card)|
        database_id = metabase_state.database_by_name(q.database)&.id
        raise "Database (#{q.database}) not found" if database_id == nil
        MetabaseQuerySync::MetabaseApi::PutCardRequest.native(
          id: card&.id,
          sql: q.sql,
          database_id: metabase_state.database_by_name(q.database)&.id,
          name: api_item_name(q),
          description: q.description,
          collection_id: root_collection_id,
        )
      end
    end
  end
end