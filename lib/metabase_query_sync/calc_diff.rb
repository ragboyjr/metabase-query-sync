module MetabaseQuerySync
  class CalcDiff
    # @param req [CalcDiffRequest]
    # @return [Array<MetabaseApi::ApiRequest>]
    def call(req)
      raise 'Not implemented.'
    end

    protected

    # @param item [IR::Model]
    # @return [String]
    def api_item_name(item)
      "#{item.id}:#{item.name}"
    end

    # @param graph [IR::Graph]
    # @param query_id [String]
    # @return [IR::Query, nil]
    def find_graph_query(graph, query_id)
      graph.queries.filter { |q| id(q) == query_id }.first
    end

    # @param graph [IR::Graph]
    # @param pulse_id [String]
    # @return [IR::Pulse, nil]
    def find_graph_pulse(graph, pulse_id)
      graph.pulses.filter { |p| id(p) == pulse_id }.first
    end

    # @param metabase_state [MetabaseState]
    # @param card_id [String]
    # @return [MetabaseApi::Card, nil]
    def find_api_card(metabase_state, card_id)
      metabase_state.cards.filter { |c| id(c) == card_id }.first
    end

    # @param metabase_state [MetabaseState]
    # @param pulse_id [String]
    # @return [MetabaseApi::Pulse, nil]
    def find_api_pulse(metabase_state, pulse_id)
      metabase_state.pulses.filter { |p| id(p) == pulse_id }.first
    end

    # gets the normalized id from the given object to be used for comparisons
    # @return [String]
    def id(object)
      case object
      when IR::Model
        object.id
      when MetabaseApi::Model
        object.name[/^([^:]+):/, 1] # metabase api names are constructed with #{IR id}:#{IR name}
      else
        raise "Unexpected object (#{object.class}) provided."
      end
    end
  end
end