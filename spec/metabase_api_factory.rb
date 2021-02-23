module MetabaseApiFactory
  def card(attributes = {})
    MetabaseApi::Card.native({
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
      channels: [],
      skip_if_empty: true,
    }.merge(attributes))
  end
end