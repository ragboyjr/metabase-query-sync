RSpec.describe MetabaseQuerySync::Sync do
  before do
    @api = Class.new do
      include MetabaseApiFactory, MetabaseApiSteps
    end.new
    @ir = Class.new do
      include IRFactory, IRSteps
    end.new
  end

  def when_a_sync_occurs(root_collection_id: 1, dry_run: false)
    described_class.new(@ir.read_ir, @api.api).(MetabaseQuerySync::SyncRequest.new(root_collection_id: root_collection_id, dry_run: dry_run))
  end

  it 'archives pulses that are not in the ir' do
    @api.given_an_api_with(pulses: [@api.pulse(id: 1, collection_id: 1)])
    @ir.given_a_graph(pulses: [])
    when_a_sync_occurs
    @api.then_the_api_received([
      @api.put_pulse_request(id: 1, collection_id: 1, archived: true)
    ])
    end
  it 'archives cards that are not in the ir' do
    @api.given_an_api_with(cards: [@api.card(id: 1, collection_id: 1)])
    @ir.given_a_graph(queries: [])
    when_a_sync_occurs
    @api.then_the_api_received([
      @api.put_card_request(id: 1, collection_id: 1, archived: true)
    ])
  end
  it 'adds cards that are not in metabase' do
    @api.given_an_api_with
    @ir.given_a_graph(queries: [@ir.query(name: 'Test Query')])
    when_a_sync_occurs
    @api.then_the_api_received([
      @api.put_card_request(id: nil, collection_id: 1, name: 'Test Query')
    ])
  end
  xit 'adds pulses that are not in metabase' do

  end
  xit 'updates pulse cards that have changed' do

  end
  xit 'updates pulse channels that have changed' do

  end
  xit 'updates pulse names that have changed' do

  end
  xit 'updates card name and descriptions that have changed' do

  end
  xit 'updates card sql that has changed' do

  end
end
