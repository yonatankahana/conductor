
# Running Conductor using Docker

In this article we will explore how you can set up Netflix Conductor on your local machine using Docker compose.
The docker compose will bring up the following:

1. Conductor API Server
2. Conductor UI
3. Elasticsearch
4. Redis

## Prerequisites

1. [Docker](https://docs.docker.com/get-docker/)
2. Recommended host with CPU and RAM to be able to run multiple docker containers (at-least 16GB RAM)

## Steps

### 1. Clone the Conductor Code

```console
git clone https://github.com/Netflix/conductor.git
```

### 2. Build the Docker Compose

```console
cd conductor/docker
docker-compose build
```

### 3. Run Docker Compose

```console
docker-compose up
```

Once up and running, you will see the following in your Docker dashboard:

1. Elasticsearch
2. Redis
3. Conductor Server
4. Conductor UI

You can access the UI & Server on your browser to verify that they are running correctly:

#### Conductor Server URL

- Server main page: [http://localhost:8080/](http://localhost:8080/)
- Swagger UI: [http://localhost:8080/swagger-ui/index.html](http://localhost:8080/swagger-ui/index.html)

<img src="/img/tutorial/swagger.png" style="width: 100%"/>

#### Conductor UI URL

[http://localhost/](http://localhost)

<img src="/img/tutorial/conductorUI.png" style="width: 100%" />

### 4. Exiting Compose

`Ctrl+C` will exit docker compose.

To ensure images are stopped execute: `docker-compose down`.

## Alternative Persistence Engines

By default `docker-compose.yaml` uses `config.properties`. This configures conductor to use Redis as database.

A selection of `docker-compose-*.yaml` and `config-*.properties` files are provided demonstrating the use of alternative persistence engines.

| File                           | Containers                                                                                                     |
|--------------------------------|----------------------------------------------------------------------------------------------------------------|
| docker-compose.yaml            | <ol><li>Server</li><li>Redis</li><li>Elasticsearch</li><li>UI</li></ol>                                        |
| docker-compose-postgresql.yaml | <ol><li>Server</li><li>Redis</li><li>Elasticsearch</li><li>UI</li><li>PostgreSQL persistence</li></ol>         |
| docker-compose-minimal.yaml    | <ol><li>Server</li><li>Redis</li></ol>                                                                         |
| docker-compose-prometheus.yaml | Brings up Prometheus server                                                                                    |

For example this will start the server instance backed by a PostgreSQL DB.

```console
docker-compose -f docker-compose-postgres.yaml up
```

- Note: Switching between persistence engines may require to reset docker storage volumes (CAREFUL: it will remove all your data): `docker compose -f docker-compose.yaml -f docker-compose-postgresql.yaml down -v`.

## Monitoring with Prometheus

TODO: add information about required implementation reqired and another -f flag required

Start Prometheus with:
`docker-compose -f docker-compose-prometheus.yaml up -d`

Go to [http://127.0.0.1:9090](http://127.0.0.1:9090).

## Potential problem when using Docker Images

### Not enough memory

You will need at least ~3 GB of memory to run the default `docker-compose.yaml`. You can use `docker-compose-minimal.yaml` instead, to run Conductor without Elasticsearch and UI. The minimal compose require ~1GB of memory.

### Elasticsearch remains in yellow health state

When you run Elasticsearch, sometimes the health remains in the *yellow* state. Conductor server by default requires
*green* state to run when indexing is enabled. To work around this, you can use the following property: `conductor.elasticsearch.clusterHealthColor=yellow`.

Reference: [Issue 2262][issue2262]

### Elasticsearch timeout

By default, a standalone (single node) Elasticsearch has a *yellow* status which will cause timeout (`java.net.SocketTimeoutException`) for Conductor server (required status is *green*).
Spin up a cluster (more than one node) to prevent the timeout or use config option `conductor.elasticsearch.clusterHealthColor=yellow`.

Reference: [Issue 2262][issue2262]

### To troubleshoot a failed startup

Check the log of the server, using `docker logs docker_server_1`.

### Unable to access to conductor server API on port 8080

It may takes some time for conductor server to start. Please check server log for potential error.

### How to disable Elasticsearch

By default, docker-compose will start conductor with Elasticsearch enabled. If you don't want to use Elasticsearch, you can start the minimal docker-compose file: `docker-compose-minimal.yaml`, i.e:

```console
docker-compose -f docker-compose-minimal.yaml up
```

[issue2262]: https://github.com/Netflix/conductor/issues/2262
