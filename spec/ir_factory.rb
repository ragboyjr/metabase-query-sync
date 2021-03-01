module IRFactory
  def graph(collections: [], pulses: [pulse(name: 'Test Pulse')], queries: [])
    IR::Graph.new(collections: collections, pulses: pulses, queries: queries)
  end

  def query(id: nil, name:, description: nil, slug: nil, database:'Local', pulse: 'Test Pulse', collection: nil, sql: 'select * from orders')
    IR::Query.new(id: id || name.downcase.gsub(' ', '-'), name: name, description: description, slug: slug || name.downcase, database: database, pulse: pulse, collection: collection, sql: sql)
  end

  def pulse(name:, alerts: nil)
    IR::Pulse.new(name: name, alerts: alerts || [
      pulse_alert do |a|
        a.emails ['ragboyjr@icloud.com']
        a.hourly
      end
    ])
  end

  def pulse_alert
    (yield PulseAlertBuilder.new).()
  end

  class PulseAlertBuilder
    def initialize
      @args = {}
    end

    def hourly
      @args = @args.merge({schedule: {type: 'hourly'}})
      self
    end

    def slack(channel)
      @args = @args.merge({type: 'slack', slack: {channel: channel}})
      self
    end

    def emails(emails)
      @args = @args.merge({type: 'email', email: {emails: emails}})
      self
    end

    def call
      IR::Pulse::Alert.new(@args)
    end
  end
end