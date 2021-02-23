module MetabaseQuerySync
  # @!attribute metabase_api
  #   @return [MetabaseApi]
  class Sync
    def initialize(read_ir, metabase_api, logger = nil)
      @read_ir = read_ir
      @metabase_api = metabase_api
      @logger = logger || Logger.new(IO::NULL)
    end

    # @param sync_req [SyncRequest]
    def call(sync_req)
      graph = @read_ir.()
      metabase_state = MetabaseState.from_metabase_api(@metabase_api, sync_req.root_collection_id)
      sync_requests(calc_diff(graph, metabase_state), sync_req.dry_run)
    end

    private

    # return a set of requests to send to metabase
    def calc_diff(graph, metabase_state)
      []
    end

    # sync requests up to metabase
    def sync_requests(requests, dry_run)
      requests.each do |req|
        case req
        when MetabaseApi::PutPulseRequest
          @logger.info "PutPulseRequest #{req}"
          @metabase_api.put_pulse(req).value!
        when MetabaseApi::PutCardRequest
          @logger.info "PutCardRequest #{req}"
          @metabase_api.put_card(req).value!
        else
          @logger.notice "Unhandled Request Type: #{req.class}"
        end
      end
    end
  end
end