# Description
#   A hubot integration for Home-Assistant.io
#
# Configuration:
#   HUBOT_HOME_ASSISTANT_HOST - the hostname for Home Assistant, like `https://demo.home-assistant.io`.
#   HUBOT_HOME_ASSISTANT_API_PASSWORD - the API password for Home Assistant.
#   HUBOT_HOME_ASSISTANT_MONITOR_EVENTS - defaults to true. Can be set to false to skip all streaming / monitoring
#   HUBOT_HOME_ASSISTANT_MONITOR_ALL_ENTITIES - whether to monitor all entities by default
#   HUBOT_HOME_ASSISTANT_EVENTS_DESTINATION - which room/channel/chat to send events to
#
# Commands:
#   hubot hass state of <friendly name of entity> - returns the current state of the entity
#   hubot hass turn <friendly name of entity> <on|off> - turn the entity on/off
#   hubot hass set <friendly name of entity> to <new state> - set the entity state to the given value
#
# Author:
#   Robbie Trencheny <me@robbiet.us>

_ = require('lodash')
{ URL } = require('url')
HomeAssistant = require('homeassistant')
moment = require('moment')

module.exports = (robot) ->
  unless process.env.HUBOT_HOME_ASSISTANT_HOST?
    robot.logger.error "hubot-home-assistant included, but missing HUBOT_HOME_ASSISTANT_HOST."
    return

  unless process.env.HUBOT_HOME_ASSISTANT_API_PASSWORD?
    robot.logger.error "hubot-home-assistant included, but missing HUBOT_HOME_ASSISTANT_API_PASSWORD."
    return

  hassUrl = new URL(process.env.HUBOT_HOME_ASSISTANT_HOST)
  hass = new HomeAssistant({
    host: "#{hassUrl.protocol}//#{hassUrl.hostname}",
    port: if !hassUrl.port then (if hassUrl.protocol == 'https:' then '443' else '80') else hassUrl.port,
    password: process.env.HUBOT_HOME_ASSISTANT_API_PASSWORD,
    ignoreCert: process.env.HUBOT_HOME_ASSISTANT_IGNORE_CERT || false
  })

  ##
  # Call Service
  #
  # Calls a service with the specified arguments
  #
  # @param string
  # @param string
  # @param object
  # @return Promise
  callService = (domain, service, service_data) ->
    hass.services.call(domain, service, service_data)
    .then (res) ->
      return res
    .catch (err) ->
      robot.logger.error err

  ##
  # Get Device by Friendly Name
  #
  # Finds exactly one device (first encountered) that matches
  #
  # @param string
  # @return Promise
  getDeviceByFriendlyName = (friendlyName) ->
    friendlyName = friendlyName.replace '’', "'" # fix for Slack silliness
    hass.states.list()
    .then (entities) ->
      foundDevice = _.find entities, 'attributes': 'friendly_name': friendlyName
      if !foundDevice
        throw new Error('No device found with that name!')
      return foundDevice

  ##
  # Set Power Status
  #
  # Convenience method to turn a device on/off
  #
  # @param string
  # @param string
  # @return Promise
  setPower = (friendlyName, state) ->
    getDeviceByFriendlyName(friendlyName)
    .then (device) ->
      robot.logger.debug 'device', device
      service_data = entity_id: device.entity_id
      callService('homeassistant', 'turn_'+state, service_data)
      .catch (err) ->
        robot.logger.error err

  ##
  # Get the current state of a device
  robot.respond /(?:hass|ha) state of (.*)/i, (res) ->
    getDeviceByFriendlyName(res.match[1])
    .then (device) ->
      robot.logger.debug 'device', device
      last_changed = moment(new Date(device.last_changed)).fromNow()
      res.reply "#{device.attributes.friendly_name} is #{device.state} (since #{last_changed})"
    .catch (err) ->
      res.send err.message
      robot.logger.error err

  ##
  # Turn a device on/off
  robot.respond /(?:hass|ha) turn (.*) (on|off)/i, (res) ->
    friendlyName = res.match[1]
    state = res.match[2]
    setPower(friendlyName, state)
    .then () ->
      res.reply "#{friendlyName} turned #{state}"
    .catch (err) ->
      res.send err.message
      robot.logger.error err

  ##
  # Set a device to a particular state
  robot.respond /(?:hass|ha) set (.*) to (.*)/i, (res) ->
    friendlyName = res.match[1]
    state = res.match[2]
    res.reply "Setting #{friendlyName} to #{state}"
    getDeviceByFriendlyName(friendlyName)
    .then (device) ->
      parts = device.entity_id.split('.')
      domain = parts[0]
      service = parts[1]
      # Check if a JSON object was passed
      try
        payload = JSON.parse(state)
      catch e
        payload = { state: state }
      callService(domain, service, payload)
    .then () ->
      res.reply "#{friendlyName} set to #{state}"
    .catch (err) ->
      res.send err.message
      robot.logger.error err
