FROM ruby:slim
RUN apt update \
    && apt install -y curl \
    && apt clean
RUN mkdir /app
COPY http_server/http_server.rb /app/http_server.rb
RUN useradd rb
USER rb
CMD ["ruby", "/app/http_server.rb"]
