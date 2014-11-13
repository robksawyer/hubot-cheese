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

module.exports = (robot) ->
  
  robot.brain.on 'loaded', =>
    robot.brain.data.cheeses ||= {}

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
        try
          results = JSON.parse body
          return msg.send failureCodes[results.meta.code] if failureCodes[results.meta.code]
          cheese = results.response.Cheese.name
          cheese_producer = results.response.CheeseProducer.name
          age_classification = results.response.Cheese.age_classification
          milk_treatment = results.response.MilkTreatment.name

          if results.response.CheeseLocation[0].city and results.response.CheeseLocation[0].StateRegion.code
            cheese_location = results.response.CheeseLocation[0].city + ", " + results.response.CheeseLocation[0].StateRegion.code
          
          if cheese_location
            msg.send "Yum! The #{cheese} by #{cheese_producer} from #{cheese_location} was delicious."
          else 
            msg.send "Yum! The #{cheese} by #{cheese_producer} was delicious."

  #
  # Feed cheese to the person that asked nicely
  # Command:
  #   Hubot> i want cheese
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
        try
          results = JSON.parse body
          return msg.send failureCodes[results.meta.code] if failureCodes[results.meta.code]
          cheese = results.response.Cheese.name
          cheese_producer = results.response.CheeseProducer.name
          age_classification = results.response.Cheese.age_classification
          milk_treatment = results.response.MilkTreatment.name

          if results.response.CheeseLocation[0].city and results.response.CheeseLocation[0].StateRegion.code
            cheese_location = results.response.CheeseLocation[0].city + ", " + results.response.CheeseLocation[0].StateRegion.code  
          
          if cheese_location
            msg.send "Have a piece of #{cheese} by #{cheese_producer} from #{cheese_location}."
          else 
            msg.send "Have a piece of #{cheese} by #{cheese_producer}."

  #
  # Find more details about a cheese.
  # Command:
  #   Hubot> hubot cheese deets <cheese_id>
  #
  robot.hear /cheese deets ([0-1]*)|what do you know about the cheese ([0-1]*)/i, (msg) ->
    endpoint = url.format
      protocol: 'https'
      host: 'curdcollective-api.herokuapp.com'
      pathname: util.format '1.0/cheeses/info/%s', msg.match[1]

    msg
      .http(endpoint)
      .query
        client_id: process.env.HUBOT_CC_CLIENT_ID
        client_secret: process.env.HUBOT_CC_CLIENT_SECRET
      .get() (err, res, body) ->
        try
          results = JSON.parse body
          return msg.send failureCodes[results.meta.code] if failureCodes[results.meta.code]
          cheese = results.response.Cheese.name
          details = "Name: " + cheese + "\n"

          cheese_producer = results.response.CheeseProducer.name
          if cheese_producer
            details += "Producer: " + cheese_producer + "\n"

          texture = results.response.Texture.name
          if texture
            details += "Texture: " + texture + "\n"

          classification = results.response.Classification.name
          if classification
            details += "Classification: " + classification + "\n"

          age_classification = results.response.Cheese.age_classification
          if age_classification
            details += "Age Classification: " + age_classification + "\n"

          aging_time = results.response.Cheese.aging_time
          if aging_time
            details += "Aged for: " + aging_time + "\n"

          rennet = results.response.RennetType.name
          if rennet
            details += "Rennet Type: " + rennet + "\n"

          milk_treatment = results.response.MilkTreatment.name
          if milk_treatment
            details += "Milk Treatment: " + milk_treatment + "\n"
          
          rind = results.response.Rind.name
          if rind
            details += "Rind: " + rind + "\n"

          milk_sources = for source.name in results.response.MilkSource
          if milk_sources
            milk_sources = milk_sources.join(',')
            details += "Milk Source(s): " + milk_sources + "\n"

          if results.response.CheeseLocation[0].city and results.response.CheeseLocation[0].StateRegion.code
            cheese_location = results.response.CheeseLocation[0].city + ", " + results.response.CheeseLocation[0].StateRegion.code 
          
          if cheese_location
            details += "Location: " + cheese_location + "\n"
          
          info = results.response.Cheese.info_overview
          if info
            details += info + "\n"

  #
  # Sends a piece of cheese to a user
  # Command:
  #   Hubot> send cheese to @<user name>
  #
  robot.hear /send cheese to @(.*)/i, (msg) ->

    endpoint = url.format
            protocol: 'https'
            host: 'curdcollective-api.herokuapp.com'
            pathname: util.format '1.0/cheeses/info/%s', Math.random() * (2576 - 1) + 1

    if msg.match[1]
      users = robot.brain.usersForFuzzyName(msg.match[1].trim())

    if users
      if users.length is 1
        user = users[0]
        msg
          .http(endpoint)
          .query
            client_id: process.env.HUBOT_CC_CLIENT_ID
            client_secret: process.env.HUBOT_CC_CLIENT_SECRET
          .get() (err, res, body) ->
            try
              results = JSON.parse body
              return msg.send failureCodes[results.meta.code] if failureCodes[results.meta.code]
              cheese = results.response.Cheese.name
              cheese_producer = results.response.CheeseProducer.name
              age_classification = results.response.Cheese.age_classification
              milk_treatment = results.response.MilkTreatment.name
              
              if results.response.CheeseLocation[0].city and results.response.CheeseLocation[0].StateRegion.code
                cheese_location = results.response.CheeseLocation[0].city + ", " + results.response.CheeseLocation[0].StateRegion.code  
              
              if cheese_location
                msg.reply "#{user.name} have a piece of #{cheese} by #{cheese_producer} from #{cheese_location}. Be sure to thank #{msg.message.user.name}."
              else
                msg.reply "#{user.name} have a piece of #{cheese} by #{cheese_producer}. Be sure to thank #{msg.message.user.name}."

      else if users.length > 1
        msg.send "Too many users like that"
      else
        msg.send "#{msg.match[1]}? Never heard of 'em"
  
  #
  # Get the total number of cheeses that exist
  # Command:
  #   Hubot> hubot how many cheeses exist?
  #
  robot.respond /how many cheeses exist(.*)|total cheese(.*)|how many cheeses|cheese total/i, (msg) ->
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
        try
          results = JSON.parse body
          return msg.send failureCodes[results.meta.code] if failureCodes[results.meta.code]
          total_cheese = results.response
          msg.send "So far I've counted #{total_cheese} cheeses."

