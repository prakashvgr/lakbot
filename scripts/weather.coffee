# Description:
# Responds with current weather information for the place
# 
# Configuration:
# HUBOT_FORECAST_API_KEY
# HUBOT_WEATHER_CELSIUS
#
# Commands:
# hubot weather in <place>
# hubot weather in <place> ?
# hubot how is the weather in <place>
# hubot how is the weather in <place> ?
#
# Author
# Piyush Vardhan (piyush.vardhan@capgemini.com)
#
env = process.env

weatherAPIUrl = 'https://api.forecast.io/forecast/' + process.env.HUBOT_FORECAST_API_KEY + '/'
mapAPIUrl = 'http://maps.googleapis.com/maps/api/geocode/json'

fetchLatLong = (msg, location, cb) ->
  msg.http(mapAPIUrl).query(address: location, sensor: false)
    .get() (err, res, body) ->
      try
        body = JSON.parse body
        latlong = body.results[0].geometry.location
      catch err
        err = "#{location} is not in World"
        return cb(msg, null, err)
      cb(msg, latlong, err)

fetchWeatherdata = (msg,latlong, err) ->
   return msg.send err if err
   return msg.send "set env.HUBOT_FORECAST_API_KEY" if not env.HUBOT_FORECAST_API_KEY
   weatherurl = weatherAPIUrl + latlong.lat + ',' + latlong.lng   
   msg.http(weatherurl).query(units:'ca').get() (err,res,body) ->
     return msg.send 'weather information is temporary unavialable' if err
     try
       body = JSON.parse body
       weatherinfo = body.currently
     catch err
       return msg.send 'weather data can not be parsed for required information'
     hum = (weatherinfo.humidity * 100).toFixed 0
     temp = getTemperature(weatherinfo.temperature)
     winfo = "It is currently #{temp} #{weatherinfo.summary}, #{hum}% humidity"
     msg.send winfo

getTemperature = (tmp) ->
    if env.HUBOT_WEATHER_CELSIUS == "Y"
        return tmp.toFixed(0) + "°C"
    else if env.HUBOT_WEATHER_CELSIUS == "N"
        return ((tmp * 18) + 32).toFixed(0) + "°F"
    else
       return tmp.toFixed(0) + "°C"

module.exports = (robot) ->
    robot.respond /(how is the|how is|^$)? weather in (.*)/i, (msg) ->
        location = msg.match[2].trim().replace(/s+/g, '-').toLowerCase()
        fetchLatLong(msg, location, fetchWeatherdata)