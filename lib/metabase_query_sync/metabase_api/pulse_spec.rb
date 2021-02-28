RSpec.describe MetabaseApi::Pulse do
  context 'when building channels' do
    def channel(&block)
      MetabaseApi::Pulse::Channel.build(&block)
    end

    it 'validates hours are in range for day schedule' do
      expect {
        channel { |c| c.daily(26) }
      }.to raise_error(RuntimeError, 'invalid hour provided (26)')
    end

    it 'validates days are in range for weekly schedule' do
      expect {
        channel { |c| c.weekly(22, :monday) }
      }.to raise_error(RuntimeError, 'invalid day provided (monday)')
    end
  end
end
