# Description:
# Allows Hubot to use blumix personality insights service for cognitive processing.
#
# Dependencies:
# watson-developer-cloud installed
# twitter installed
#
# Configuration:
# IBM_BLUEMIX_PI_USERNAME
# IBM_BLUEMIX_PI_PASSWORD
# TWITTER_CONSUMER_KEY
# TWITTER_CONSUMER_SECRET
# TWITTER_ACCESS_TOKEN_KEY
# TWITTER_ACCESS_TOKEN_SECRET
#
# Commands:
# hubot tell me about <twitter-handle>

env = process.env
watson = require('watson-developer-cloud')
twitter = require('twitter')
traits = require('./traits')

env.IBM_BLUEMIX_PI_USERNAME = ''
env.IBM_BLUEMIX_PI_PASSWORD = ''
env.TWITTER_CONSUMER_KEY = ''
env.TWITTER_CONSUMER_SECRET = ''
env.TWITTER_ACCESS_TOKEN_KEY = ''
env.TWITTER_ACCESS_TOKEN_SECRET = ''

data = {}

compareChildPercent = (o1, o2) ->
    result = 0;

    if (Math.abs(o1.child.percentage) > Math.abs(o2.child.percentage))
        result = -1;

    if (Math.abs(o1.child.percentage) < Math.abs(o2.child.percentage))
        result = 1;

    return result;

insight = (err, result, cb, msg) ->

    pinsights = watson.personality_insights ({
        url: 'https://gateway.watsonplatform.net/personality-insights/api',
        username: env.IBM_BLUEMIX_PI_USERNAME,
        password: env.IBM_BLUEMIX_PI_PASSWORD,
        version: 'v2'
        });
    param = {
        text:result,
        language: 'en'
    }

    pinsights.profile param , (err,response) ->
        if err
            msg.send 'It seems AI engine is not available as of now, please check with me after 15-20 min.'
            return
        else
            cb(null,response,null, msg)

getprofiler = (err, result, cb, msg) ->
    t = traits()
    if err
        msg.send 'It seems profile is not available as of now for the twitter handle, please check with me after 15-20 min.'
    else
        children = []
        messages = []
        needsChildren = []
        valuesChildren = []

        xf = Object.keys t.facets
        yf = xf.map(getNode)

        for fctName in yf
            f = t.facets[fctName]

            child = searchInProfile f, fctName, result,"Big 5"

            children.push child if child?
            if child?
                if child.percentage > 0.5
                    messages.push(f.HighDescription.toLowerCase())
                else
                    messages.push(f.LowDescription.toLowerCase())

        xn = Object.keys t.needs
        yn = xn.map(getNode)
        for ndName in yn
            n = t.needs[ndName]
            child = searchInProfile n, ndName, result,"Needs"
            if child?
                o = {}
                o.need = n
                o.child = child
                needsChildren.push o

        needsChildren.sort(compareChildPercent)
        child = needsChildren[0].child
        children.push child if child?
        stmtindx=0
        s = ''

        if child?
            stmtindx = Math.min (Math.floor (child.percentage * 4), 3)

        if stmtindx == 0
            s = 'Experiences that make you feel high ' + needsChildren[0].need[stmtindx] + ' are generally unappealing to you'
        if stmtindx == 1
            s = 'Experiences that give a sense of ' + needsChildren[0].need[stmtindx] + ' hold some appeal to you'
        if stmtindx == 2
            s = 'You are motivated to seek out experiences that provide a strong feeling of ' + needsChildren[0].need[stmtindx]
        if stmtindx == 3
            s = 'Your choices are driven by a desire for ' + needsChildren[0].need[stmtindx]

        messages.push(s.toLowerCase())


        xv = Object.keys t.values
        yv = xv.map(getNode)
        for valName in yv
            v = t.values[valName]
            child = searchInProfile v, valName, result,"Values"
            if child?
                o = {}
                o.value = n
                o.child = child
                valuesChildren.push o
            valuesChildren.sort(compareChildPercent)
            child = valuesChildren[0].child
            children.push child if child?

        stmtindx=0
        s = ''
        if child?
            stmtindx = Math.min (Math.floor (child.percentage * 4), 3)

        if stmtindx == 0
            s = 'You are relatively unconcerned with ' + valuesChildren[0].value[stmtindx]
        if stmtindx == 1
            s = 'You don\'t find  ' +  valuesChildren[0].value[stmtindx] + ' to be particularly motivating for you'
        if stmtindx == 2
            s = 'You value ' + valuesChildren[0].value[stmtindx] + ' a bit more'
        if stmtindx == 3
            s = 'You consider ' + valuesChildren[0].value[stmtindx] + ' to guide a large part of what you do'


        messages.push(s.toLowerCase())

        stmts = messages.map(formatStmt)
        summary = ""
        for x in stmts

            summary = summary + x
        msg.send summary

formatStmt = (s) ->
    c = s.charAt(0)
    uc = c.toLocaleUpperCase() + s.substring( 1 ) + "."
    return uc

getNode = (o) ->
    if (Object.keys o).length > 0
        return o
    else
        return null

searchInProfile = (t, tname , prf, secName) ->
    x = prf.tree.children

    for n in x
        if n.name is secName
            c = n.children.map(getChild)

            for d in c
                y = d.children.map(getChild)
                if secName is "Big 5"
                    for childgrp in y
                        z = childgrp.children.map(getChild)
                        for child in z
                            return child if child.name is tname
                if secName is "Needs"
                    for child in y
                        if child.name is tname
                            return child

                if secName is "Values"
                    for child in y
                        if child.name is tname
                            return child
getChild = (c) ->
    return c

readTwitterHandle = (err, result, cb,msg) ->

    twitter_client = new twitter({
        consumer_key: env.TWITTER_CONSUMER_KEY
        consumer_secret: env.TWITTER_CONSUMER_SECRET
        access_token_key: env.TWITTER_ACCESS_TOKEN_KEY
        access_token_secret: env.TWITTER_ACCESS_TOKEN_SECRET
        });

    twitter_client.get '/statuses/user_timeline.json?screen_name='+result + '&count=10000', (error, tweets, response) ->
        if (error)
            msg.send 'It seems twitter is not available as of now, please check with me after 15-20 min.'
            return

        accumulatedTweets = []
        tweetstring = accumulatedTweets.concat(tweets.map(grabTweets))
        cb(null, tweetstring, getprofiler,msg);

grabTweets = (tweet) ->
    parsedTweet = tweet.text.replace('[^(\\x20-\\x7F)]*', '');
    return parsedTweet;

module.exports = (robot) ->
    robot.hear /(Aiemee tell me about) (.*)/i, (msg) ->
        matches = msg.match
        txt = matches[2] or ''
        params = { text: txt }
        data.msg = params
        readTwitterHandle(null, txt, insight, msg)
