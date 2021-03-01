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
          next MetabaseQuerySync::IR::Query.from_h({id: id_from_file(f)}.merge(data)) if f.end_with? 'query.yaml'
          next MetabaseQuerySync::IR::Pulse.from_h({id: id_from_file(f)}.merge(data)) if f.end_with? 'pulse.yaml'
        end
      )
    end

    private

    # @param file_path [String]
    def id_from_file(file_path)
      file_path.gsub(/^#{Regexp.quote(File.join(@path, ''))}(.+)\.(query|pulse)\.yaml$/, '\1')
    end
  end
end