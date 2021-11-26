FROM ruby:3.0.2-buster

WORKDIR /app
RUN apt-get update -y
RUN apt-get install -y nodejs npm postgresql-client
RUN npm install -g yarn
ADD Gemfile .
ADD Gemfile.lock .
RUN bundle install
ADD . .
RUN yarn install # ホントは ADD . . の前にいい感じに実行できそう
RUN bundle exec rake assets:precompile

