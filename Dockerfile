FROM debian:unstable


RUN apt-get update \
    && apt-get install openssl -y\
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists/partial/*


ARG APP_HOME=/home/anyex


COPY _build/prod/rel/anyex $APP_HOME


WORKDIR $APP_HOME


ENV LANG=en_US.UTF-8
ENV PATH="$APP_HOME/bin:$PATH"

ENTRYPOINT [ "anyex", "console" ]