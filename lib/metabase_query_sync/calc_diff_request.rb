require 'dry-struct'

module MetabaseQuerySync
  # @!method graph
  #   @return [IR::Graph]
  # @!method metabase_state
  #   @return [MetabaseState]
  # @!method root_collection_id
  #   @return [Integer]
  class CalcDiffRequest < Dry::Struct
    attribute :graph, Types.Strict(IR::Graph)
    attribute :metabase_state, Types.Strict(MetabaseState)
    attribute :root_collection_id, Types::Strict::Integer
  end
end