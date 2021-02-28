RSpec.describe MetabaseQuerySync::ReadIR do
  it 'throws exception on call' do
    expect {
      described_class.new.()
    }.to raise_error(RuntimeError, 'not implemented.')
  end
end
