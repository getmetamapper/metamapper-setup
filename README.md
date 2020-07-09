# Metamapper Setup

[![CircleCI](https://circleci.com/gh/getmetamapper/metamapper-setup.svg?style=shield)](https://circleci.com/gh/getmetamapper/metamapper-setup) [![latest version](https://img.shields.io/docker/v/metamapper/metamapper?sort=semver)](https://hub.docker.com/r/metamapper/metamapper) [![discord](https://img.shields.io/discord/713821768237973535)](http://discuss.metamapper.io)

Official bootstrap for spinning up your own Metamapper instance with Docker and Docker-Compose.

## Setup

To get started, we recommend you fork this repo and run the following command:

```bash
./setup.sh
```

Once the bootstrap has completed, you should be able to run:

```bash
docker-compose up -d
```

Then you can access the web UI from whatever port (default: 5050) is specified in your `gunicorn.py` configuration.

## Environment Variables

### `METAMAPPER_IMAGE` (default: `metamapper/metamapper`)

We publish to two separate Docker Hub repositories during our build process.

#### `metamapper/metamapper`

Stable builds are published as [point releases](https://semver.org/) to [metamapper/metamapper](https://hub.docker.com/r/metamapper/metamapper). **We recommend this as your starting point when deploying your own Metamapper instance.**

You can specify what image of Metamapper you want to install with the `METAMAPPER_IMAGE` variable.

```bash
METAMAPPER_IMAGE=metamapper/metamapper METAMAPPER_VERSION=latest ./setup.sh
```

#### `metamapper/preview`

We also maintain a development image at [metamapper/preview](https://hub.docker.com/r/metamapper/preview). These builds contain the latest – but potentially unstable – features available. Use this if you want to be on the bleeding edge and help us debug our codebase before an official release.

Preview releases are tagged with the first 7 characters of the last commit hash.

### `METAMAPPER_VERSION` (default: `latest`)

You can specify what version of Metamapper you want to install with the `METAMAPPER_VERSION` variable:

```bash
METAMAPPER_IMAGE=metamapper/preview METAMAPPER_VERSION=35b182c ./setup.sh
```

## Configuring Metamapper

### The `conf` module

We offer some configuration files to some of the libraries that Metamapper uses to function. These files are generated and placed in the [conf](metamapper/conf) directory as part of [setup.sh](setup.sh) script.

#### gunicorn.py

Metamapper uses [gunicorn](https://docs.gunicorn.org/en/stable/index.html) to serve web requests. You can customize any aspect of Gunicorn via the `gunicorn.py` [configuration](https://docs.gunicorn.org/en/stable/configure.html) file.

#### celery.py

Metamapper uses [celery](https://docs.celeryproject.org/en/stable/index.html) to handle async task processing. You can customize the Celery configuration via the `celery.py` [configuration](https://docs.celeryproject.org/en/stable/userguide/configuration.html) file.

#### settings.py

Metamapper is a Django application. Much of the configuration is done in the [django.conf.settings](https://github.com/metamapper-io/metamapper/blob/master/metamapper/settings.py) module.

You can override any setting in this file using the `settings.py` file generated during the installation process. However, do this with extreme caution, as it could break your build.

### The `contrib` module

Code that is added into this module is added directly into the Metamapper source code on your Docker image. This means that it is accessible by different parts of the application.

For example, Metamapper uses [full text search](https://www.postgresql.org/docs/9.6/textsearch.html) capabilities provided natively in Postgres. This decision was made to reduce the number of components users have to install to get Metamapper up and running – e.g., most people aren't going to need a full-fledge Elasticsearch cluster for their data.

You could, however, roll out your own Elasticsearch (or Solr or whatever) backend, place it in the `contrib` module, and update the reference to that module using the `METAMAPPER_SEARCH_BACKEND` environment variable. Regardless of what happens behind the scenes, it should work as expected as long as the backend exposes the same abstract interface.

We currently expose the following backends as configurable:

| Environment Variable | Description |
| -------------------- | ----------- |
| `METAMAPPER_SEARCH_BACKEND` | Handles searching data assets, such as tables, and their annotations |
| `METAMAPPER_FILE_STORAGE_BACKEND` | Handles file uploads to different cloud providers |
| `METAMAPPER_EMAIL_BACKEND` | Handles email notification deliveries |


### `requirements.txt`

We provide an empty [requirements.txt](metamapper/requirements.txt) that you can update with an dependencies that your `contrib` module needs. It is automatically installed via `pip` at the end of the Docker build process:

```docker
RUN if [ -s /usr/local/metamapper/metamapper/requirements.txt ]; \
    then pip install -r /usr/local/metamapper/metamapper/requirements.txt; fi
```

## Resources

- [Issue Tracker](https://github.com/metamapper-io/metamapper-setup/issues)
- [Code](https://github.com/metamapper-io/metamapper)
