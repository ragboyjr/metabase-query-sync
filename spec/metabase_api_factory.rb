module MetabaseApiFactory
  def card(attributes = {})
    MetabaseApi::Card.native({
      id: nil,
      name: 'Test Card',
      database_id: 1,
      sql: 'select * from orders'
    }.merge(attributes))
  end

  def put_card_request(attributes = {})
    MetabaseApi::PutCardRequest.native({
      id: nil,
      name: 'Test Card',
      database_id: 1,
      sql: 'select * from orders'
    }.merge(attributes))
  end

  def database(id:, name:)
    MetabaseApi::Database.new(id: id, name: name)
  end

  def item(attributes = {})
    MetabaseApi::Item.new(attributes)
  end

  def collection(attributes = {})
    MetabaseApi::Collection.new({
      id: nil,
      name: 'Test Collection',
      slug: 'test-collection',
      location: '/',
      parent_id: nil,
    }.merge(attributes))
  end

  def pulse(attributes = {})
    MetabaseApi::Pulse.new({
      id: nil,
      name: 'Test Pulse',
      cards: [],
      channels: [pulse_channel { |c| c.hourly.emails ['ragboyjr@icloud.com']}],
      skip_if_empty: true,
    }.merge(attributes))
  end

  def put_pulse_request(attributes = {})
    MetabaseApi::PutPulseRequest.new({
      id: nil,
      name: 'Test Pulse',
      cards: [],
      channels: [pulse_channel { |c| c.hourly.emails ['ragboyjr@icloud.com']}],
      skip_if_empty: true
    }.merge(attributes))
  end

  def pulse_card(attributes = {})
    MetabaseApi::Pulse::Card.new(attributes)
  end

  def pulse_channel(&block)
    MetabaseApi::Pulse::Channel.build(&block)
  end
end