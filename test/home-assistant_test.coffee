Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'

expect = chai.expect

helper = new Helper [
  '../src/home-assistant.coffee'
]

# Alter time as test runs
originalDateNow = Date.now
mockDateNow = () ->
  return Date.parse('Mon Jul 02 2018 16:00:56 GMT-0500 (CDT)')

describe 'home-assistant', ->
  beforeEach ->
    process.env.HUBOT_LOG_LEVEL='error'
    process.env.HUBOT_HOME_ASSISTANT_HOST='http://hassio.local:8123'
    process.env.HUBOT_HOME_ASSISTANT_API_PASSWORD='foobar'
    Date.now = mockDateNow
    nock.disableNetConnect()
    @room = helper.createRoom()

  afterEach ->
    delete process.env.HUBOT_LOG_LEVEL
    delete process.env.HUBOT_HOME_ASSISTANT_HOST
    delete process.env.HUBOT_HOME_ASSISTANT_API_PASSWORD
    Date.now = originalDateNow
    nock.cleanAll()
    @room.destroy()

  it 'get the current state of all entities', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass list')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass list']
          ['hubot', "sun.sun: Sun; camera.office: Office; camera.den: Den; group.commute: Commute; group.climate: Climate; group.living_room: Living Room; group.living_room_downlights: Living Room Downlights; group.hallway: Hallway; group.hallway_light: Hallway Light; group.den: Den; group.den_light: Den Light; group.bedroom: Bedroom; group.second_bedroom: Second Bedroom; group.dining_room: Dining Room; group.dining_room_light: Dining Room Light; group.kitchen: Kitchen; group.kitchen_fan: Kitchen Fan; group.office: Office; group.outdoor: Outdoor; group.whois: Domains; group.speedtest: Speedtest; light.nightstand: Nightstand; light.living_room_downlight_6: Living Room Downlight; light.living_room_downlight_2: Living Room Downlight; light.right_end_table: Right End Table; light.kitchen_fan_2: Kitchen Fan; light.dining_room_3: Dining Room; light.dining_room_2: Dining Room; light.kitchen_fan: Kitchen Fan; light.hallway_2: Hallway; light.den: Den; light.left_end_table: Left End Table; light.living_room_downlight_5: Living Room Downlight; light.living_room_downlight_4: Living Room Downlight; light.den_2: Den; light.kitchen_sink: Kitchen Sink; light.dining_room: Dining Room; light.hallway: Hallway; light.living_room_downlight: Living Room Downlight; light.living_room_downlight_3: Living Room Downlight; light.hallway_3: Hallway; light.xmasactivegroup: xmasActiveGroup; light.den_3: Den; light.afred_hue_group: Afred Hue Group; light.bedroom: Bedroom; light.living_room: Living Room; light.office: Office; light.kitchen: Kitchen; light.dining_room_4: Dining Room; light.front_porch: Front Porch; light.xmasactivegroupeven: xmasActiveGroupEven; light.xmasactivegroupodd: xmasActiveGroupOdd; climate.my_ecobee3: My ecobee3; weather.my_ecobee3: My ecobee3; binary_sensor.den_occupancy: Den Occupancy; binary_sensor.second_bedroom_occupancy: Second Bedroom Occupancy; binary_sensor.bedroom_occupancy: Bedroom Occupancy; binary_sensor.my_ecobee3_occupancy: Hallway Occupancy; binary_sensor.living_room_occupancy: Living Room Occupancy; binary_sensor.office_occupancy: Office Occupancy; media_player.living_room_apple_tv: Living Room Apple TV; media_player.bedroom_apple_tv: Bedroom Apple TV; remote.living_room_apple_tv: Living Room Apple TV; remote.bedroom_apple_tv: Bedroom Apple TV; switch.porch_outlet: Porch Outlet; sensor.strangepursuitnet: strangepursuit.net; sensor.allergy_index_yesterday: Allergy Index: Yesterday; sensor.allergy_index_tomorrow: Allergy Index: Tomorrow; sensor.allergy_index_forecasted_average: Allergy Index: Forecasted Average; sensor.allergy_index_historical_average: Allergy Index: Historical Average; sensor.cold__flu_forecasted_average: Cold & Flu: Forecasted Average; sensor.allergy_index_today: Allergy Index: Today; sensor.unanimously: unanimous.ly; sensor.yeargin: yearg.in; sensor.yourliberalfriendscom: yourliberalfriends.com; sensor.speedtest_download: Speedtest Download; sensor.speedtest_ping: Speedtest Ping; sensor.speedtest_upload: Speedtest Upload; sensor.next_35_bus: Next #3/#5 Bus; sensor.myseatsharecom: myseatshare.com; sensor.samanthaycom: samantha-y.com; sensor.samanthaycom_2: samanthay.com; sensor.seatshare: seatsha.re; sensor.slyeargincom: slyeargin.com; sensor.dark_sky_overnight_low_temperature: Dark Sky Overnight Low Temperature; sensor.dark_sky_nearest_storm_distance: Nearest Storm Distance; sensor.dark_sky_minutely_summary: Weather; sensor.dark_sky_temperature: Temperature; sensor.dark_sky_hourly_summary: Dark Sky Hourly Summary; sensor.dark_sky_daytime_high_temperature: Dark Sky Daytime High Temperature; sensor.stephenyeargincom: stephenyeargin.com; sensor.my_ecobee3_temperature: Avg. Home Temp.; sensor.den_temperature: Den Temperature; sensor.living_room_temperature: Living Room Temperature; sensor.second_bedroom_temperature: Second Bedroom Temperature; sensor.office_temperature: Office Temperature; sensor.bedroom_temperature: Bedroom Temperature; sensor.my_ecobee3_humidity: Humidity; alarm_control_panel.simplisafe: SimpliSafe; device_tracker.stephens_macbook_air_wireless: Stephen's MacBook Air (Wireless); device_tracker.playstation_4: PlayStation 4; device_tracker.living_room_apple_tv_lan: Living Room Apple TV (LAN); device_tracker.wd_mybook_live: WD MyBook Live; device_tracker.samanthas_macbook_air: Samantha's MacBook Air; device_tracker.airport_extreme_lan: Airport Extreme (LAN); device_tracker.home_hue: Home Hue; device_tracker.home_assistant_lan: Home Assistant (LAN); device_tracker.cloud_key: Cloud Key; device_tracker.pistephenyeargincom_wireless: pi.stephenyeargin.com (Wireless); device_tracker.ecobee3: ecobee3; device_tracker.stephens_iphone_6: Stephen's iPhone 6; device_tracker.office_raspi_camera_wireless: Office Raspi Camera (Wireless); device_tracker.bedroom_apple_tv_wireless: Bedroom Apple TV (Wireless); device_tracker.withings_scale: Withings Scale; device_tracker.samanthas_work_macbook_pro: Samantha's Work MacBook Pro; device_tracker.stephens_work_macbook_pro: Stephen's Work MacBook Pro; device_tracker.tplink_av2000_2: TP-Link AV2000 2; device_tracker.tplink_av2000_1: TP-Link AV2000 1; sensor.stephens_iphone_6_battery_level: Stephen's iPhone 6 Battery Level; sensor.stephens_iphone_6_battery_state: Stephen's iPhone 6 Battery State"]
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'gets state of an entity by friendly name', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass state of Den')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass state of Den']
          ['hubot', '@alice Den is idle (since an hour ago)']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'gets state of an entity by entity_id', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass state of light.den')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass state of light.den']
          ['hubot', '@alice Den is on (since an hour ago)']
        ]
        done()
      catch err
        done err
      return
    , 1000)


  it 'returns an error for getting state of missing entity', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass state of Not Found Device')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass state of Not Found Device']
          ['hubot', 'No device found with that name!']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'turns an entity on by friendly name', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')
    nock('http://hassio.local:8123')
      .post('/api/services/light/turn_on')
      .replyWithFile(200, __dirname + '/fixtures/device-turn_on.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass turn Nightstand on')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass turn Nightstand on']
          ['hubot', '@alice Nightstand turned on']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'turns an entity on by entity_id', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')
    nock('http://hassio.local:8123')
      .post('/api/services/light/turn_on')
      .replyWithFile(200, __dirname + '/fixtures/device-turn_on.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass turn light.nightstand on')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass turn light.nightstand on']
          ['hubot', '@alice Nightstand turned on']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'returns an error when turning on missing entity', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass turn Does Not Exist on')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass turn Does Not Exist on']
          ['hubot', 'No device found with that name!']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'set entity state', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')
    nock('http://hassio.local:8123')
      .post('/api/services/stephens_iphone_6/device_tracker')
      .replyWithFile(200, __dirname + '/fixtures/device-tracker-set_home.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass set Stephen\'s iPhone 6 to home')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass set Stephen\'s iPhone 6 to home']
          ['hubot', '@alice Setting Stephen\'s iPhone 6 to home']
          ['hubot', '@alice Stephen\'s iPhone 6 set to home']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'returns an error when setting state of missing entity', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot hass set Does Not Exist to home')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot hass set Does Not Exist to home']
          ['hubot', '@alice Setting Does Not Exist to home']
          ['hubot', 'No device found with that name!']
        ]
        done()
      catch err
        done err
      return
    , 1000)
