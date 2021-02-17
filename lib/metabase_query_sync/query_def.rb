require 'dry-schema'
require 'dry-struct'

class MetabaseQuerySync::QueryDef < Dry::Struct
  class Alert < Dry::Struct
    class Frequency < Dry::Struct
      class Daily < Frequency
        attribute :hour, MetabaseQuerySync::Types::Strict::Integer

        def initialize(hour:)
          raise "Hour #{hour} must be within 0 and 23" unless (0..23) === hour
          super(hour: hour)
        end

        def self.create_schema
          Dry::Schema.JSON do
            required(:type).value(:string, eql?: 'daily')
            required(:hour).filled(:integer)
          end
        end

        def self.from_validated_hash(h)
          new(hour: h["hour"])
        end
      end

      class Hourly < Frequency
        def self.create_schema
          Dry::Schema.JSON do
            required(:type).value(:string, eql?: 'hourly')
          end
        end

        def self.from_validated_hash(h)
          new
        end
      end

      def self.create_schema
        Daily.create_schema | Hourly.create_schema
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

    class Slack < self
      attribute :channel, MetabaseQuerySync::Types::Strict::String

      def self.create_schema
        Dry::Schema.JSON do
          required(:type).value(:string, eql?: 'slack')
          required(:frequency).hash(Frequency.create_schema)
          required(:channel).filled(:string)
        end
      end

      def self.from_validated_hash(h)
        new(frequency: Frequency.from_validated_hash(h["frequency"]), channel: h["channel"])
      end
    end

    class Email < self
      class Recipient < Dry::Struct
        class EmailAddress < self
          attribute :email, MetabaseQuerySync::Types::Strict::String

          def self.create_schema
            Dry::Schema.JSON do
              required(:type).value(:string, eql?: 'email_address')
              required(:email).filled(:string)
            end
          end

          def self.from_validated_hash(h)
            return new(email: h["email"])
          end
        end

        class User < self
          def initialize()
            raise %q{Not implemented yet, eventually we'll be able to support user account recipients.}
          end
        end

        def self.create_schema
          EmailAddress.create_schema
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

      attribute :recipients, MetabaseQuerySync::Types::Strict::Array.of(MetabaseQuerySync::Types.Instance(Recipient))

      def self.create_schema
        Dry::Schema.JSON do
          required(:type).value(:string, eql?: 'email')
          required(:frequency).hash(Frequency.create_schema)
          required(:recipients).array(:filled?, Recipient.create_schema)
        end
      end

      def self.from_validated_hash(h)
        new(frequency: Frequency.from_validated_hash(h["frequency"]), recipients: h["recipients"].map { |r| Recipient.from_validated_hash(r) })
      end
    end

    attribute :frequency, Frequency

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

    def self.create_schema
      Slack.create_schema | Email.create_schema
    end
  end

  attribute :name, MetabaseQuerySync::Types::Strict::String
  attribute :sql, MetabaseQuerySync::Types::Strict::String
  attribute :database, MetabaseQuerySync::Types::Strict::String
  attribute :alerts, MetabaseQuerySync::Types::Strict::Array.default([].freeze).of(MetabaseQuerySync::Types.Instance(Alert))

  # @param h [Hash]
  # @return [QueryDef]
  def self.from_h(h)
    # @type [Dry::Schema::Result]
    result = Dry::Schema.JSON do
      required(:name).filled(:string)
      required(:sql).filled(:string)
      required(:database).filled(:string)
      optional(:alerts).array(:filled?, Alert.create_schema)
    end.(h)
    raise "Invalid hash provided: #{result.errors.to_h}" if result.failure?

    new(
      name: h["name"],
      sql: h["sql"],
      database: h["database"],
      alerts: Array(h["alerts"]).map { |alert| Alert.from_validated_hash(alert) }
    )
  end
end