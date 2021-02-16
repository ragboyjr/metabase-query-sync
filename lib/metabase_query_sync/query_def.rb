require 'dry/schema'

class MetabaseQuerySync::QueryDef
  attr_reader :name, :sql, :alerts

  class Alert
    attr_reader :frequency

    class Frequency
      class Daily < Frequency;
        attr_reader :hour
        def initialize(hour)
          raise 'expected int between 0 and 23' unless (0..23) === hour
          @hour = hour
        end

        def ==(o)
          o.is_a?(Daily) && hour == o.hour
        end

        def self.schema
          Dry::Schema.JSON do
            required(:type).value(:string, eql?: 'daily')
            required(:hour).filled(:integer)
          end
        end

        def self.from_validated_hash(h)
          new(h['hour'])
        end
      end

      class Hourly < Frequency
        def self.schema
          Dry::Schema.JSON do
            required(:type).value(:string, eql?: 'hourly')
          end
        end

        def ==(o)
          o.is_a?(Hourly)
        end

        def self.from_validated_hash(h)
          new
        end
      end

      def self.schema
        Daily.schema | Hourly.schema
      end

      # @return [Frequency]
      def self.from_validated_hash(h)
        case h["type"]
        when 'daily'
          Daily.from_validated_hash(h)
        when 'hourly'
          Hourly.from_validated_hash(h)
        end
      end
    end

    # @param [Alert::Frequency] frequency
    def initialize(frequency)
      @frequency = frequency
    end

    class Slack < self
      attr_reader :channel
      # @param frequency [Frequency]
      # @param channel [String]
      def initialize(frequency, channel)
        super(frequency)
        @channel = channel
      end

      def ==(o)
        o.is_a?(Slack) && frequency == o.frequency && channel == o.channel
      end

      def self.schema
        Dry::Schema.JSON do
          required(:type).value(:string, eql?: 'slack')
          required(:frequency).hash(Frequency.schema)
          required(:channel).filled(:string)
        end
      end

      def self.from_validated_hash(h)
        new(Frequency.from_validated_hash(h["frequency"]), h["channel"])
      end
    end

    class Email < self
      attr_reader :recipients

      class Recipient
        class EmailAddress < self
          attr_reader :email
          # @param email [String]
          def initialize(email)
            @email = email
          end

          def self.schema
            Dry::Schema.JSON do
              required(:type).value(:string, eql?: 'email_address')
              required(:email).filled(:string)
            end
          end

          def ==(o)
            o.is_a?(EmailAddress) && email == o.email
          end

          def self.from_validated_hash(h)
            return new(h["email"])
          end
        end
        class User < self
          def initialize()
            raise %q{Not implemented yet, eventually we'll be able to support user account recipients.}
          end
        end

        def self.schema
          EmailAddress.schema
        end

        def self.from_validated_hash(h)
          case h["type"]
          when "email_address"
            EmailAddress.from_validated_hash(h)
          else
            raise 'Unexpected case'
          end
        end
      end

      # @param frequency [Frequency]
      # @param recipients [Array<Recipient>]
      def initialize(frequency, recipients)
        super(frequency)
        @recipients = recipients
      end

      def ==(o)
        o.is_a?(Email) && frequency == o.frequency && recipients == o.recipients
      end

      def self.schema
        Dry::Schema.JSON do
          required(:type).value(:string, eql?: 'email')
          required(:frequency).hash(Frequency.schema)
          required(:recipients).array(:filled?, Recipient.schema)
        end
      end

      def self.from_validated_hash(h)
        new(Frequency.from_validated_hash(h["frequency"]), h["recipients"].map { |r| Recipient.from_validated_hash(r) })
      end
    end

    # @param h [Hash]
    # @return [Alert]
    def self.from_validated_hash(h)
      case h["type"]
      when "slack"
        Slack.from_validated_hash(h)
      when "email"
        Email.from_validated_hash(h)
      else
        raise 'Unhandled case.'
      end
    end

    def self.schema
      Slack.schema | Email.schema
    end
  end

  # @param alerts [Array<Alert>]
  def initialize(name:, sql:, alerts: [])
    @name = name
    @sql = sql
    @alerts = alerts
  end

  def ==(o)
    o.is_a?(QueryDef) && name == o.name && sql == o.sql && alerts == o.alerts
  end

  # @param h [Hash]
  # @return [QueryDef]
  def self.from_h(h)
    # @type [Dry::Schema::Result]
    result = Dry::Schema.JSON do
      required(:name).filled(:string)
      required(:sql).filled(:string)
      optional(:alerts).array(:filled?, Alert.schema)
    end.(h)
    raise "Invalid hash provided: #{result.errors.to_h}" if result.failure?

    new(
      name: h["name"],
      sql: h["sql"],
      alerts: Array(h["alerts"]).map { |alert| Alert.from_validated_hash(alert) }
    )
  end
end