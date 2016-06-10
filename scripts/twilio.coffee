
env = process.env

HUBOT_TWILIO_SID = 'ACc9972b73feffc9b4be2dd33b1ded86aa'
HUBOT_TWILIO_TOKEN = 'a1fe075f96f884eeff6a8c704b979aa7'
HUBOT_TWILIO_NUMFROM = '+12565300135'
HUBOT_TWILIO_TWIML = 'http://demo.twilio.com/docs/voice.xml'

twilio = require('twilio')(HUBOT_TWILIO_SID, HUBOT_TWILIO_TOKEN)

module.exports = (robot) ->

  robot.respond /Check my last SMS/i, (msg) ->

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
    TwilioAPICall = msg.match[0]
    sendTo = msg.match[1]
    console.log sendTo
    if sendTo == undefined
      msg.send 'Opps!! Number OR Message is missing - sendSMS (+xxxxxxxxxxxx) Message'
      return
    smsBody = msg.match[2]
    fnSendSMS(msg, sendTo, smsBody)

fnSendSMS = (msg, sendTo, smsBody) ->
  twilio.messages.create {
    to: "#{sendTo}"
    from: "#{HUBOT_TWILIO_NUMFROM}"
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
    from: "#{HUBOT_TWILIO_NUMFROM}"
    url: "#{HUBOT_TWILIO_TWIML}"
  }, (err, call) ->
    try
      if call.sid != undefined
        msg.send "Call initiated successfully to #{call.to}"
        return
    catch err
      msg.send "Twilio API failure response #{err}:"
      return
