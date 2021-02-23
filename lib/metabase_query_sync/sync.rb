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
      graph = @read_ir.()
      metabase_state = MetabaseState.from_metabase_api(@metabase_api, sync_req.root_collection_id)
      sync_requests(calc_diff(graph, metabase_state, sync_req.root_collection_id), sync_req.dry_run)
    end

    private

    # return a set of requests to send to metabase
    def calc_diff(graph, metabase_state, root_collection_id)
      [].chain(
        delete_pulses(graph, metabase_state),
        delete_cards(graph, metabase_state),
        add_cards(graph, metabase_state, root_collection_id)
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
        .filter { |q| metabase_state.card_by_name(q.name) == nil }
        .map do |q|
          database_id = metabase_state.database_by_name(q.database)&.id
          raise "Database (#{q.database}) not found" if database_id == nil
          MetabaseApi::PutCardRequest.native(
            sql: q.sql,
            database_id: metabase_state.database_by_name(q.database)&.id,
            name: q.name,
            description: q.description,
            collection_id: root_collection_id,
          )
        end
    end

    # sync requests up to metabase
    def sync_requests(requests, dry_run)
      requests.each do |req|
        case req
        when MetabaseApi::PutPulseRequest
          @logger.info "PutPulseRequest #{req.to_h}"
          dry_run || @metabase_api.put_pulse(req).value!
        when MetabaseApi::PutCardRequest
          @logger.info "PutCardRequest #{req.to_h}"
          dry_run || @metabase_api.put_card(req).value!
        else
          @logger.notice "Unhandled Request Type: #{req.class}"
        end
      end
    end
  end
end