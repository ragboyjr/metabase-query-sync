module MetabaseApiSteps
  attr_reader :api

  def given_an_api_with(collections: nil, cards: [], pulses: [], databases: nil)
    @api = MetabaseApi::StubMetabaseApi.new(collections: collections == nil ? [collection(id: 1)] : collections, cards: cards, pulses: pulses, databases: databases == nil ? [
      database(id: 1, name: 'Local')
    ] : databases)
  end

  def given_an_empty_api
    given_an_api_with(collections: [], cards: [], pulses: [])
  end

  def then_the_api_received(requests)
    RSpec::Expectations::ExpectationTarget.new(@api.requests).to RSpec::Matchers::BuiltIn::Eql.new(requests)
  end
end