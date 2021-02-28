.PHONY: db clean-db build clean-build push-gem

db: docker/metabase/local.sqlite
clean-db:
	rm docker/metabase/local.sqlite

docker/metabase/local.sqlite: docker/metabase/fixture.sql
	cat docker/metabase/fixture.sql | sqlite3 docker/metabase/local.sqlite

build: release.gem
push-gem: build
	gem push release.gem
clean-build:
	rm release.gem

release.gem: metabase_query_sync.gemspec
	gem build metabase_query_sync.gemspec --output=release.gem