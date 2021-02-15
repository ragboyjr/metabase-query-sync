require 'dry/schema'

class MetabaseQuerySync::QueryDef::QueryDef
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
      end
      class Hourly; end
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
    end

    class Email < self
      attr_reader :recipients

      class Recipient
        class Email < self
          attr_reader :email
          # @param email [String]
          def initialize(email)
            @email = email
          end
        end
        class User < self
          def initialize()
            raise %q{Not implemented yet, eventually we'll be able to support user account recipients.}
          end
        end
      end

      # @param frequency [Frequency]
      # @param recipients [Array<Recipient>]
      def initialize(frequency, recipients)
        super(frequency)
        @recipients = recipients
      end
    end
  end

  # @param alerts [Array<Alert>]
  def initialize(name:, sql:, alerts: [])
    @name = name
    @sql = sql
    @alerts = alerts
  end

  # @param h [Hash]
  def self.from_h(h)
    # @type [Dry::Schema::Result]
    result = Dry::Schema.JSON do
      required(:name).filled(:string)
      required(:sql).filled(:string)
    end.(h)
    raise "Invalid hash provided: #{result.errors.to_h}" if result.failure?

    self.new(
      name: h["name"],
      sql: h["sql"],
    )
  end
end