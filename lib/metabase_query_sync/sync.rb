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
      new(ReadIR::FromFiles.new(config.paths, logger), MetabaseApi::FaradayMetabaseApi.from_metabase_credentials(config.credentials), logger)
    end

    # @param sync_req [SyncRequest]
    def call(sync_req)
      @logger.info "Starting sync with req: #{sync_req.to_h}"
      graph = @read_ir.()
      metabase_state = MetabaseState.from_metabase_api(@metabase_api, sync_req.root_collection_id)

      calc_diffs = [
        CalcDiff::CardCalcDiff.new,
        CalcDiff::PulseCalcDiff.new
      ]

      calc_diffs.reduce(metabase_state) do |metabase_state, calc_diff|
        calc_diff_req = CalcDiffRequest.new(graph: graph, metabase_state: metabase_state, root_collection_id: sync_req.root_collection_id)
        sync_requests(calc_diff.(calc_diff_req), sync_req.dry_run, metabase_state)
      end

      @logger.info "Finished sync"
    end

    private

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