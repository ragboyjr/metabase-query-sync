# MetabaseQuerySync

MetabaseQuerySync is a tool for automatically syncing metabase queries defined in files to a specific metabase installation.

This enables metabase queries to be maintained with the relevant source code to ease refactoring of models in your application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metabase_query_sync'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install metabase-query-sync

## Usage

Build files with `.query.yaml` or `.pulse.yaml` suffix and sync those files up to your metabase instance.

### Files Definitions

```yaml
# in low-volume-orders.query.yaml
name: Low Volume Orders
sql: 'select * from orders'
database: Local DB # must match name of database in metabase
pulse: Hourly # must match local pulse name field, throws exception if no pulse is found with that name
```

```yaml
# in hourly.pulse.yaml
name: Hourly
alerts:
  - type: email # can be one of slack/email
    email:
      emails: ['ragboyjr@icloud.com']
    # or instead
    #slack:
    #  channel: '#test-channel'
    schedule:
      type: hourly # can be one of hourly, daily, weekly
      hour: 5 # number from 0-23, only needed if daily or weekly
      day: mon # first 3 character of day only needed if weekly
```

### Running the Sync

Then using the metabase-query-sync cli tool, you can sync those files directly into metabase:

```bash
Command:
  metabase-query-sync sync

Usage:
  metabase-query-sync sync ROOT_COLLECTION_ID PATH

Description:
  Sync queries/pulses to your metabase root collection

Arguments:
  ROOT_COLLECTION_ID  	# REQUIRED The root collection id to sync all items under.
  PATH                	# REQUIRED The path to metabase item files to sync from.

Options:
  --[no-]dry-run, -d              	# Perform a dry run and do not actually sync to the metabase instance., default: false
  --host=VALUE, -H VALUE          	# Metabase Host, if not set, will read from env at METABASE_QUERY_SYNC_HOST
  --user=VALUE, -u VALUE          	# Metabase User, if not set, will read from env at METABASE_QUERY_SYNC_USER
  --pass=VALUE, -p VALUE          	# Metabase Password, if not set, will read from env at METABASE_QUERY_SYNC_PASS
  --help, -h                      	# Print this help
```

## Development

- Install gems with `bundle install`
- Run tests with `bundle exec rspec`

### TODO

- Support Collections and Syncing with collections
- Matching IR vs MetabaseApi items should go off of the file name + collection id instead of just the name

## Debugging with Metabase

To setup the local data source for metabase, run `make db`.

Starting the metabase docker container should automatically initialize an empty metabase installation with the main admin user account (ragboyjr@icloud.com / password123).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ragboyjr/metabase-query-sync. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ragboyjr/metabase-query-sync/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Metabase::Query::Sync project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ragboyjr/metabase-query-sync/blob/master/CODE_OF_CONDUCT.md).
