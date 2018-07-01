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
  return Date.parse('Fri Jun 22 2018 17:14:09 GMT-0500 (CDT)')

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
          ['hubot', '@alice Den is idle (since 8 hours ago)']
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
          ['hubot', '@alice Den is off (since 2 hours ago)']
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
