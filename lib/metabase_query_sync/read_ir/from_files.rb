require 'logger'
require 'yaml'

class MetabaseQuerySync::ReadIR
  class FromFiles < self
    def initialize(path, logger = nil)
      @paths = path.is_a?(Array) ? path : [path]
      @logger = logger || Logger.new(IO::NULL)

      raise 'Paths must not be empty when reading from files' if @paths.empty?
    end

    def call
      MetabaseQuerySync::IR::Graph.from_items(
        @paths.flat_map { |p| ir_items_from_path(p) }
      )
    end

    private

    # @param path [String]
    def ir_items_from_path(path)
      (scope, path) = split_path(path)
      @logger.info "Reading IR Items from path (#{path}) and scope (#{scope})"

      # @type [String] f
      Dir[File.join(path, "**/*.{query,pulse}.yaml")].map do |f|
        data = YAML.load_file(f)
        next MetabaseQuerySync::IR::Query.from_h(prefix_id(scope, {"id" => id_from_file(path, f)}.merge(data))) if f.end_with? 'query.yaml'
        next MetabaseQuerySync::IR::Pulse.from_h(prefix_id(scope, {"id" => id_from_file(path, f)}.merge(data))) if f.end_with? 'pulse.yaml'
      end
    end

    # @param path [String]
    def split_path(path)
      path.include?(':') ? path.split(':', 2) : [nil, path]
    end

    # @param file_path [String]
    def id_from_file(base_path, file_path)
      file_path.gsub(/^#{Regexp.quote(File.join(base_path, ''))}(.+)\.(query|pulse)\.yaml$/, '\1')
    end

    # @param attributes [Hash]
    def prefix_id(scope, attributes)
      return attributes unless scope
      attributes.merge({"id" => File.join(scope, attributes["id"])})
    end
  end
end