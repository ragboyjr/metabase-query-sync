require 'yaml'

class MetabaseQuerySync::QueryDef::ReadQueryDefs
  class FromFile < self
    # @param path [String]
    def initialize(path)
      @path = path
    end

    def call()
      Dir[File.join(@path, "**/*.yaml")].map do |f|
        QueryDef.from_h(YAML.load_file(f))
      end
    end
  end
end