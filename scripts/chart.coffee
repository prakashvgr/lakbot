# Description:
#  
#
# Dependencies:
#   watson-developer-cloud
#
# Configuration:
#   
#
# Commands:
#   
#
# Author:
#   Prakash Rajendran (prakash.rajendran@capgemini.com)
#

env = process.env

watson = require('watson-developer-cloud')
fs = require('fs')
speech_to_text = watson.speech_to_text(
  username: ''
  password: ''
  version: 'v1')
files = [
  'audio-file1.flac'
  'audio-file2.flac'
]

conversation = ''
language_translation = watson.language_translation(
  username: ''
  password: ''
  version: 'v2')


module.exports = (robot) ->
  robot.respond /analyze audio/i, (msg) ->
    for file of files
      params = 
        audio: fs.createReadStream(files[file])
        content_type: 'audio/flac'
        timestamps: true
        word_alternatives_threshold: 0.9
        continuous: true
      speech_to_text.recognize params, (error, transcript) ->
        if error
          console.log 'error:', error
        else
          #body = JSON.stringify(transcript, null, 2)
          conversation = transcript.results[0].alternatives[0].transcript
    console.log conversation
    #fnTextTransalte(msg, conversation)

fnTextTransalte = (msg, txt) ->
  language_translation.translate {
    text: txt
    source: 'en'
    target: 'es'
  }, (err, translation) ->
    if err
      console.log err
    else
      console.log translation
    return

