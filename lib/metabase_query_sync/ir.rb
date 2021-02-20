require 'dry-schema'

# Internal Representation
module MetabaseQuerySync::IR
  # given an abstract hash representation of
  # an IR item, create the corresponding IR item
  # @return [Collection, Pulse, Query]
  def self.item_from_h(h)
    result = Dry::Schema.JSON do
      required(:type).value(:str?, :filled?, included_in?: ['collection', 'pulse', 'query'])
    end.(h)
    raise "Invalid hash provided: #{result.errors.to_h}" if result.errors?

    case h["type"]
    when "collection"
      raise 'not implemented'
    when "pulse"
      raise 'not implemented'
    when "query"
      Query.from_h(h)
    end
  end
end