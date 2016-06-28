# Description:
#   Get instagram images by hash tag
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_INSTAGRAM_CLIENT_KEY
#   HUBOT_INSTAGRAM_ACCESS_KEY
#
# Commands:
#   hubot insta tag <tag> - Show recent instagram tags
#
# Author:
#  Prakash Rajendran (prakash.rajendran@capgemini.com)
#

env = process.env

INSTAGRAM_API_URL = 'https://api.instagram.com/v1/tags/'

module.exports = (robot) ->
  robot.respond /(insta tag)?(.*)/i, (msg) ->

    if msg.match[2]
      text = msg.match[2].trim().split(" ")
      tag =  text[0]
    else
      msg.send 'Please provied tag'
      return

    unless env.HUBOT_INSTAGRAM_CLIENT_KEY
      msg.send "Please set the HUBOT_INSTAGRAM_CLIENT_KEY environment variable."
      return
    unless env.HUBOT_INSTAGRAM_CLIENT_SECRET
      msg.send "Please set the HUBOT_INSTAGRAM_CLIENT_SECRET environment variable."
      return
    unless env.HUBOT_INSTAGRAM_ACCESS_TOKEN
      msg.send "Please set the HUBOT_INSTAGRAM_ACCESS_TOKEN environment variable."
      return

    fnSearchTag(msg, tag)

fnSearchTag = (msg, paramTag) ->
  msg.http(INSTAGRAM_API_URL + paramTag + '/media/recent')
    .query(access_token: env.HUBOT_INSTAGRAM_ACCESS_TOKEN, count: env.HUBOT_INSTAGRAM_RESPONSE_COUNT)
    .get() (err, res, body) ->
      try
        console.log body
        console.log res
        console.log err

        body = JSON.parse body
        medias = body.data
        if items.length > 0
          for media in medias
            msg.seng '@'+media.caption.from.full_name + '-- :' + media.caption.text
            #msg.send media.caption.text
            msg.send media.images.standard_resolution.url
        else
          msg.send "Oops, no media for this #{paramTag}"
      catch err
        msg.send "Unable to search with tag #{paramTag}, #{err}"
