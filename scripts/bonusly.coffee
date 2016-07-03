# Description:
#   Allows users to give 'micro-bonuses' on bonusly 
#
# Dependencies:
#   None
#
# Configuration:
#   BONUSLY_ADMIN_API_TOKEN
#
# Commands:
#   hubot bonusly help - gives a available hashtag with sample bonus command
#   hubot bonusly give <amount> to <name|email> for <reason> <#hashtag> - gives a micro-bonus to the specified user
#   hubot bonusly bonuses - lists recent micro-bonuses
#   hubot bonusly leaderboard <giver|receiver> -  show leaderboard for giving or receiving
#   hubot bonusly hashtag count -  show hashtag with count
#
# Author:
#   Prakash Rajendran (prakash.rajendran@capgemini.com)
#

env = process.env

module.exports = (robot) ->
  token = env.BONUSLY_ADMIN_API_TOKEN
  adapter = robot.adapterName
  client = "hubot-#{robot.adapterName}"
  service = 'https://bonus.ly'
  bad_token_message = 'The Bonusly API token is not set. Navigate to https://bonus.ly/api as an _admin_ user (important), grab the access token and set the BONUSLY_ADMIN_API_TOKEN environment variable.'

  robot.respond /(bonusly)? help/i, (msg) ->
    return msg.send bad_token_message unless token
    msg.send "o.k. find the sample one with available hashtags ..."
    path="/api/v1/companies/show?access_token=#{token}&limit=10"
    msg.http(service)
      .path(path)
      .get() (err, res, body) ->
        data = JSON.parse body
        msg.send data.result.example_reason
        msg.send 'Suggested Hashtag : '+ data.result.suggested_hashtags
        msg.send 'Suggested Amount : ' + data.result.give_amounts
		
  robot.respond /(bonusly)? bonuses/i, (msg) ->
    return msg.send bad_token_message unless token
    msg.send "o.k. I'm grabbing recent bonuses ..."
    path="/api/v1/bonuses?access_token=#{token}&limit=10"
    msg.http(service)
      .path(path)
      .get() (err, res, body) ->
        switch res.statusCode
          when 200
            data = JSON.parse body
            bonuses = data.result
            bonuses_text = ("From #{bonus.giver.short_name} to #{bonus.receiver.short_name} #{bonus.reason}" for bonus in bonuses).join('\n')
            msg.send bonuses_text
          when 400
            data = JSON.parse body
            msg.send data.message
          else
            msg.send "Request (#{service}#{path}) failed (#{res.statusCode})."

  robot.respond /(bonusly)? ?leaderboard ?(giver|receiver)?/i, (msg) ->
    return msg.send bad_token_message unless token
    type_str = msg.match[2]
    type = if (type_str? && type_str == 'giver') then 'giver' else 'receiver'
    path="/api/v1/analytics/standouts?access_token=#{token}&role=#{type}&limit=10"
    msg.send "o.k. I'll pull up the top #{type}s for you ..."
    msg.http(service)
      .path(path)
      .get() (err, res, body) ->
        switch res.statusCode
          when 200
            leaders = JSON.parse(body).result
            leaders_text = ("##{index+1} with #{leader.count} bonuses: #{leader.user.first_name} #{leader.user.last_name}" for leader, index in leaders).join('\n')
            msg.send leaders_text
          when 400
            data = JSON.parse body
            msg.send data.message
          else
            msg.send "Request (#{service}#{path}) failed (#{res.statusCode})."

  robot.respond /bonusly hashtag count/i, (msg) ->
    return msg.send bad_token_message unless token
    chartAPI = 'http://www.chartgo.com/preview.do?'
    hashTagName = ''
    hashTagCount = ''
    chartAPIPram = 'charttype=pie&width=600&height=500&chrtbkgndcolor=gradientblue&labelorientation=vertical&fonttypetitle=bold&fonttypelabel=bold&show3d=1&legend=1&labels=1&gradient=1&border=1'	
    msg.send "o.k. I'm grabbing hashtag with counts ..."
    path="/api/v1/analytics/trends?access_token=#{env.BONUSLY_ADMIN_API_TOKEN}"
	
    msg.http(service)
      .path(path)
      .get() (err, res, body) ->
        body = JSON.parse body
        results = body.result
        for result in results
          hashTagName = hashTagName + '%0D%0A' + (result.hashtag).replace('#','%23')
          hashTagCount = hashTagCount + '%0D%0A' + result.count
		  
        chartImage = "#{chartAPI}#{chartAPIPram}&xaxis1=#{hashTagName}&yaxis1=#{hashTagCount}"
        msg.send chartImage
		
  robot.respond /(bonusly)? (give) ?(.*)?/i, (msg) ->
    return msg.send bad_token_message unless token
    giver = msg.message.user.name.toLowerCase()
    text = msg.match[3]
    console.log text
    console.log giver
    if text?
      msg.send "o.k. I'll try to give that bonus ..."
    else
      text = ''

    path = '/api/v1/bonuses/create_from_text'
    post = "access_token=#{token}&giver=#{encodeURIComponent(giver)}&client=#{encodeURIComponent(client)}&text=#{encodeURIComponent(text)}" 

    msg.http(service)
      .path(path)
      .header('Content-Type', 'application/x-www-form-urlencoded')
      .post(post) (err, res, body) ->
        switch res.statusCode
          when 200
            data = JSON.parse body
            msg.send data.result
          when 400
            data = JSON.parse body
            msg.send data.message
          else
            msg.send "Failed to give: (#{res.statusCode}). Tried to post (#{post}) to (#{service}#{path})"