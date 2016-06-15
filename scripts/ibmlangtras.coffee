module.exports = (robot) ->
  robot.respond /watson ?(trans|txt2speach)? (.*)$/i, (msg) ->
    query = msg.match[2]
    translateWatson(msg, query)


translateWatson = (msg, query) ->
  console.log query
  watson = require('watson-developer-cloud')
  language_translation = watson.language_translation(
    username: '{62329d17-5ab7-4724-b7c3-18683ce4b971}'
    password: '{hOoAbonsW5gI}'
    version: 'v2')
  language_translation.translate {
    text: 'hello'
    source: 'en'
    target: 'es'
  }, (err, translation) ->
    if err
      console.log err
    else
      console.log translation
    return
