require "bundler/setup"
require "metabase_query_sync"

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

QueryDef = MetabaseQuerySync::QueryDef
MetabaseApi = MetabaseQuerySync::MetabaseApi
IR = MetabaseQuerySync::IR