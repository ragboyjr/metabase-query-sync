require 'dry/cli'

module MetabaseQuerySync
  class CLI
    extend Dry::CLI::Registry

    class Version < Dry::CLI::Command
      def call
        puts VERSION
      end
    end

    class Sync < Dry::CLI::Command
      desc 'Sync queries/pulses to your metabase root collection'

      argument :root_collection_id, type: :integer, required: true, desc: 'The root collection id to sync all items under.'
      argument :paths, type: :array, required: true, desc: 'The paths to metabase item files to sync from. Support for scoped paths with custom_name:/path/to/folder is supported as well to ensure each imported item is scoped with custom_name.'
      option :dry_run, type: :boolean, default: false, aliases: ['-d'], desc: 'Perform a dry run and do not actually sync to the metabase instance.'
      option :host, type: :string, aliases: ['-H'], desc: 'Metabase Host, if not set, will read from env at METABASE_QUERY_SYNC_HOST'
      option :user, type: :string, aliases: ['-u'], desc: 'Metabase User, if not set, will read from env at METABASE_QUERY_SYNC_USER'
      option :pass, type: :string, aliases: ['-p'], desc: 'Metabase Password, if not set, will read from env at METABASE_QUERY_SYNC_PASS'

      def call(root_collection_id:, paths:, dry_run: false, host: nil, user: nil, pass: nil, **)
        config = MetabaseQuerySync::Config.new(
          credentials: MetabaseQuerySync::MetabaseCredentials.from_env(host: host, user: user, pass: pass),
          paths: paths,
        )
        sync = MetabaseQuerySync::Sync.from_config(config, Logger.new(STDOUT))
        sync.(MetabaseQuerySync::SyncRequest.new(root_collection_id: root_collection_id.to_i, dry_run: dry_run))
      end
    end

    register "version", Version, aliases: ['v', '-v', '--version']
    register "sync", Sync, aliases: ['s']
  end
end