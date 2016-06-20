# Description:
# Allows Hubot to use blumix sentiment service for cognitive processing.
#
# Dependencies:
# watson-developer-cloud installed
#
# Configuration:
# IBM_BLUEMIX_SENTIMENT_KEY
#
# Commands:
# hubot AIE lab <comment>
#
#
env = process.env
watson = require('watson-developer-cloud')
data = {}
sentiment = (err, result, cb, msg) ->
    alchemy_language = watson.alchemy_language ({api_key:env.IBM_BLUEMIX_SENTIMENT_KEY})
    alchemy_language.sentiment result.msg , (err,response) ->
        if err
            
            msg.send 'Ooops! I am facing some issue in analysing this feedback. It will be good if you change it a bit and try again.'
            return
        else  
            
            sentiment_type = response.docSentiment.type
            switch sentiment_type
                when 'positive' then msg.send 'Thanks for your encouraging feedback.'
                when 'negative' then msg.send 'Thanks for your feedback. We will try to improve further.'
                when 'neutral' then msg.send  'Thanks for your feedback.'

module.exports = (robot) ->
    robot.hear /(Aiemee AIE lab) (.*)/i, (msg) ->
        matches = msg.match
        txt = matches[2] or ''
        
        params = { text: txt }
        data.msg = params
        sentiment(null, data, null, msg)
        