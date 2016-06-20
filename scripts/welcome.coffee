# Description:
#   General and private greet message to the newly joined user.
#
# Commands:
#   None
#
# Configuration:
#   None
#
# Author:
#   Prakash Rajendran (prakash.rajendran@capgemini.com)
#

module.exports = (robot) ->

  welcomeMsg = process.env.HUBOT_WELCOME_MESSAGE or "Hey {USER}, welcome to Capgemini AIE Chatbot. What are you looking for today?"

  robot.enter (res) ->
    userName = res.message.user.name
    res.send welcomeMsg.replace "{USER}",userName
    robot.send {room: userName},
      """Hi there, I'm Aiemee! Welcome to Capgemini AIE Chatbot.
      Here's how i work - you can directly message me the word "Aiemee help" to get to know all my services,
      Sample
        1. Aiemee Ping - Respond with Pong
        2. Aiemee Weather in <place> - Display the weather in <place>
        3. Aiemee seriously guys - Display a serious guies GIF image
        4. Aiemee Lunchtime near <city> - Response with nearby hotel
      """

  robot.leave (res) ->
    userName = res.message.user.name
    res.send "User #{userName} left the Capgemini AIE Chatbot"
