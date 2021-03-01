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

  it 'archives cards and pulses that are not in the ir' do
    @api.given_an_api_with(cards: [@api.card(id: 1, collection_id: 1)], pulses: [@api.pulse(id: 1, collection_id: 1)])
    @ir.given_a_graph(queries: [], pulses: [])
    when_a_sync_occurs
    @api.then_the_api_received([
      @api.put_card_request(id: 1, collection_id: 1, archived: true),
      @api.put_pulse_request(id: 1, collection_id: 1, archived: true)
    ])
  end
  it 'adds cards and pulses that are not in metabase' do
    @api.given_an_api_with
    @ir.given_a_graph(
      queries: [@ir.query(name: 'Test Query', pulse: 'test-pulse', description: 'Query Test')],
      pulses: [
        @ir.pulse(name: 'Test Pulse', alerts: [
          @ir.pulse_alert { |a| a.hourly.emails ["test@gmail.com"] }
        ])
      ]
    )

    when_a_sync_occurs

    @api.then_the_api_received([
      @api.put_card_request(name: 'test-query:Test Query', collection_id: 1, description: 'Query Test'),
      @api.put_pulse_request(name: 'test-pulse:Test Pulse', channels: [
        @api.pulse_channel { |c| c.hourly.emails(["test@gmail.com"])}
      ], cards: [@api.pulse_card(id: 1)], collection_id: 1)
    ])
  end
  it 'sends no requests when cards and pulses have not changed' do
    @api.given_an_api_with(
      cards: [@api.card(id: 1, name: 'card-1:Card 1', sql: 'select 1', collection_id: 1)],
      pulses: [@api.pulse(id: 1, name: 'pulse-1:Pulse 1', cards: [@api.pulse_card(id: 1)], collection_id: 1)]
    )
    @ir.given_a_graph(
      queries: [@ir.query(name: 'Card 1', pulse: 'pulse-1', sql: 'select 1')],
      pulses: [@ir.pulse(name: 'Pulse 1')]
    )

    when_a_sync_occurs

    @api.then_the_api_received([])
  end

  context 'it updates cards when' do
    def given_card_in_api(attributes)
      @api.given_an_api_with(
        cards: [@api.card(**{id: 1, name: 'card-1:Card 1', sql: 'select 1', collection_id: 1}.merge(attributes))],
        pulses: [@api.pulse(id: 1, name: 'pulse-1:Pulse 1', cards: [@api.pulse_card(id: 1)], collection_id: 1)],
        databases: [@api.database(id: 1, name: 'Local'), @api.database(id: 2, name: 'Local 2')]
      )
    end
    def given_query_in_graph(attributes)
      @ir.given_a_graph(
        queries: [@ir.query(**{name: 'Card 1', pulse: 'pulse-1', sql: 'select 1'}.merge(attributes))],
        pulses: [@ir.pulse(name: 'Pulse 1')]
      )
    end

    it 'name changes' do
      given_card_in_api(name: 'card-1:Card 1')
      given_query_in_graph(id: 'card-1', name: 'Card 1 Updated')
      when_a_sync_occurs
      @api.then_the_api_received([
        @api.put_card_request(id: 1, name:'card-1:Card 1 Updated', sql: 'select 1', collection_id: 1)
      ])
    end
    it 'sql changes' do
      given_card_in_api(sql: 'select old')
      given_query_in_graph(sql: 'select new')
      when_a_sync_occurs
      @api.then_the_api_received([
        @api.put_card_request(id: 1, name: 'card-1:Card 1', sql: 'select new', collection_id: 1),
      ])
    end
    it 'description changes' do
      given_card_in_api(description: 'description old')
      given_query_in_graph(description: 'description new')
      when_a_sync_occurs
      @api.then_the_api_received([
        @api.put_card_request(id: 1, name: 'card-1:Card 1', sql: 'select 1', description: 'description new', collection_id: 1)
      ])
    end
    it 'database changes' do
      given_card_in_api(database_id: 1)
      given_query_in_graph(database: 'Local 2')
      when_a_sync_occurs
      @api.then_the_api_received([
        @api.put_card_request(id: 1, name: 'card-1:Card 1', sql: 'select 1', database_id: 2, collection_id: 1),
      ])
    end
  end

  context 'it updates pulses when' do
    def given_pulse_in_api(**attributes)
      @api.given_an_api_with(
        cards: [@api.card(id: 1, name: 'card-1:Card 1', sql: 'select 1', collection_id: 1)],
        pulses: [@api.pulse(id: 1, name: 'pulse-1:Pulse 1', cards: [@api.pulse_card(id: 1)], channels: [@api.pulse_channel { |c| c.hourly.slack '#test' }], collection_id: 1, **attributes)],
      )
    end
    def given_pulse_in_graph(**attributes)
      @ir.given_a_graph(
        queries: [@ir.query(name: 'Card 1', pulse: 'pulse-1', sql: 'select 1')],
        pulses: [@ir.pulse(id: 'pulse-1', name: 'Pulse 1', alerts: [@ir.pulse_alert { |a| a.hourly.slack '#test' }], **attributes)]
      )
    end
    def put_pulse_request(**attributes)
      @api.put_pulse_request(id: 1, name: 'pulse-1:Pulse 1', collection_id: 1, cards: [@api.pulse_card(id: 1)], channels: [@api.pulse_channel { |c| c.hourly.slack '#test' }], **attributes)
    end
    it 'name changes' do
      given_pulse_in_api
      given_pulse_in_graph(name: 'Pulse 1 Updated')
      when_a_sync_occurs
      @api.then_the_api_received([
        put_pulse_request(name: 'pulse-1:Pulse 1 Updated')
      ])
    end
    it 'channels change' do
      given_pulse_in_api
      given_pulse_in_graph(alerts: [@ir.pulse_alert { |a| a.hourly.slack '#test-new' }])
      when_a_sync_occurs
      @api.then_the_api_received([
        put_pulse_request(channels: [@api.pulse_channel { |c| c.hourly.slack '#test-new' }])
      ])
    end
    it 'cards change' do
      @api.given_an_api_with(
        cards: [
          @api.card(id: 1, name: 'card-1:Card 1', sql: 'select 1', collection_id: 1),
          @api.card(id: 2, name: 'card-2:Card 2', sql: 'select 1', collection_id: 1),
        ],
        pulses: [@api.pulse(id: 1, name: 'pulse-1:Pulse 1', cards: [@api.pulse_card(id: 1)], channels: [@api.pulse_channel { |c| c.hourly.slack '#test' }], collection_id: 1)],
      )
      @ir.given_a_graph(
        queries: [
          @ir.query(name: 'Card 1', pulse: 'pulse-1', sql: 'select 1'),
          @ir.query(name: 'Card 2', pulse: 'pulse-1', sql: 'select 1'),
        ],
        pulses: [@ir.pulse(name: 'Pulse 1', alerts: [@ir.pulse_alert { |a| a.hourly.slack '#test' }])]
      )
      when_a_sync_occurs
      @api.then_the_api_received([
        put_pulse_request(cards: [@api.pulse_card(id: 1), @api.pulse_card(id: 2)])
      ])
    end
  end
end
