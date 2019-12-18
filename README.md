# README

The tech stack:

* Ruby 2.6.3
* Rails 5.2.4
* SQLite (not used)
* Redis
* Twitter API
* ActionCable (for websocket)
* Needs JDK to run the Stanford NLP library (MacOS download link: https://support.apple.com/kb/DL1572?locale=en_US)

## Starting instructions

* Start a Redis server in localhost `redis-server`
* Clone the Repo to a local directory `git clone https://github.com/sajan45/twitter_live_dashboard`. Please be patient as the repo is heavy due to NLP models.
* Run `cd twitter-live-dashboard`
* Run `rails server`

## Usage Instructions
* Open **http://localhost:3000/tweets/?source=%40timesofindia** for live stream of tweets of a user (timesofindia in this case)
* Open **http://localhost:3000/tweets/?source=%23SavdhaanIndia** to live stream tweets on a hashtag
* Open **http://localhost:3000/word-cloud** for a word-cloud of words from tweets related to Byjus
* Open **http://localhost:3000/sentiment** for sentiment analysis chart

## Architecture

The project uses Websocket connections to stream tweets to the browser. Every request to /tweets page opens a websocket connection and subscribes the user to a particular topic (either a user or a hashtag). During subscription, the server checks whether there are any other users who are also subscribed to the same topic. If there are no other users subscribed to the same topic, then the Channel starts a **Worker** which runs in s separate **thread** and keeps listening for new tweets on the given topic, using Twitter's stream API.  When there is a new tweet, it broadcasts that to all clients who are subscribed to that topic.

The server uses Server-Sent Events (SSE) for live streaming on REST API. It is not the best approach for a blocking server, as every request will block a thread or process causing resource exhaustion. A better approached would be using some event-based servers like the 'eventmachine' or some other way that works in a non-blocking way.

It uses Redis to store connection count related data.
