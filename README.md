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

TKTK

## Development

- Install gems with `bundle install`
- Run tests with `bundle exec rspec`

## Debugging with Metabase

To setup the local data source for metabase, run `make db`.

Starting the metabase docker container should automatically initialize an empty metabase installation with the main admin user account (ragboyjr@icloud.com / password123).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ragboyjr/metabase-query-sync. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ragboyjr/metabase-query-sync/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Metabase::Query::Sync project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ragboyjr/metabase-query-sync/blob/master/CODE_OF_CONDUCT.md).
