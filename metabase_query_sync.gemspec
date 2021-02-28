require_relative 'lib/metabase_query_sync/version'

# @type [Gem::Specification] spec
Gem::Specification.new do |spec|
  spec.add_dependency "zeitwerk", '~> 2.4'
  spec.add_dependency "dry-schema", '~> 1.5'
  spec.add_dependency "dry-struct", '~> 1.4'
  spec.add_dependency "dry-monads", '~> 1.3'
  spec.add_dependency "faraday", "~> 1.0"
  spec.add_dependency "faraday_middleware", "~> 1.0"
  spec.add_dependency "dry-cli", "~> 0.6"

  spec.required_ruby_version = "~> 2.7"

  spec.name          = "metabase_query_sync"
  spec.version       = MetabaseQuerySync::VERSION
  spec.authors       = ["RJ Garcia"]
  spec.email         = ["ragboyjr@icloud.com"]

  spec.summary       = 'MetabaseQuerySync is a tool for automatically syncing metabase queries defined in files to a specific metabase installation.'
  spec.homepage      = "https://github.com/ragboyjr/metabase-query-sync"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  #spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir["README.md", "LICENSE.txt", "lib/**/*.rb"].filter { |f| !f.end_with?('_spec.rb') }
  spec.bindir        = "bin"
  spec.executables   = ['metabase-query-sync']
  spec.require_paths = ["lib"]
end