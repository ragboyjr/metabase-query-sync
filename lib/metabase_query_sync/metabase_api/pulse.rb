class MetabaseQuerySync::MetabaseApi
  class Pulse < Model
    KEY = "pulse"

    class Channel < Model
      attribute :enabled, MetabaseQuerySync::Types::Strict::Bool.default(true)
      attribute :schedule_type, MetabaseQuerySync::Types::Strict::String
      attribute :schedule_day, MetabaseQuerySync::Types::Strict::String.optional
      attribute :schedule_hour, MetabaseQuerySync::Types::Strict::Integer.optional
      attribute :schedule_frame, MetabaseQuerySync::Types::Strict::String.optional
      attribute :channel_type, MetabaseQuerySync::Types::Strict::String.enum('email', 'slack')
      attribute? :recipients, MetabaseQuerySync::Types::Strict::Array do
        attribute :email, MetabaseQuerySync::Types::Strict::String
      end
      attribute? :details do
        attribute :channel, MetabaseQuerySync::Types::Strict::String
      end

      def self.build
        (yield ChannelBuilder.new).()
      end

      class ChannelBuilder
        def initialize
          @args = {}
          @class = nil
        end

        # @param hour [Integer] value between 0 and 23
        def daily(hour)
          assert_hour hour
          @args = @args.merge({schedule_type: 'daily', schedule_day: nil, schedule_frame: nil, schedule_hour: hour})
          self
        end

        def assert_hour(hour)
          raise "invalid hour provided (#{hour})" unless (0..23) === hour
        end
        def assert_day(day)
          raise "invalid day provided (#{day})" unless [:sun, :mon, :tue, :wed, :thu, :fri, :sat] === day
        end

        # @param hour [Integer] value between 0 and 23
        # @param day [:sun, :mon, :tue, :wed, :thu, :fri, :sat]
        def weekly(hour, day)
          assert_hour hour
          assert_day day
          @args = @args.merge({
            schedule_type: 'weekly',
            schedule_day: day.to_s,
            schedule_frame: nil,
            schedule_hour: hour
          })
          self
        end

        def hourly
          @args = @args.merge({schedule_type: 'hourly', schedule_day: nil, schedule_frame: nil, schedule_hour: nil})
          self
        end

        # @param emails [Array<String>]
        def emails(emails)
          @args = @args.merge({channel_type: 'email', recipients: emails.map {|e| {email: e}} })
          self
        end

        # @param channel [String]
        def slack(channel)
          @args = @args.merge({channel_type: 'slack', details: {channel: channel}})
          self
        end

        def call()
          Channel.new(@args)
        end
      end
    end

    class Card < Model
      attribute :id, MetabaseQuerySync::Types::Strict::Integer
      attribute :include_csv, MetabaseQuerySync::Types::Strict::Bool.default(false)
      attribute :include_xls, MetabaseQuerySync::Types::Strict::Bool.default(false)
    end

    has :id, :archived, :name, :collection_id
    attribute :cards, MetabaseQuerySync::Types::Strict::Array.of(Pulse::Card)
    attribute :channels, MetabaseQuerySync::Types::Strict::Array.of(Pulse::Channel)
    attribute :skip_if_empty, MetabaseQuerySync::Types::Strict::Bool

    # @param put_pulse_request [PutPulseRequest]
    # @return self
    def self.from_request(put_pulse_request)
      new(put_pulse_request.to_h)
    end
  end
end