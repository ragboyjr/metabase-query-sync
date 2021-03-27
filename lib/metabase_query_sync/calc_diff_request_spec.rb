RSpec.describe MetabaseQuerySync::CalcDiffRequest do
  # simple throw away test to just help understand dry-struct semantics
  it 'can accept a graph and metabase state' do
    res = described_class.new(
      graph: IR::Graph.from_items([]),
      metabase_state: MetabaseQuerySync::MetabaseState.empty,
      root_collection_id: 1
    )
    expect(res).to be_kind_of(described_class)
  end
end
