require 'dry-schema'
require 'yaml'
require 'erb'

module MetabaseQuerySync
  class Config
    attr_reader :credentials, :paths

    # @param credentials [MetabaseQuerySync::MetabaseCredentials]
    # @param paths [Array<String>]
    def initialize(credentials:, paths:)
      @credentials = credentials
      @paths = paths
    end

    def self.from_file(path, paths: [], host: nil, user: nil, pass: nil)
      if File.exists? path
        data = YAML.load(ERB.new(File.read(path)).result)
        result = Dry::Schema.JSON do
          required(:paths).value(array[:string], min_size?: 1)
          required(:credentials).hash do
            required(:host).filled(:string)
            required(:user).filled(:string)
            required(:pass).filled(:string)
          end
        end.(data)
        raise "Invalid data provided in config file: #{result.errors.to_h}" if result.failure?
      end
      new(
        credentials: MetabaseCredentials.new(
          host: host || data["credentials"]["host"],
          user: user || data["credentials"]["user"],
          pass: pass || data["credentials"]["pass"]
        ),
        paths: paths.empty? ? data["paths"] : paths
      )
    end
  end
end