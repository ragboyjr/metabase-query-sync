require "bundler/setup"
require "metabase_query_sync"
require 'simplecov'
require_relative 'file_fixtures'
require_relative 'ir_factory'
require_relative 'ir_steps'
require_relative 'metabase_api_factory'
require_relative 'metabase_api_steps'

SimpleCov.start do
  add_filter '_spec.rb'
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # allow focusing on tests
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

MetabaseApi = MetabaseQuerySync::MetabaseApi
IR = MetabaseQuerySync::IR

def given_the_following_env_is_set(env)
  ENV.update(env)
end