require 'json'

RSpec.describe MetabaseApi::FaradayMetabaseApi do
  def given_the_api_is_setup_with(&configure_stubs)
    @client = MetabaseApi::FaradayMetabaseApi.from_metabase_credentials(
      MetabaseQuerySync::MetabaseCredentials.new(host: "http://localhost", user: "test", pass: "test")
    ) do |c|
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.post('/api/session') { json_response({"id" => "84fa6c52-d714-442b-a816-8c86036925e2"}) }
      configure_stubs.(stubs)
      c.adapter :test, stubs
    end
  end

  def when_the_client
    @result = yield @client
  end

  def then_the_result_is_successful
    expect(@result.success?).to be(true)
  end

  def and_if_query_params(hash, response)
    ->(env) do
      response if env.params == hash
    end
  end

  def json_response(body, status: 200)
    [status, {'Content-Type' => 'application/json' }, body.to_json]
  end

  module Factory
    def self.collection(h = {})
      {"id" => 1, "archived" => false, "slug" => "sales", "name" => "Sales", "location" => "/", "description" => nil, "parent_id" => nil}.merge(h)
    end

    def self.card(h = {})
      JSON.parse(%q({"id":2,"archived":false,"display":"table","visualization_settings":{},"name":"Test Card","description":null,"database_id":2,"collection_id":2,"query_type":"native","dataset_query":{"type":"native","native":{"query":"SELECT * FROM orders"},"database":2}})).merge(h)
    end
  end

  it 'can search by query and model' do
    given_the_api_is_setup_with do |stubs|
      stubs.get('/api/search', &and_if_query_params(
        {"q" => "a", "model" => "collection"},
        json_response([{"id" => 1, "name" => "a", "description" => nil, "model" => "collection"}])
      ))
    end
    when_the_client { |client| client.search('a', model: 'collection') }
    then_the_result_is_successful
  end

  it 'can get collection' do
    given_the_api_is_setup_with do |stubs|
      stubs.get('/api/collection/1') { json_response(Factory.collection) }
    end
    when_the_client { |client| client.get_collection(1) }
    then_the_result_is_successful
  end

  it 'can get collection items' do
    given_the_api_is_setup_with do |stubs|
      stubs.get('/api/collection/1/items') { json_response( [{"id" => 1, "name" => "Sales", "model" => "collection", "description" => nil}]) }
    end
    when_the_client { |client| client.get_collection_items(1) }
    then_the_result_is_successful
  end

  it 'can get databases' do
    given_the_api_is_setup_with do |stubs|
      stubs.get('/api/database') { json_response( [{"id" => 1, "name" => "Local Db"}]) }
    end
    when_the_client { |client| client.get_databases() }
    then_the_result_is_successful
  end

  it 'can create a collection' do
    given_the_api_is_setup_with do |stubs|
      stubs.post('/api/collection', %q({"id":null,"name":"Test","color":"#509EE3","description":null,"parent_id":null,"archived":false})) { json_response(Factory.collection("name" => "Test")) }
    end
    when_the_client { |client| client.put_collection(MetabaseApi::PutCollectionRequest.new(name: "Test")) }
    then_the_result_is_successful
  end

  it 'can update a collection' do
    given_the_api_is_setup_with do |stubs|
      stubs.put('/api/collection/5', %q({"id":5,"name":"Test","color":"#509EE3","description":null,"parent_id":null,"archived":false})) { json_response(Factory.collection("id" => 5, "name" => "Test")) }
    end
    when_the_client { |client| client.put_collection(MetabaseApi::PutCollectionRequest.new(id: 5, name: "Test")) }
    then_the_result_is_successful
  end

  it 'can get a card' do
    given_the_api_is_setup_with do |stubs|
      stubs.get('/api/card/2') { json_response(Factory.card) }
    end
    when_the_client { |client| client.get_card(2) }
    then_the_result_is_successful
  end

  it 'can create a card' do
    given_the_api_is_setup_with do |stubs|
      stubs.post('/api/card', %q({"id":null,"name":"Orders","description":null,"display":"table","visualization_settings":{},"collection_id":2,"dataset_query":{"type":"native","native":{"query":"select * from orders"},"database":2}})) { json_response(Factory.card) }
    end
    when_the_client { |client| client.put_card(MetabaseApi::PutCardRequest.native(sql: 'select * from orders', database_id: 2, name: 'Orders', collection_id: 2))}
    then_the_result_is_successful
  end

  it 'can update a card' do
    given_the_api_is_setup_with do |stubs|
      stubs.put('/api/card/2', %q({"id":2,"name":"Orders","description":null,"display":"table","visualization_settings":{},"collection_id":2,"dataset_query":{"type":"native","native":{"query":"select * from orders"},"database":2}})) { json_response(Factory.card) }
    end
    when_the_client { |client| client.put_card(MetabaseApi::PutCardRequest.native(id: 2, sql: 'select * from orders', database_id: 2, name: 'Orders', collection_id: 2))}
    then_the_result_is_successful
  end
end
