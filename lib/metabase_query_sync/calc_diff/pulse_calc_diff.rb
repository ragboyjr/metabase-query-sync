class MetabaseQuerySync::CalcDiff
  class PulseCalcDiff < self
    # @param req [MetabaseQuerySync::CalcDiffRequest]
    def call(req)
      [].chain(
        delete_pulses(req.graph, req.metabase_state),
        add_pulses(req.graph, req.metabase_state, req.root_collection_id)
      )
    end

    private

    # @param graph [IR::Graph]
    # @param metabase_state [MetabaseState]
    def delete_pulses(graph, metabase_state)
      metabase_state.pulses
        .filter { |pulse| find_graph_pulse(graph, id(pulse)) == nil }
        .map { |pulse| MetabaseQuerySync::MetabaseApi::PutPulseRequest.from_pulse(pulse).new(archived: true) }
    end
  end

  # @param graph [IR::Graph]
  # @param metabase_state [MetabaseState]
  # # @param root_collection_id [Integer]
  def add_pulses(graph, metabase_state, root_collection_id)
    graph.pulses
      .map do |pulse|
      api_pulse = find_api_pulse(metabase_state, id(pulse))
      pulse_cards = graph
        .queries_by_pulse(pulse.id)
        .flat_map do |query|
        card = find_api_card(metabase_state, id(query))
        card ? [card] : []
      end
        .map { |card| MetabaseQuerySync::MetabaseApi::Pulse::Card.new(id: card.id) }
      pulse_channels = pulse.alerts.map do |alert|
        MetabaseQuerySync::MetabaseApi::Pulse::Channel.build do |c|
          case alert.type
          when 'email'
            c.emails alert.email.emails
          when 'slack'
            c.slack alert.slack.channel
          end

          case alert.schedule.type
          when 'hourly'
            c.hourly
          when 'daily'
            c.daily(alert.hour)
          when 'weekly'
            c.weekly(alert.hour, alert.day)
          end
        end
      end
      [pulse, api_pulse, pulse_cards, pulse_channels]
    end
      .filter do |(pulse, api_pulse, pulse_cards, pulse_channels)|
      next true unless api_pulse
      api_pulse.cards != pulse_cards ||
        api_pulse.channels != pulse_channels ||
        api_pulse.name != api_item_name(pulse)
    end
      .map do |(pulse, api_pulse, pulse_cards, pulse_channels)|
      MetabaseQuerySync::MetabaseApi::PutPulseRequest.new(
        id: api_pulse&.id,
        name: "#{pulse.id}:#{pulse.name}",
        cards: pulse_cards,
        channels: pulse_channels,
        collection_id: root_collection_id,
        skip_if_empty: true,
      )
    end
  end
end
