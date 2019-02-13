# Hubot Home Assistant

[![npm version](https://badge.fury.io/js/hubot-home-assistant.svg)](http://badge.fury.io/js/hubot-home-assistant) [![Build Status](https://travis-ci.com/home-assistant/hubot-home-assistant.svg?branch=master)](https://travis-ci.com/home-assistant/hubot-home-assistant)

:speech_balloon: :house_with_garden: A Hubot module for interacting with Home Assistant via chat.

## Installation

In hubot project repo, run:

`npm install hubot-home-assistant --save`

Then add **hubot-home-assistant** to your `external-scripts.json`:

```json
[
  "hubot-home-assistant"
]
```

## Configuration:

| Variable                                    | Required? | Description        |
| ------------------------------------------- | :-------: | ------------------ |
| `HUBOT_HOME_ASSISTANT_HOST`                 | **Yes**   | The URL for your Home Assistant instance, e.g. `https://demo.home-assistant.io` or `http://hassio.local:8123`. |
| `HUBOT_HOME_ASSISTANT_API_TOKEN`            | **Yes**   | The long-lived access token for a Home Assistant user. |
| `HUBOT_HOME_ASSISTANT_MONITOR_EVENTS`       | No        | If set to any value, whether to monitor for events |
| `HUBOT_HOME_ASSISTANT_MONITOR_ALL_ENTITIES` | No        | If set to any value, whether to monitor all entities for status changes |
| `HUBOT_HOME_ASSISTANT_EVENTS_DESTINATION`   | No        | Which room/channel/chat to send events, e.g. `#homeassistant` or `@alice`; default: `#home-assistant` |

### Upgrading from v1.x?

The `HUBOT_HOME_ASSISTANT_API_PASSWORD` environment variable has been replaced by the `HUBOT_HOME_ASSISTANT_API_TOKEN`. You can obtain your long-lived access token in your `v0.77`+ instance of Home Assistant by clicking on your user icon in the navigation, scrolling to the section titled "Long-Lived Access Tokens," and clicking the "Create" button.

[Read more](https://developers.home-assistant.io/docs/en/auth_api.html#long-lived-access-token) about long-lived access tokens.

## Commands:

### List all entities

Returns the current state of the entity. Note that it uses the `hidden` attribute flag to reduce this list. It will also exclude Views and Zones.

```
<alice> hubot hass list
<hubot> sun.sun: Sun; camera.office: Office; camera.den: Den; group.commute: Commute; group.climate: Climate; ...
```

### Get the state of an entity

Returns the current state of the entity.

```
<alice> hubot hass state of Living Room Downlights
<hubot> @alice Living Room Downlights is off (since 2 hours ago)
```

### Toggle an entity on or off

Turn the entity on/off.

```
<alice> hubot hass turn Living Room Downlights on
<hubot> @alice Living Room Downlights turned on
```

### Set an entity to a desired state

Set the entity state to the given value.

```
<alice> hubot hass set Bob's iPhone to home
<hubot> @alice Setting Bob's iPhone to home
<hubot> @alice Bob's iPhone set to home
```

## Streaming Capabilities

In addition to directly interacting with Home Assistant, this package will allow you to stream entity status changes (e.g. turn a light on, home temperature rises, etc.) into a room/channel/user of your choice.

1. Set `HUBOT_HOME_ASSISTANT_MONITOR_EVENTS` to any value to enable streaming.
2. Set `HUBOT_HOME_ASSISTANT_EVENTS_DESTINATION` to where you want the messages to be seen. By default, they will go to a channel/room called `#home-assistant`.
3. Restart your Hubot

### Option 1 - Monitor Everything

Note that Home Assistant will send a lot of change events throughout the day if you have several components configured. For example, if you have a thermostat configured, it will send an event for every detected temperature change.

1. Set `HUBOT_HOME_ASSISTANT_MONITOR_ALL_ENTITIES` to any value.
2. Restart your Hubot

### Option 2 - Monitor Specific Devices

1. Ensure that `HUBOT_HOME_ASSISTANT_MONITOR_ALL_ENTITIES` is not set in the configuration.
2. Update your Home Assistant configuration under the `customize`, `customize_domain` or `customize_blob` key to include the `hubot_monitor: true` attribute. [See documentation](https://www.home-assistant.io/docs/configuration/customizing-devices/) for more details.
3. Restart your Hubot

**Examples:**

```yaml
homeassistant:

  #...

  # Set a specific device to monitor
  customize:
    climate.my_ecobee3:
      hubot_monitor: true

  # Monitor all devices in a particular domain
  customize_domain:
    alarm_control_panel:
      hubot_monitor: true
    light:
      hubot_monitor: true

  # Monitor devices matching a pattern
  customize_blob:
    "device_tracker.*_iphone":
      hubot_monitor: true
```
