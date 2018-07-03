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
#   hubot hass list - returns a list of entities and their friendly names
#   hubot hass state of <friendly name or entity ID> - returns the current state of the entity
#   hubot hass turn <friendly name or entity ID> <on|off> - turn the entity on/off
#   hubot hass set <friendly name or entity ID> to <new state> - set the entity state to the given value
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
  getDeviceByFriendlyNameOrId = (searchStr) ->
    searchStr = searchStr.replace '’', "'" # fix for Slack silliness
    hass.states.list()
    .then (entities) ->
      foundDevice = _.find entities, 'attributes': 'friendly_name': searchStr
      unless foundDevice
        foundDevice = _.find entities, 'entity_id': searchStr
        unless foundDevice
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
    getDeviceByFriendlyNameOrId(friendlyName)
    .then (device) ->
      robot.logger.debug 'device', device
      device_parts = device.entity_id.split('.')
      device_domain = device_parts[0]
      service_data = entity_id: device.entity_id
      callService('turn_'+state, device_domain, service_data)
      .then (device) ->
        return device
      .catch (err) ->
        robot.logger.error err

  ##
  # Get list of entities
  robot.respond /(?:hass|ha) list/i, (res) ->
    hass.states.list()
    .then (states) ->
      robot.logger.debug states
      output = []
      _.each states, (entity) ->
        if (
          entity.attributes.view != true && !entity.entity_id.match(/^zone\./i) && entity.attributes.hidden != true
        )
          output.push "#{entity.entity_id}: #{entity.attributes.friendly_name}"
      res.send output.join('; ')
    .catch (err) ->
      res.send err.message
      robot.logger.error err

  ##
  # Get the state of an entity
  robot.respond /(?:hass|ha) state of (.*)/i, (res) ->
    getDeviceByFriendlyNameOrId(res.match[1])
    .then (device) ->
      robot.logger.debug 'device', device
      last_changed = moment(new Date(device.last_changed)).fromNow()
      res.reply "#{device.attributes.friendly_name} is #{device.state} (since #{last_changed})"
    .catch (err) ->
      res.send err.message
      robot.logger.error err

  ##
  # Set the state of an entity
  robot.respond /(?:hass|ha) set (.*) to (.*)/i, (res) ->
    friendlyName = res.match[1]
    state = res.match[2]
    res.reply "Setting #{friendlyName} to #{state}"
    getDeviceByFriendlyNameOrId(friendlyName)
    .then (device) ->
      parts = device.entity_id.split('.')
      domain = parts[0]
      service = parts[1]
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

  ##
  # Turn a entity on/off
  robot.respond /(?:hass|ha) turn (.*) (on|off)/i, (res) ->
    searchStr = res.match[1]
    state = res.match[2]
    setPower(searchStr, state)
    .then (entities) ->
      device = _.find entities, 'attributes': 'friendly_name': searchStr
      unless device
        device = _.find entities, 'entity_id': searchStr
        unless device
          throw new Error('No device found with that name!')
      res.reply "#{device.attributes.friendly_name} turned #{state}"
    .catch (err) ->
      res.send err.message
      robot.logger.error err
