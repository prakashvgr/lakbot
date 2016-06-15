# Description:
#   It will allow you to send SMS and Automated Voice Call.
#
# Configurations:
#   HUBOT_TWILIO_SID
#   HUBOT_TWILIO_TOKEN
#   HUBOT_TWILIO_NUMFROM
#   HUBOT_TWILIO_TWIML
#
# Commands:
#   hubot check my last sms - Response with last sms.
#   hubot sendSMS (+xxxxxxxxxxxx) <Message> - Send an SMS to provided "+2<country code>10<mobile number>" digit number .
#   hubot CallTo (+xxxxxxxxxxxx) - Make a Call to provided "+2<country code>10<mobile number>" digit number.
#
# Author:
#   Prakash Rajendran (prakash.rajendran@capgemini.com)
#

env = process.env

sid = env.HUBOT_TWILIO_SID or 'ACc9972b73feffc9b4be2dd33b1ded86aa'
token = env.HUBOT_TWILIO_TOKEN or 'a1fe075f96f884eeff6a8c704b979aa7'
from = env.HUBOT_TWILIO_NUMFROM or '+12565300135'
twiml = env.HUBOT_TWILIO_TWIML or 'http://demo.twilio.com/docs/voice.xml'

twilio = require('twilio')(sid, token)

module.exports = (robot) ->

  robot.respond /Check my last SMS/i, (msg) ->

    console.log from
    twilio.messages.list {}, (err, data) ->
      anArrSMS = data.messages
      if anArrSMS.length < 0
        msg.send 'Checked! No SMS sent, try new SMS - sendSMS (+xxxxxxxxxxxx)'
        return
      lastItem = anArrSMS[0]
      msg.send "Last message sent to #{lastItem.to} with message - #{lastItem.body}"
      return

  robot.respond /CallTo ?([+][0-9]{12}\b)?/i, (msg) ->
    callTo = msg.match[1]
    if callTo == undefined
      msg.send 'Opps!! number is missing (+xxxxxxxxxxxx)'
      return
    fnMakeCall(msg, callTo)

  robot.respond /sendSMS ?([+][0-9]{12}\b)? (.*)$/i, (msg) ->
    sendTo = msg.match[1]
    if sendTo == undefined
      msg.send 'Opps!! Number/Message is missing - sendSMS (+xxxxxxxxxxxx) Message'
      return
    smsBody = msg.match[2]
    fnSendSMS(msg, sendTo, smsBody)

fnSendSMS = (msg, sendTo, smsBody) ->
  twilio.messages.create {
    to: "#{sendTo}"
    from: "#{from}"
    body: "#{smsBody}"
  }, (err, message) ->
    try
      if message.sid != undefined
        msg.send "SMS successfully send to #{message.to}"
        return
    catch err
      msg.send "Twilio API failure response #{err}:"

fnMakeCall = (msg, callTo) ->
  twilio.calls.create {
    to: "#{callTo}"
    from: "#{from}"
    url: "#{twiml}"
  }, (err, call) ->
    try
      if call.sid != undefined
        msg.send "Call initiated successfully to #{call.to}"
        return
    catch err
      msg.send "Twilio API failure response #{err}:"
      return
