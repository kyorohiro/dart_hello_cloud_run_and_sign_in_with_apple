FROM google/dart:2.8-dev

WORKDIR /app
COPY . /app

RUN pub get
CMD [ "dart", "/app/bin/server.dart"]
