require 'logger'

module MetabaseQuerySync
  # @!attribute metabase_api
  #   @return [MetabaseApi]
  class Sync
    def initialize(read_ir, metabase_api, logger = nil)
      @read_ir = read_ir
      @metabase_api = metabase_api
      @logger = logger || Logger.new(IO::NULL)
    end

    # @param config [Config]
    def self.from_config(config, logger = nil)
      new(ReadIR::FromFiles.new(config.path), MetabaseApi::FaradayMetabaseApi.from_metabase_credentials(config.credentials), logger)
    end

    # @param sync_req [SyncRequest]
    def call(sync_req)
      @logger.info "Starting sync with req: #{sync_req.to_h}"
      graph = @read_ir.()
      metabase_state = MetabaseState.from_metabase_api(@metabase_api, sync_req.root_collection_id)

      metabase_state = sync_requests(calc_cards_diff(graph, metabase_state, sync_req.root_collection_id), sync_req.dry_run, metabase_state)
      metabase_state = sync_requests(calc_pulses_diff(graph, metabase_state, sync_req.root_collection_id), sync_req.dry_run, metabase_state)

      @logger.info "Finished sync"
    end

    private

    def calc_cards_diff(graph, metabase_state, root_collection_id)
      [].chain(
        delete_cards(graph, metabase_state),
        add_cards(graph, metabase_state, root_collection_id)
      )
    end

    # pulses need to be synced after the cards since pulses need to make use of card ids
    def calc_pulses_diff(graph, metabase_state, root_collection_id)
      [].chain(
        delete_pulses(graph, metabase_state),
        add_pulses(graph, metabase_state, root_collection_id)
      )
    end

    # @param graph [IR::Graph]
    # @param metabase_state [MetabaseState]
    def delete_pulses(graph, metabase_state)
      metabase_state.pulses
        .filter { |pulse| graph.pulse_by_name(pulse.name) == nil }
        .map { |pulse| MetabaseApi::PutPulseRequest.from_pulse(pulse).new(archived: true) }
    end

    # @param graph [IR::Graph]
    # @param metabase_state [MetabaseState]
    def delete_cards(graph, metabase_state)
      metabase_state.cards
        .filter { |card| graph.query_by_name(card.name) == nil }
        .map { |card| MetabaseApi::PutCardRequest.from_card(card).new(archived: true) }
    end

    # @param graph [IR::Graph]
    # @param metabase_state [MetabaseState]
    # @param root_collection_id [Integer]
    def add_cards(graph, metabase_state, root_collection_id)
      graph.queries
        .map do |q|
          [q, metabase_state.card_by_name(q.name)]
        end
        .filter do |(q, card)|
          next true unless card
          card.dataset_query.native.query != q.sql ||
            card.database_id != metabase_state.database_by_name(q.database)&.id ||
            card.description != q.description
        end
        .map do |(q, card)|
          database_id = metabase_state.database_by_name(q.database)&.id
          raise "Database (#{q.database}) not found" if database_id == nil
          MetabaseApi::PutCardRequest.native(
            id: card&.id,
            sql: q.sql,
            database_id: metabase_state.database_by_name(q.database)&.id,
            name: q.name,
            description: q.description,
            collection_id: root_collection_id,
          )
        end
    end

    # @param graph [IR::Graph]
    # @param metabase_state [MetabaseState]
    # # @param root_collection_id [Integer]
    def add_pulses(graph, metabase_state, root_collection_id)
      graph.pulses
        .map do |pulse|
          api_pulse = metabase_state.pulse_by_name(pulse.name)
          pulse_cards = graph
            .queries_by_pulse(pulse.name)
            .flat_map do |query|
              card = metabase_state.card_by_name(query.name)
              card ? [card] : []
            end
            .map { |card| MetabaseApi::Pulse::Card.new(id: card.id) }
          pulse_channels = pulse.alerts.map do |alert|
            MetabaseApi::Pulse::Channel.build do |c|
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
          api_pulse.cards != pulse_cards || api_pulse.channels != pulse_channels
        end
        .map do |(pulse, api_pulse, pulse_cards, pulse_channels)|
          MetabaseApi::PutPulseRequest.new(
            id: api_pulse&.id,
            name: pulse.name,
            cards: pulse_cards,
            channels: pulse_channels,
            collection_id: root_collection_id,
            skip_if_empty: true,
          )
        end
    end

    # sync requests up to metabase
    # @param requests [Enumerator]
    # @param metabase_state [MetabaseState]
    def sync_requests(requests, dry_run, metabase_state)
      requests.reduce(metabase_state) do |metabase_state, req|
        case req
        when MetabaseApi::PutPulseRequest
          @logger.info "PutPulseRequest #{req.to_h}"
          next metabase_state if dry_run
          @metabase_api.put_pulse(req).fmap do |pulse|
            metabase_state.with_pulse(pulse)
          end.value!
        when MetabaseApi::PutCardRequest
          @logger.info "PutCardRequest #{req.to_h}"
          next metabase_state if dry_run
          @metabase_api.put_card(req).fmap do |card|
            metabase_state.with_card(card)
          end.value!
        else
          @logger.error "Unhandled Request Type: #{req.class}"
          metabase_state
        end
      end
    end
  end
end