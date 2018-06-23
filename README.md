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
| `HUBOT_HOME_ASSISTANT_API_PASSWORD`         | **Yes**   | The password for your Home Assistant instance. |
| `HUBOT_HOME_ASSISTANT_MONITOR_EVENTS`       | No        | If set to any value, whether to monitor for events |
| `HUBOT_HOME_ASSISTANT_MONITOR_ALL_ENTITIES` | No        | If set to any value, whether to monitor all entities for status changes |
| `HUBOT_HOME_ASSISTANT_EVENTS_DESTINATION`   | No        | Which room/channel/chat to send events, e.g. `#homeassistant` or `@alice`; default: `#home-assistant` |

## Commands:

### `hubot state of <friendly name of entity>`

Returns the current state of the entity

```
<alice> hubot state of Living Room Downlights
<hubot> @alice Living Room Downlights is off (since 2 hours ago)
```

### `hubot turn <friendly name of entity> <on|off>`

Turn the entity on/off.

```
<alice> hubot turn Living Room Downlights on
<hubot> @alice Living Room Downlights turned on
```

### `hubot set <friendly name of entity> to <new state>`

Set the entity state to the given value.

```
<alice> hubot set Bob's iPhone to home
<hubot> @alice Setting Bob's iPhone to home
<hubot> @alice Bob's iPhone set to home
```
