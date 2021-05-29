# HappyHood

Make your entire neighborhood happy.

# Onboarding a new neighborhood

This process requires two steps. Generating a CSV, and then ingesting it.

Run the following to generate a csv template:

```shell
bundle exec rails neighborhood:generate_onboarding_csv

# Creates <TIMESTAMP>_onboard_neighborhood.csv file
```

Fill out the template with the neighborhood and houses you want to include. Each
neighborhood entry will be deduplicated, so you will have several rows with
identical columns. For example, refer to `spec/fixtures/nonempty_onboarding_neighborhood.csv`.

Once the template is filled out, you can ingest it by running:

```shell
bundle exec rails neighborhood:upload[path/to/csv]
```

## Development

### Docker

You can use [dip](https://github.com/bibendi/dip) (a [docker-compose](https://docs.docker.com/compose/compose-file/) interface) to run the application.

```shell
# start a shell in the `app` service (see docker-compose.yml for other services)
dip bash

# Run rake in the `app` service
dip rake

# Run rails in the `app` service
dip rails

# Run rspec in the `app` service
dip rspec

# Run a psql console on the `postgres` service
dip psql
```

#### Rebuilding a container

```shell
docker-compose build
```
