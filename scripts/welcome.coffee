module.exports = (robot) ->

  welcomeMsg = process.env.HUBOT_WELCOME_MESSAGE or "Hey {USER}, welcome to our AIE Chatbot. What are you looking for today?"

  robot.enter (res) ->
    userName = res.message.user.name
    res.send welcomeMsg.replace "{USER}",userName
    robot.send {room: userName},
      """Hi there, I'm Aiemee! Welcome to our AIE Chatbot.
      Here's how i work - you can direct message me the word "Aiemee help",
      Sample
        1. Aiemee Ping - Respond with Pong
        2. Aiemee Weather in <place> - Display the weather in <place>
        3. Aiemee seriously guys - Display a serious guies GIF image
        4. Aiemee Lunchtime near <city>
      """

  robot.leave (res) ->
    userName = res.message.user.name
    res.send "User #{userName} left the AIE Chatbot"
