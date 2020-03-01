FROM google/dart:2.8-dev

WORKDIR /app
COPY . /app
ENV BASE_ADDR=https://helloworld-yduxpidi4a-an.a.run.app
ENV PORT=8080
RUN pub get
CMD [ "dart", "/app/bin/server.dart"]
