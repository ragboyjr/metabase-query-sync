class MetabaseQuerySync::MetabaseApi
  class PutPulseRequest < Model
    has :id, :name, :archived, :collection_id
    attribute :cards, MetabaseQuerySync::Types::Strict::Array.of(Pulse::Card)
    attribute :channels, MetabaseQuerySync::Types::Strict::Array.of(Pulse::Channel)
    attribute :skip_if_empty, MetabaseQuerySync::Types::Strict::Bool
  end
end