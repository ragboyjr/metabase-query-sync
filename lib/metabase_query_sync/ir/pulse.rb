module MetabaseQuerySync::IR
  class Pulse < Model
    attribute :name, string
    attribute :queries, array.of(string)
    attribute :skip_if_empty, bool.default(true)
    attribute :alerts, array do
      attribute :type, string.enum('email', 'slack')
      attribute :email do
        attribute :emails, array.of(string)
      end
      attribute :slack do
        attribute :channel, string
      end
      attribute :schedule do
        attribute :type, string.enum('hourly', 'daily', 'weekly')
        attribute :hour, integer.optional.default(nil)
        attribute :day, string.enum('sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat')
      end
    end
  end
end