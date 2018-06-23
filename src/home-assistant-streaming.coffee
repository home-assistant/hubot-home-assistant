##
# Notes
#   Additional streaming capabilities if enabled.
#
_ = require('lodash')
EventSource = require('eventsource')
moment = require('moment')

module.exports = (robot) ->
  unless process.env.HUBOT_HOME_ASSISTANT_HOST? || process.env.HUBOT_HOME_ASSISTANT_API_PASSWORD?
    return

  cleanKey = (key) ->
    key.replace(/_/g, ' ').replace /\w\S*/g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

  componentToHex = (c) ->
    hex = c.toString(16)
    if hex.length == 1 then '0' + hex else hex

  rgbToHex = (r, g, b) ->
    '#' + componentToHex(r) + componentToHex(g) + componentToHex(b)

  getSlackIcon = (entity_id) ->
    switch entity_id.split(".")[0]
      when "alarm_control_panel"
        return ":rotating_light:"
      when "automation"
        return ":arrow_forward:"
      when "binary_sensor"
        return ":o:"
      when "camera"
        return ":eyes:"
      when "configurator"
        return ":gear:"
      when "conversation"
        return ":studio_microphone:"
      when "device_tracker"
        return ":bust_in_silhouette:"
      when "garage_door"
        return ":oncoming_automobile:"
      when "group"
        return ":busts_in_silhouette:"
      when "homeassistant"
        return ":house_with_garden:"
      when "input_boolean"
        return ":pencil:"
      when "input_select"
        return ":control-knobs:"
      when "input_slider"
        return ":level_slider:"
      when "light"
        return ":bulb:"
      when "lock"
        return ":unlock:"
      when "media_player"
        return ":speaker:"
      when "notify"
        return ":pager:"
      when "proximity"
        return ":world_map:"
      when "scene"
        return ":black_square_button:"
      when "script"
        return ":page_facing_up:"
      when "sensor"
        return ":eye:"
      when "simple_alarm"
        return ":bell:"
      when "sun"
        return ":sunny:"
      when "switch"
        return ":electric_plug:"
      when "thermostat"
        return ":thermometer:"
      when "updater"
        return ":tada:"
      when "weblink"
        return ":globe_with_meridians:"
      when "zone"
        return ":world_map:"
      else
        return ":bookmark:"

  sendEvent = (event) ->
    if event.data.new_state.attributes.hubot_monitor is true or process.env.HUBOT_HOME_ASSISTANT_MONITOR_ALL_ENTITIES?
      name = event.data.new_state.attributes.friendly_name || event.data.entity_id
      new_state = event.data.new_state
      old_state = event.data.old_state
      last_changed = moment(new Date(old_state.last_changed)).fromNow(true)
      if new_state.attributes.unit_of_measurement
        message = "#{name} is #{new_state.state} #{new_state.attributes.unit_of_measurement} (was #{old_state.state} #{old_state.attributes.unit_of_measurement} for #{last_changed})"
      else
        message = "#{name} is #{new_state.state} (was #{old_state.state} for #{last_changed})"
      switch robot.adapterName
        when 'slack'
          new_state_fields = _.map(_.merge({}, new_state.attributes, new_state), (value, key) ->
            if moment(new Date(value)).isValid() and moment(new Date(value)).isAfter('2013-01-01')
              value = moment(new Date(value)).format("dddd, MMMM Do YYYY, h:mm:ss a")
            return "title": cleanKey(key), "value": String(value), "short": String(value).length <= 20
          ).filter ((o) ->
            o.title != "Attributes"
          )
          old_state_fields = _.map(_.merge({}, old_state.attributes, old_state), (value, key) ->
            if moment(new Date(value)).isValid() and moment(new Date(value)).isAfter('2013-01-01')
              value = moment(new Date(value)).format("dddd, MMMM Do YYYY, h:mm:ss a")
            return "title": cleanKey(key), "value": String(value), "short": String(value).length <= 20
          ).filter ((o) ->
            o.title != "Attributes"
          )
          new_state_attachment =
            "fallback": "New State",
            "title": "New State",
            "fields": new_state_fields
          old_state_attachment =
            "fallback": "Old State",
            "title": "Old State",
            "fields": old_state_fields
          if new_state.attributes.rgb_color
            rgb_color = new_state.attributes.rgb_color
            new_state_attachment.color = rgbToHex rgb_color[0], rgb_color[1], rgb_color[2]
          if old_state.attributes.rgb_color
            rgb_color = old_state.attributes.rgb_color
            old_state_attachment.color = rgbToHex rgb_color[0], rgb_color[1], rgb_color[2]
          if event.data.entity_id.split(".")[0] == "camera"
            new_state_attachment["image_url"] = new_state.attributes.entity_picture
          if event.data.entity_id.split(".")[0] == "camera"
            old_state_attachment["image_url"] = old_state.attributes.entity_picture
          attachment =
            "text": message,
            "attachments": [
              new_state_attachment,
              old_state_attachment
            ],
            "channel": process.env.HUBOT_HOME_ASSISTANT_EVENTS_DESTINATION || "#home-assistant",
            "username": name
          if new_state.attributes.entity_picture and event.data.entity_id.split(".")[0] != "camera"
            attachment["icon_url"] = new_state.attributes.entity_picture
          else
            attachment["icon_emoji"] = getSlackIcon event.data.entity_id
          robot.emit 'slack-attachment', attachment
        else
          robot.messageRoom process.env.HUBOT_HOME_ASSISTANT_EVENTS_DESTINATION, message

  ##
  # Stream Home Assistant events
  if process.env.HUBOT_HOME_ASSISTANT_MONITOR_EVENTS?
    @es = new EventSource("#{process.env.HUBOT_HOME_ASSISTANT_HOST}/api/stream", {headers: {'x-ha-access': process.env.HUBOT_HOME_ASSISTANT_API_PASSWORD}})
    @es.addEventListener 'message', (msg) ->
      if msg.data != "ping"
        msgData = JSON.parse(msg.data)
        if msgData.event_type == "state_changed"
          sendEvent msgData
