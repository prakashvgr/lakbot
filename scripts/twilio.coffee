
env = process.env

HUBOT_TWILIO_SID = 'ACc9972b73feffc9b4be2dd33b1ded86aa'
HUBOT_TWILIO_TOKEN = 'a1fe075f96f884eeff6a8c704b979aa7'
HUBOT_TWILIO_NUMFROM = '+12565300135'

twilio = require('twilio')(HUBOT_TWILIO_SID, HUBOT_TWILIO_TOKEN)

#messagingServiceSid: 'MGe74ba951cb9f74dab83ed0d9df5b1ab8'

module.exports = (robot) ->
  robot.respond /(sendSMS|sendMMS) ?([+][0-9]{12}\b)? (.*)$/i, (msg) ->

    TwilioAPICall = msg.match[0]
    console.log TwilioAPICall
    if TwilioAPICall?
      return

    switch TwilioAPICall
      when "sendSMS"
        sendTo = msg.match[1]
        sendTo = if sendTo? then sendTo else '+919980505002'
        smsBody = msg.match[2]
        fnSendSMS(msg, sendTo, smsBody)
      when "sendMMS"
        fnSendMMS(msg)

  robot.respond /lastSMS/i, (msg) ->
    twilio.messages.list {}, (err, data) ->
      anArrSMS = data.messages
      lastItem = anArrSMS.pop()
      console.log "Last message sent to #{lastItem.to} with message - #{lastItem.body}"
      return

fnSendSMS = (msg, sendTo, smsBody) ->
  twilio.messages.create {
    to: "#{sendTo}"
    from: "#{HUBOT_TWILIO_NUMFROM}"
    body: "#{smsBody}"
  }, (err, body) ->
    if err
      console.log "Error :: #{err}"
      return
    res = JSON.parse(body)

    try
      if res.statusCode isnt 201
        console.log "Error :: status code: #{res.status} Message: #{res.message}"
        return
      if res.sid?
        console.log "SMS successfully send to #{res.to}."
        return
    catch err
      console.log "Twilio API failure response #{err}:"
