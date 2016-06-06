# Description
#   Respond with spofity music track based on the search
#
# Configurations:
#
#   HUBOT_SPOFITY_CLIENT_ID
#   HUBOT_SPOFITY_CLIENT_SECRET
#
# Commands:
#   hubot search <track / album > - randomly selects track / album with matched search results
#   hubot search artist - randomly selects artist with matched search results
#
# Author:
#   Prakash Rajendran (prakash.rajendran@capgemini.com)
#

env = process.env

SPOFITY_TOKEN_URL = 'https://accounts.spotify.com/api/token'
SPOFITY_API_URL = 'https://api.spotify.com/v1/'
accessToken = val: '0'

module.exports = (robot) ->
  robot.respond /search ?(track|song|album|artist)? (.*)$/i, (msg) ->
    qtype = msg.match[1]
    query = msg.match[2]
    type = if qtype? then qtype else 'track'
    searchSpotify(msg, type, query)

searchSpotify = (msg, serType, serQuery) ->
  msg.http(SPOFITY_API_URL + 'search')
    .query(query: serQuery, type: serType)
    .get() (err, res, body) ->
      try
        body = JSON.parse body
        switch serType
          when "track"
            items = body.tracks.items
          when "album"
            items = body.albums.items
          when "artist"
            items = body.artists.items
        if items.length > 0
          item = msg.random items
          msg.send item.external_urls.spotify
        else
          msg.send "Oops, no record for this #{serType}, try another #{serType}"
      catch err
        msg.send "Unable to search #{serType}, #{err}"
