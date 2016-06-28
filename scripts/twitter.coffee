# Description:
#   Search for recent tweets on Twitter.
#
# Dependencies:
#   twitter installed
#
# Configuration:
#   TWITTER_CONSUMER_KEY
#   TWITTER_CONSUMER_SECRET
#   TWITTER_ACCESS_TOKEN_KEY
#   TWITTER_ACCESS_TOKEN_SECRET
#   TWITTER_RESPONSE_COUNT
#
# Commands:
#   hubot twitter search <hashtag> - Search public tweets. <query> - #AIE #Capgemini
#
# Author:
#  Prakash Rajendran (prakash.rajendran@capgemini.com)
#

Twitter = require('twitter');

env = process.env

twit = new Twitter({
  consumer_key: env.TWITTER_CONSUMER_KEY,
  consumer_secret: env.TWITTER_CONSUMER_SECRET,
  access_token_key: env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: env.TWITTER_ACCESS_TOKEN_SECRET
});

doSearch = (msg) ->
  #query = msg.match[1]
  query = msg.match[1].replace(' #','+#')
  return if !query

  count = env.TWITTER_RESPONSE_COUNT
  searchConfig =
    q: "#{query}",
    count: count,
    lang: 'en',
    result_type: 'recent'

  twit.get 'search/tweets', searchConfig, (err, reply) ->
    return msg.send "Error retrieving tweets!" if err
    return msg.send "No results returned!" unless reply?.statuses?.length

    statuses = reply.statuses
    response = ''
    i = 0
    for status, i in statuses

      msg.send "@#{status.user.screen_name} -- : #{status.text}"
      if status.entities.media != undefined
        media_url = "\n"+status.entities.media[0].media_url
        msg.send "#{media_url}"
      msg.send "\n" if i != count-1

module.exports = (robot) ->
  robot.respond /twitter search (.*)$/i, (msg) ->
    unless env.TWITTER_CONSUMER_KEY
      msg.send "Please set the TWITTER_CONSUMER_KEY environment variable."
      return
    unless env.TWITTER_CONSUMER_SECRET
      msg.send "Please set the TWITTER_CONSUMER_SECRET environment variable."
      return
    unless env.TWITTER_ACCESS_TOKEN_KEY
      msg.send "Please set the TWITTER_ACCESS_TOKEN_KEY environment variable."
      return
    unless env.TWITTER_ACCESS_TOKEN_SECRET
      msg.send "Please set the TWITTER_ACCESS_TOKEN_SECRET environment variable."
      return

    doSearch(msg)
