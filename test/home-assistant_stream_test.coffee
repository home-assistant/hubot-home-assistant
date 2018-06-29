Helper = require 'hubot-test-helper'
chai = require 'chai'
nock = require 'nock'
fs = require 'fs'

expect = chai.expect

helper = new Helper [
  '../src/home-assistant-streaming.coffee'
]

# Alter time as test runs
originalDateNow = Date.now
mockDateNow = () ->
  return Date.parse('Fri Jun 22 2018 17:14:09 GMT-0500 (CDT)')

describe 'home-assistant streaming', ->
  beforeEach ->
    process.env.HUBOT_LOG_LEVEL='error'
    process.env.HUBOT_HOME_ASSISTANT_HOST='http://hassio.local:8123'
    process.env.HUBOT_HOME_ASSISTANT_API_PASSWORD='foobar'
    process.env.HUBOT_HOME_ASSISTANT_MONITOR_EVENTS='true'
    process.env.HUBOT_HOME_ASSISTANT_EVENTS_DESTINATION='room1'
    process.env.HUBOT_HOME_ASSISTANT_MONITOR_ALL_ENTITIES='true'
    Date.now = mockDateNow
    # nock.disableNetConnect()
    @room = helper.createRoom(httpd: false)

  afterEach ->
    delete process.env.HUBOT_LOG_LEVEL
    delete process.env.HUBOT_HOME_ASSISTANT_HOST
    delete process.env.HUBOT_HOME_ASSISTANT_API_PASSWORD
    delete process.env.HUBOT_HOME_ASSISTANT_MONITOR_EVENTS
    delete process.env.HUBOT_HOME_ASSISTANT_EVENTS_DESTINATION
    delete process.env.HUBOT_HOME_ASSISTANT_MONITOR_ALL_ENTITIES
    Date.now = originalDateNow
    # nock.cleanAll()
    @room.destroy()

  it 'receives a series of streamed events', (done) ->
    # SKIP: Not yet implemented (trouble with emulating EventSource call)
    return this.skip()

    nock('http://hassio.local:8123')
      .get('/api/stream')
      .reply(200, (uri, requestBody) ->
        fs.createReadStream(__dirname + '/fixtures/stream.txt')
      )

    selfRoom = @room
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          # ['hubot', '']
        ]
        done()
      catch err
        done err
      return
    , 1000)
