# Description:
#   Create hangouts with Hubot.
#
# Commands:
#   hubot hangout me - Response with Hangout URL.
#
# Configuration:
#   None

module.exports = (robot) ->
  robot.respond /hangouts me/i, (msg) ->
    msg.send "I've started a Hangout! Join here: https://g.co/hangouts"
