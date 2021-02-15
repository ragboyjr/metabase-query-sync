RSpec.describe MetabaseQuerySync::QueryDef::QueryDef do
  context 'can be created from hash' do
    [
      {name: "Test", sql: "1"}
    ].each do |hash|
      it 'creates on valid hash: ' + hash.to_s do
        res = MetabaseQuerySync::QueryDef::QueryDef.from_h(hash)
        expect(res).to be_instance_of(MetabaseQuerySync::QueryDef::QueryDef)
      end
    end


    [
      {},
      {name: 1, sql: 1}
    ].each do |hash|
      it 'raises errors on invalid hash: ' + hash.to_s do
        expect do
          MetabaseQuerySync::QueryDef::QueryDef.from_h(hash)
        end.to raise_error(RuntimeError, /Invalid hash provided:/)
      end
    end
  end
end