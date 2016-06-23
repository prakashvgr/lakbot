# Description:
#   Search for tweets on Twitter.
#
# Dependencies:
#   twitter installed
#
# Configuration:
#   HUBOT_TWITTER_CONSUMER_KEY
#   HUBOT_TWITTER_CONSUMER_SECRET
#   HUBOT_TWITTER_ACCESS_TOKEN
#   HUBOT_TWITTER_ACCESS_TOKEN_SECRET
#   HUBOT_TWITTER_MAX_COUNT
#
# Commands:
#   hubot twitter search <query> - Search all public tweets
#
# Author:
#  Prakash Rajendran (prakash.rajendran@capgemini.com)
#

Twitter = require('twitter');

env = process.env

env.HUBOT_TWITTER_CONSUMER_KEY = 'mlzz0sNxyFJjHAAUtVAAeLOlZ'
env.HUBOT_TWITTER_CONSUMER_SECRET = 'qYsr3MXfviyIPyWFg7UwA8Zi0vXI44HIFu4TU9ytlwBdpguc2a'
env.HUBOT_TWITTER_ACCESS_TOKEN = '1407288830-jyFItUnbV33PloIuGDKpGseiwUICSbVeQCMKGlS'
env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET = 'ZKRE0pDpBwlHJd387R2s3UDTdZBzc9lzmaQp0QrsXOwDt'
env.HUBOT_TWITTER_MAX_COUNT = '5'

twit = new Twitter({
  consumer_key: env.HUBOT_TWITTER_CONSUMER_KEY,
  consumer_secret: env.HUBOT_TWITTER_CONSUMER_SECRET,
  access_token_key: env.HUBOT_TWITTER_ACCESS_TOKEN,
  access_token_secret: env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET
});

doSearch = (msg) ->
  query = msg.match[1]
  console.log query
  return if !query

  count = env.HUBOT_TWITTER_MAX_COUNT
  searchConfig =
    q: "#{query}",
    count: count,
    lang: 'en',
    result_type: 'recent'

  twit.get 'search/tweets', searchConfig, (err, reply) ->
    console.log err
    return msg.send "Error retrieving tweets!" if err
    return msg.send "No results returned!" unless reply?.statuses?.length

    statuses = reply.statuses
    response = ''
    i = 0
    for status, i in statuses
      response += "**@#{status.user.screen_name}**: #{status.text}"
      response += "\n" if i != count-1

    return msg.send response

module.exports = (robot) ->
  robot.respond /twitter search (.*)$/i, (msg) ->
    unless env.HUBOT_TWITTER_CONSUMER_KEY
      msg.send "Please set the HUBOT_TWITTER_CONSUMER_KEY environment variable."
      return
    unless env.HUBOT_TWITTER_CONSUMER_SECRET
      msg.send "Please set the HUBOT_TWITTER_CONSUMER_SECRET environment variable."
      return
    unless env.HUBOT_TWITTER_ACCESS_TOKEN
      msg.send "Please set the HUBOT_TWITTER_ACCESS_TOKEN environment variable."
      return
    unless env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET
      msg.send "Please set the HUBOT_TWITTER_ACCESS_TOKEN_SECRET environment variable."
      return

    doSearch(msg)
