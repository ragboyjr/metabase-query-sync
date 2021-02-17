RSpec.describe MetabaseQuerySync::QueryDef do
  context 'can be created from hash' do
    [
      [{"name" => "Test", "sql" => "1", "database" => "Local"}, QueryDef.new(name: "Test", sql: "1", database: "Local")],
      [
        {"name" => "Test", "sql" => "1", "database" => "Local", "alerts" => [
          {"type" => "slack", "frequency" => {"type" => "hourly"}, "channel" => "#health-checks"}
        ]},
        QueryDef.new(name: "Test", sql: "1", database: "Local", alerts: [
          QueryDef::Alert::Slack.new(frequency: QueryDef::Alert::Frequency::Hourly.new, channel: '#health-checks')
        ])
      ],
      [
        {"name" => "Test", "sql" => "1", "database" => "Local", "alerts" => [
          {"type" => "email", "frequency" => {"type" => "daily", "hour" => 22}, "recipients" => [
            {"type" => "email_address", "email" => "test@gmail.com"}
          ]}
        ]},
        QueryDef.new(name: "Test", sql: "1", database: "Local", alerts: [
          QueryDef::Alert::Email.new(
            frequency: QueryDef::Alert::Frequency::Daily.new(hour: 22),
            recipients: [QueryDef::Alert::Email::Recipient::EmailAddress.new(email: "test@gmail.com")]
          )
        ])
      ],
    ].each do |(hash, expected)|
      it 'creates on valid hash: ' + hash.to_s do
        res = QueryDef.from_h(hash)
        expect(res).to eq(expected)
      end
    end


    [
      {},
      {"name" => 1, "sql" => 1}
    ].each do |hash|
      it 'raises errors on invalid hash: ' + hash.to_s do
        expect do
          QueryDef.from_h(hash)
        end.to raise_error(RuntimeError, /Invalid hash provided:/)
      end
    end
  end

  context 'Frequency::Daily' do
    it 'validates integers are in range of 0..23' do
      expect do
        QueryDef::Alert::Frequency::Daily.new(hour: 25)
      end.to raise_error(RuntimeError, 'Hour 25 must be within 0 and 23')
    end
  end
end