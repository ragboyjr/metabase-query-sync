require 'yaml'

class MetabaseQuerySync::ReadIR
  class FromFiles < self
    def initialize(path)
      @path = path
    end

    def call
      MetabaseQuerySync::IR::Graph.from_items(
        # @type [String] f
        Dir[File.join(@path, "**/*.{query,pulse}.yaml")].map do |f|
          data = YAML.load_file(f)
          next MetabaseQuerySync::IR::Query.from_h(data) if f.end_with? 'query.yaml'
          next MetabaseQuerySync::IR::Pulse.from_h(data) if f.end_with? 'pulse.yaml'
        end
      )
    end
  end
end