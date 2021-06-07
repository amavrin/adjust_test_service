FROM ruby:slim
RUN mkdir /app
COPY http_server/http_server.rb /app/http_server.rb
CMD ["ruby", "/app/http_server.rb"]
