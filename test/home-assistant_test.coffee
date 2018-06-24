Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'

expect = chai.expect

helper = new Helper [
  '../src/home-assistant.coffee',
  '../src/home-assistant-streaming.coffee'
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

  it 'gets the state of a particular device', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot state of Den')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot state of Den']
          ['hubot', '@alice Den is idle (since 8 hours ago)']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'returns an error if when friendly name not found to get state', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot state of Not Found Device')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot state of Not Found Device']
          ['hubot', 'No device found with that name!']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'turns a device on', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')
    nock('http://hassio.local:8123')
      .post('/api/services/turn_on/homeassistant')
      .replyWithFile(200, __dirname + '/fixtures/device-turn_on.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot turn Living Room Downlights on')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot turn Living Room Downlights on']
          ['hubot', '@alice Living Room Downlights turned on']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'returns an error when friendly name not found to turn on', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot turn Does Not Exist on')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot turn Does Not Exist on']
          ['hubot', 'No device found with that name!']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'sets a device tracker to home', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')
    nock('http://hassio.local:8123')
      .post('/api/services/stephens_iphone_6/device_tracker')
      .replyWithFile(200, __dirname + '/fixtures/device-tracker-set_home.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot set Stephen\'s iPhone 6 to home')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot set Stephen\'s iPhone 6 to home']
          ['hubot', '@alice Setting Stephen\'s iPhone 6 to home']
          ['hubot', '@alice Stephen\'s iPhone 6 set to home']
        ]
        done()
      catch err
        done err
      return
    , 1000)

  it 'returns an error when friendly name not found for device tracker', (done) ->
    nock('http://hassio.local:8123')
      .get('/api/states')
      .replyWithFile(200, __dirname + '/fixtures/states.json')

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot set Does Not Exist to home')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot set Does Not Exist to home']
          ['hubot', '@alice Setting Does Not Exist to home']
          ['hubot', 'No device found with that name!']
        ]
        done()
      catch err
        done err
      return
    , 1000)
