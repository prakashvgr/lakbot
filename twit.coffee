# Description:
#   Search for tweets on Twitter.
#
# Dependencies:
#   "twit": "1.1.x"
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

Twit = require "twit"
env = process.env

config =
  consumer_key: env.HUBOT_TWITTER_CONSUMER_KEY
  consumer_secret: env.HUBOT_TWITTER_CONSUMER_SECRET
  access_token: env.HUBOT_TWITTER_ACCESS_TOKEN
  access_token_secret: env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET

twit = undefined

getTwit = ->
  unless twit
    twit = new Twit config
  return twit

doSearch = (msg) ->
  query = msg.match[1]
  console.log query
  return if !query

  twit = getTwit()
  count = env.HUBOT_TWITTER_MAX_COUNT
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
      response += "**@#{status.user.screen_name}**: #{status.text}"
      response += "\n" if i != count-1

    return msg.send response

module.exports = (robot) ->
  robot.respond /twitter search (.*)$/i, (msg) ->
    unless config.consumer_key
      msg.send "Please set the HUBOT_TWITTER_CONSUMER_KEY environment variable."
      return
    unless config.consumer_secret
      msg.send "Please set the HUBOT_TWITTER_CONSUMER_SECRET environment variable."
      return
    unless config.access_token
      msg.send "Please set the HUBOT_TWITTER_ACCESS_TOKEN environment variable."
      return
    unless config.access_token_secret
      msg.send "Please set the HUBOT_TWITTER_ACCESS_TOKEN_SECRET environment variable."
      return

    doSearch(msg)
