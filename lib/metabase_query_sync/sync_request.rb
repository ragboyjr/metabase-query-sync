require 'dry-struct'

module MetabaseQuerySync
  # @!method root_collection_id
  #   @return [Integer]
  # @!method dry_run
  #   @return [Boolean]
  class SyncRequest < Dry::Struct
    attribute :root_collection_id, Types::Strict::Integer
    attribute :dry_run, Types::Strict::Bool.default(false)
  end
end