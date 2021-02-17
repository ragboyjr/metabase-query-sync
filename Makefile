.PHONY: db clean-db

db: docker/metabase/local.sqlite
clean-db:
	rm docker/metabase/local.sqlite

docker/metabase/local.sqlite: docker/metabase/fixture.sql
	cat docker/metabase/fixture.sql | sqlite3 docker/metabase/local.sqlite