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
#   https://curdcollective-api.herokuapp.com/1.0/cheeses/info/193.json?client_id=c7db062c&client_secret=194e46e98dfccaa10de6f198b3dce718
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

module.exports = (robot) ->
  robot.respond /hello/, (msg) ->
    msg.reply "hello!"

  robot.hear /orly/, ->
    msg.send "yarly"
