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
      argument :path, type: :string, required: true, desc: 'The path to metabase item files to sync from.'
      option :dry_run, type: :boolean, default: false, aliases: ['-d'], desc: 'Perform a dry run and do not actually sync to the metabase instance.'
      option :host, type: :string, aliases: ['-h'], desc: 'Metabase Host'
      option :user, type: :string, aliases: ['-u'], desc: 'Metabase User'
      option :pass, type: :string, aliases: ['-p'], desc: 'Metabase Password'

      def call(root_collection_id:, path:, dry_run: false, host: nil, user: nil, pass: nil)
        config = MetabaseQuerySync::Config.new(
          credentials: MetabaseQuerySync::MetabaseCredentials.from_env(host: host, user: user, pass: pass),
          path: path,
        )
        sync = MetabaseQuerySync::Sync.from_config(config, Logger.new(STDOUT))
        sync.(MetabaseQuerySync::SyncRequest.new(root_collection_id: root_collection_id.to_i, dry_run: dry_run))
      end
    end

    register "version", Version, aliases: ['v', '-v', '--version']
    register "sync", Sync, aliases: ['s']
  end
end