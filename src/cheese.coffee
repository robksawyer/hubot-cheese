# Description
#   Hubots like cheese. 
#   This script taps into the huge database and API for cheese known as Curd Collective.
#   
#   The domain 
#   API Endpoint: https://curdcollective-api.herokuapp.com/1.0/
#   API Documentation: https://curdcollective.3scale.net/overview
#   
#   IMPORTANT: In order to use this script, you'll need to sign up to the API at https://curdcollective.3scale.net/signup. 
#              This will provide you with the client_id and client_secret that you'll need to configure as an evironment variable.
# 
# Dependencies:
#   
# Configuration:
#   HUBOT_CC_CLIENT_ID
#   HUBOT_CC_CLIENT_SECRET
#
# Commands:
#   hubot eat cheese - This will feed your robot a random piece of cheese and tell you a few more details about which he ate.
#
# Notes:
#   Feed your robot daily.
#
# Author:
#   Rob Sawyer[https://github.com/robksawyer]

util = require 'util'
url = require 'url'

process.env.HUBOT_CC_CLIENT_ID ||= 'c7db062c'
process.env.HUBOT_CC_CLIENT_SECRET ||= '194e46e98dfccaa10de6f198b3dce718'

failureCodes =
  '403': 'Forbidden'
  '404': 'Not Found'
  '429': 'Too Many Requests'
  '500': 'Internal Server Error'
  '504': 'Service Unavailable'

module.exports = (robot) ->

  robot.respond /eat cheese/i, (msg) ->
    endpoint = url.format
      protocol: 'https'
      host: 'curdcollective-api.herokuapp.com'
      pathname: util.format '1.0/cheeses/info/%s', 193
    
    msg.send endpoint

    msg
      .http(endpoint)
      .query
        client_id: process.env.HUBOT_CC_CLIENT_ID
        client_secret: process.env.HUBOT_CC_CLIENT_SECRET
      .get() (err, res, body) ->
        return msg.send failureCodes[res.statusCode] if failureCodes[res.statusCode]
        try
          results = JSON.parse body
          cheese = results.response.Cheese.name
          #msg.send util.format "%s - %s - %s - %s - %s - %s", user.id, user.first_name, user.last_name, user.username, user.display_name, user.url
          #msg.send util.format "Profile Picture: %s", user.images[115]
          msg.send "Yum, the #{cheese} was delicious"

