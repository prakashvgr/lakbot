module.exports = (robot) ->

  welcomeMsg = process.env.HUBOT_WELCOME_MESSAGE or "Hey {USER}, welcome to our channel!"

  robot.enter (res) ->
    userName = res.message.user.name
    console.log userName
    console.log welcomeMsg.replace "{USER}",userName
    res.send welcomeMsg.replace "{USER}",userName

  robot.leave (res) ->
    userName = res.message.user.name
    console.log userName
    console.log welcomeMsg.replace "{USER}",userName
    res.send "User #{userName} left the channel"
