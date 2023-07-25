# https://elixirforum.com/t/elixir-phoenix-running-a-dev-setup-inside-docker/43269
FROM elixir:latest

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y postgresql-client && \
    apt-get install -y inotify-tools

# https://stackoverflow.com/a/57546198
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
# https://stackoverflow.com/a/41792420
ARG NODE_VERSION
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"


RUN mix local.hex --force && \
    mix archive.install hex phx_new --force && \
    mix local.rebar --force

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME