module MetabaseQuerySync::IR
  class Pulse < Model
    class AlertChannel < Model
      TYPES = ['email', 'slack'].freeze
      class Email < Model
        attribute :emails, array.of(string)
      end
      class Slack < Model
        attribute :channel, string
      end
      class Schedule < Model
        TYPES = ['hourly', 'daily', 'weekly'].freeze
        DAYS = [nil, 'sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'].freeze
        attribute :type, string.enum(*TYPES)
        attribute :hour, integer.optional.default(nil)
        attribute :day, string.optional.default(nil).enum(*DAYS)
      end

      attribute :type, string.enum(*TYPES)
      attribute :email, Email.optional.default(nil)
      attribute :slack, Slack.optional.default(nil)
      attribute :schedule, Schedule
    end

    attribute :id, string
    attribute :name, string
    attribute :skip_if_empty, bool.default(true)
    attribute :alerts, array.of(AlertChannel)

    validate_with_schema do
      required(:id).filled(:string)
      required(:name).filled(:string)
      optional(:skip_if_empty).value(:bool)
      required(:alerts).value(:array, min_size?: 1).each do
        hash do
          required(:type).value(:filled?, :str?, included_in?: AlertChannel::TYPES)
          required(:schedule).hash do
            required(:type).value(:filled?, :str?, included_in?: AlertChannel::Schedule::TYPES)
            optional(:hour).value(:integer)
            optional(:day).value(included_in?: AlertChannel::Schedule::DAYS)
          end
          optional(:email).hash do
            required(:emails).value(array[:string], min_size?: 1)
          end
          optional(:slack).hash do
            required(:channel).filled(:string)
          end
        end
      end
    end
  end
end