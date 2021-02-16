RSpec.describe MetabaseQuerySync::QueryDef do
  context 'can be created from hash' do
    [
      [{"name" => "Test", "sql" => "1"}, QueryDef.new(name: "Test", sql: "1")],
      [
        {"name" => "Test", "sql" => "1", "alerts" => [
          {"type" => "slack", "frequency" => {"type" => "hourly"}, "channel" => "#health-checks"}
        ]},
        QueryDef.new(name: "Test", sql: "1", alerts: [
          QueryDef::Alert::Slack.new(QueryDef::Alert::Frequency::Hourly.new, '#health-checks')
        ])
      ],
      [
        {"name" => "Test", "sql" => "1", "alerts" => [
          {"type" => "email", "frequency" => {"type" => "daily", "hour" => 22}, "recipients" => [
            {"type" => "email_address", "email" => "test@gmail.com"}
          ]}
        ]},
        QueryDef.new(name: "Test", sql: "1", alerts: [
          QueryDef::Alert::Email.new(
            QueryDef::Alert::Frequency::Daily.new(22),
            [QueryDef::Alert::Email::Recipient::EmailAddress.new("test@gmail.com")]
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
end