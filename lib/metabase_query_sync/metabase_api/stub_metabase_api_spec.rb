RSpec.describe MetabaseApi::StubMetabaseApi do
  include MetabaseApiFactory

  def given_an_api_with(collections: [], cards: [], pulses: [])
    @api = described_class.new(collections: collections, cards: cards, pulses: pulses)
  end

  def when_the_api
    @result = yield @api
  end

  def then_the_result_matches_success_of(expected)
    expect(@result).to eql(Dry::Monads::Success(expected))
  end

  def then_the_result_matches_failure_of(expected)
    expect(@result).to eql(Dry::Monads::Failure(expected))
  end

  context 'get_collection' do
    it 'returns success if matches id' do
      given_an_api_with(collections: [collection(id: 1)])
      when_the_api { |a| a.get_collection(1) }
      then_the_result_matches_success_of collection(id: 1)
    end

    it 'returns error if no matching id' do
      given_an_api_with(collections: [])
      when_the_api { |a| a.get_collection(1) }
      then_the_result_matches_failure_of(nil)
    end
  end

  context 'get_pulse' do
    it 'returns success if matches id' do
      given_an_api_with(pulses: [pulse(id: 1)])
      when_the_api { |a| a.get_pulse(1) }
      then_the_result_matches_success_of pulse(id: 1)
    end

    it 'returns error if no matching id' do
      given_an_api_with(pulses: [])
      when_the_api { |a| a.get_pulse(1) }
      then_the_result_matches_failure_of(nil)
    end
  end

  context 'get_card' do
    it 'returns success if matches id' do
      given_an_api_with(cards: [card(id: 1)])
      when_the_api { |a| a.get_card(1) }
      then_the_result_matches_success_of card(id: 1)
    end

    it 'returns error if no matching id' do
      given_an_api_with(cards: [])
      when_the_api { |a| a.get_pulse(1) }
      then_the_result_matches_failure_of(nil)
    end
  end

  context 'get_collection_items' do
    it 'returns failure if collection does not exist' do
      given_an_api_with
      when_the_api { |a| a.get_collection_items(1) }
      then_the_result_matches_failure_of(nil)
    end
    it 'can get_collection_items' do
      given_an_api_with(collections: [
        collection(id: 1, name: 'Collection', parent_id: 1),
        collection(id: 2, parent_id: 2),
      ], pulses: [
        pulse(id: 3, collection_id: 2),
        pulse(id: 4, name: 'Pulse', collection_id: 1),
      ], cards: [
        card(id: 5, name: 'Card', collection_id: 1),
        card(id: 6, collection_id: nil),
      ])

      when_the_api { |a| a.get_collection_items(1) }

      then_the_result_matches_success_of([
        item(id: 1, collection_id: 1, name: 'Collection', model: 'collection'),
        item(id: 4, collection_id: 1, name: 'Pulse', model: 'pulse'),
        item(id: 5, collection_id: 1, name: 'Card', model: 'card'),
      ])
    end
  end
end
