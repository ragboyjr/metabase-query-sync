class MetabaseQuerySync::MetabaseApi
  class PutPulseRequest < ApiRequest
    has :id, :name, :archived, :collection_id
    attribute :cards, MetabaseQuerySync::Types::Strict::Array.of(Pulse::Card)
    attribute :channels, MetabaseQuerySync::Types::Strict::Array.of(Pulse::Channel)
    attribute :skip_if_empty, MetabaseQuerySync::Types::Strict::Bool

    def self.from_pulse(pulse)
      new(pulse.to_h)
    end
  end
end