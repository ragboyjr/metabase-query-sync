require 'faraday'
require 'faraday_middleware'
require 'dry-monads'

class MetabaseQuerySync::MetabaseApi
  class FaradayMetabaseApi < self
    include Dry::Monads[:result]

    # @param client [Faraday::Connection]
    # @param user [String]
    # @param pass [String]
    def initialize(client:, user:, pass:)
      @client = client
      @user = user
      @pass = pass
    end

    # @param creds [MetabaseQuerySync::MetabaseCredentials]
    def self.from_metabase_credentials(creds, &configure_faraday)
      client = Faraday.new(url: creds.host) do |c|
        c.request :json, content_type: /\bjson$/
        c.response :json, content_type: /\bjson$/
        c.request :url_encoded, content_type: /x-www-form-urlencoded/
        c.response :logger
        c.adapter Faraday.default_adapter
        c.headers['User-Agent'] =
          "MetabaseQuerySync/#{MetabaseQuerySync::VERSION} (#{RUBY_ENGINE}#{RUBY_VERSION})"

        configure_faraday.call(c) if configure_faraday
      end

      new(client: client, user: creds.user, pass: creds.pass)
    end

    def search(q, model: nil)
      request(:get, '/api/search') do |req|
        req.params.update(q: q, model: model)
      end.fmap to_collection_of(Item)
    end

    def get_collection(id)
      request(:get, "/api/collection/#{id}").fmap to(Collection)
    end

    def get_collection_items(collection_id)
      request(:get, "/api/collection/#{collection_id}/items").fmap to_collection_of(Item)
    end

    def put_collection(collection_request)
      if collection_request.id
        request(:put, "/api/collection/#{collection_request.id}", body: collection_request.to_h)
      else
        request(:post, "/api/collection", body: collection_request.to_h)
      end.fmap to(Collection)
    end

    def get_databases
      request(:get, '/api/database').fmap to_collection_of(Database)
    end

    def get_card(id)
      request(:get, "/api/card/#{id}").fmap to(Card)
    end

    def put_card(card_request)
      if card_request.id
        request(:put, "/api/card/#{card_request.id}", body: card_request.to_h)
      else
        request(:post, "/api/card", body: card_request.to_h)
      end.fmap to(Card)
    end

    def put_pulse(pulse_request)
      if pulse_request.id
        request(:put, "/api/pulse/#{pulse_request.id}", body: pulse_request.to_h)
      else
        request(:post, "/api/pulse", body: pulse_request.to_h)
      end.fmap to(Pulse)
    end

    private

    def to(klass)
      klass.method(:new)
    end

    def to_collection_of(klass)
      ->(collection) { collection.map(&klass.method(:new)) }
    end

    def token
      @token ||= login.value!.id
    end

    def login
      return request(:post, '/api/session', body: {
        username: @user,
        password: @pass
      }, skip_token: true).fmap &to(Session)
    end

    def request(method, path, body: nil, headers: nil, skip_token: false, &block)
      res = @client.run_request(method, path, body, headers) do |req|
        req.headers['X-Metabase-Session'] = token unless skip_token
        block.call(req) if block
      end
      if (200..299) === res.status
        Success(res.body)
      else
        Failure(res)
      end
    end
  end
end