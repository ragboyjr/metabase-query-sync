class MetabaseQuerySync::QueryDef::ReadQueryDefs
  # @return [Array<QueryDef>]
  def call()
    raise 'call must be implemented for read query defs'
  end
end