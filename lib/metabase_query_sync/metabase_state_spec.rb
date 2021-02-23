RSpec.describe MetabaseQuerySync::MetabaseState do
  include MetabaseApiFactory

  def given_an_api_with(collections: [], cards: [], pulses: [])
    @api = MetabaseApi::StubMetabaseApi.new(collections: collections, cards: cards, pulses: pulses, databases: [
      database(id: 1, name: 'Local')
    ])
  end

  def given_an_empty_api
    given_an_api_with
  end

  def when_the_state_is_created(root_collection_id)
    @state = described_class.from_metabase_api(@api, root_collection_id)
  end

  def then_the_state_is_empty
    expect(@state.empty?).to be(true)
  end

  context 'creating from metabase api' do
    it 'can create from an empty state' do
      given_an_empty_api
      when_the_state_is_created(1)
      then_the_state_is_empty
    end
    xit 'fails if no root collection is present' do

    end
    xit 'filters out for pulses and cards' do

    end
    xit 'recursively retrieves items from collections' do

    end
  end
end
