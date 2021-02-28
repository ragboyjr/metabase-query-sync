RSpec.describe IR::Pulse do
  extend IRFactory
  context 'create and validate' do
    [
      [
        {name: "Pulse", alerts: [
          {type: "email", schedule: {type: 'hourly'}, email: {emails: ["test@test.com"]}}
        ]},
        pulse(name: "Pulse", alerts: [
          pulse_alert do |a|
            a.emails ["test@test.com"]
            a.hourly
          end
        ])
      ],
      [
        {"name"=>"Hourly", "alerts"=>[{"type"=>"slack", "slack"=>{"channel"=>"#alerts"}, "schedule"=>{"type"=>"hourly"}}]},
        pulse(name: "Hourly", alerts: [
          pulse_alert do |a|
            a.slack '#alerts'
            a.hourly
          end
        ])
      ]
    ].each do |(schema, expected)|
      it "allows the following schema: #{schema}" do
        expect(described_class.from_h(schema)).to eq(expected)
      end
    end

    [
      {},
      {name: "Pulse", alerts: []},
      {name: "Pulse", alerts: [
        {type: "email", schedule: {}, email: {emails: ["test@test.com"]}}
      ]},
    ].each do |schema|
      it "rejects the following schema: #{schema}" do
        expect {
          described_class.from_h(schema)
        }.to raise_error(RuntimeError)
      end
    end
  end
end
