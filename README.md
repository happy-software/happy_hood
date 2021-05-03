# HappyHood

Make your entire neighborhood happy.

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
