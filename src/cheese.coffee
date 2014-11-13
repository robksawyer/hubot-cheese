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
#   hubot eat cheese - This will feed your robot a random piece of cheese and tell you a few more details about which cheese it consumed.
#   hubot i want cheese - Sends cheese to the person asking
#   hubot how many cheeses exist? - Sends a total number of cheeses that exist in the Curd Collective API
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
  '401': 'Unauthorized'
  '403': 'Forbidden'
  '404': 'Not Found'
  '429': 'Too Many Requests'
  '500': 'Internal Server Error'
  '504': 'Service Unavailable'

cheeseUser = (toUser, fromUser, message) ->
  endpoint = url.format
      protocol: 'https'
      host: 'curdcollective-api.herokuapp.com'
      pathname: util.format '1.0/cheeses/info/%s', Math.random() * (2576 - 1) + 1
  msg
      .http(endpoint)
      .query
        client_id: process.env.HUBOT_CC_CLIENT_ID
        client_secret: process.env.HUBOT_CC_CLIENT_SECRET
      .get() (err, res, body) ->
        #return msg.send failureCodes[res.statusCode] if failureCodes[res.statusCode]
        try
          results = JSON.parse body
          cheese = results.response.Cheese.name
          cheese_producer = results.response.CheeseProducer.name
          age_classification = results.response.Cheese.age_classification
          milk_treatment = results.response.MilkTreatment.name
          cheese_location = results.response.CheeseLocation[0].city + ", " + results.response.CheeseLocation[0].StateRegion.code  
          msg.reply "#{toUser.name} have a piece of #{cheese} by #{cheese_producer} from #{cheese_location}. Be sure to thank #{fromUser}."

module.exports = (robot) ->
  
  #
  # Feed your robot cheese 
  # Command:
  #   Hubot> hubot eat cheese
  #
  robot.respond /eat cheese|have some cheese/i, (msg) ->
    endpoint = url.format
      protocol: 'https'
      host: 'curdcollective-api.herokuapp.com'
      pathname: util.format '1.0/cheeses/info/%s', Math.random() * (2576 - 1) + 1

    msg
      .http(endpoint)
      .query
        client_id: process.env.HUBOT_CC_CLIENT_ID
        client_secret: process.env.HUBOT_CC_CLIENT_SECRET
      .get() (err, res, body) ->
        #return msg.send failureCodes[res.statusCode] if failureCodes[res.statusCode]
        try
          results = JSON.parse body
          cheese = results.response.Cheese.name
          cheese_producer = results.response.CheeseProducer.name
          age_classification = results.response.Cheese.age_classification
          milk_treatment = results.response.MilkTreatment.name
          cheese_location = results.response.CheeseLocation[0].city + ", " + results.response.CheeseLocation[0].StateRegion.code  
          #msg.send util.format "%s - %s - %s - %s - %s - %s", user.id, user.first_name, user.last_name, user.username, user.display_name, user.url
          #msg.send util.format "Profile Picture: %s", user.images[115]
          msg.send "Yum! The #{cheese} by #{cheese_producer} from #{cheese_location} was delicious."

  #
  # Feed cheese to the person that asked nicely
  # Command:
  #   Hubot> hubot i want cheese
  #
  robot.hear /cheese me|i want cheese|can i haz chee(s|z)e(.*)/i, (msg) ->
    endpoint = url.format
      protocol: 'https'
      host: 'curdcollective-api.herokuapp.com'
      pathname: util.format '1.0/cheeses/info/%s', Math.random() * (2576 - 1) + 1

    msg
      .http(endpoint)
      .query
        client_id: process.env.HUBOT_CC_CLIENT_ID
        client_secret: process.env.HUBOT_CC_CLIENT_SECRET
      .get() (err, res, body) ->
        #return msg.send failureCodes[res.statusCode] if failureCodes[res.statusCode]
        try
          results = JSON.parse body
          cheese = results.response.Cheese.name
          cheese_producer = results.response.CheeseProducer.name
          age_classification = results.response.Cheese.age_classification
          milk_treatment = results.response.MilkTreatment.name
          cheese_location = results.response.CheeseLocation[0].city + ", " + results.response.CheeseLocation[0].StateRegion.code  
          msg.reply "Have a piece of #{cheese} by #{cheese_producer} from #{cheese_location}."

  #
  # Sends a piece of cheese to a user
  # Command:
  #   Hubot> hubot cheese <user name>: <message>
  #
  robot.hear /cheese (.*?): (.*)/i, (msg) ->
    endpoint = url.format
      protocol: 'https'
      host: 'curdcollective-api.herokuapp.com'
      pathname: util.format '1.0/cheeses/info/%s', Math.random() * (2576 - 1) + 1

    users = robot.brain.usersForFuzzyName(msg.match[1].trim())
    if users.length is 1
      user = users[0]
      cheeseUser(user, msg.message.user)
      msg.send "Cheese being prepared"
    else if users.length > 1
      msg.send "Too many users like that"
    else
      msg.send "#{msg.match[1]}? Never heard of 'em"
  
  #
  # Get the total number of cheeses that exist
  # Command:
  #   Hubot> hubot how many cheeses exist?
  #
  robot.respond /how many cheeses exist(.*)|total cheeses|how many cheeses/i, (msg) ->
    endpoint = url.format
      protocol: 'https'
      host: 'curdcollective-api.herokuapp.com'
      pathname: util.format '1.0/cheeses/total'

    msg
      .http(endpoint)
      .query
        client_id: process.env.HUBOT_CC_CLIENT_ID
        client_secret: process.env.HUBOT_CC_CLIENT_SECRET
      .get() (err, res, body) ->
        #return msg.send failureCodes[res.statusCode] if failureCodes[res.statusCode]
        try
          results = JSON.parse body
          total_cheese = results.response
          msg.send "So far I've counted #{total_cheese} cheeses."

