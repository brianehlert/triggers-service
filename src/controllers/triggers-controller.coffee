_ = require 'lodash'
MeshbluHttp = require 'meshblu-http'
TriggerParser = require '../helpers/trigger-parser'

class TriggersController
  constructor: ({@meshbluConfig}) ->

  allTriggers: (req, res) =>
    meshbluAuth = req.meshbluAuth ? {}
    meshbluConfig = _.defaults meshbluAuth, @meshbluConfig
    meshbluHttp = new MeshbluHttp meshbluConfig
    meshbluHttp.devices type: 'octoblu:flow', (error, body) =>
      return res.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return res.status(error.code ? 500).send(error.message) if error?

      triggers = TriggerParser.parseTriggersFromDevices body.devices
      return res.status(200).json(triggers)

  myTriggers: (req, res) =>
    meshbluAuth = req.meshbluAuth ? {}
    meshbluConfig = _.defaults meshbluAuth, @meshbluConfig
    meshbluHttp = new MeshbluHttp meshbluConfig
    meshbluHttp.devices type: 'octoblu:flow', owner: meshbluConfig.uuid, (error, body) =>
      return res.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return res.status(error.code ? 500).send(error.message) if error?

      triggers = TriggerParser.parseTriggersFromDevices body.devices
      return res.status(200).json(triggers)

  sendMessage: (req, res) =>
    {flowId, triggerId} = req.params

    meshbluAuth = req.meshbluAuth ? {}
    meshbluConfig = _.defaults meshbluAuth, @meshbluConfig
    meshbluHttp = new MeshbluHttp meshbluConfig

    message =
      devices: [flowId]
      topic: 'triggers-service'
      payload:
        from: triggerId
        params: _.extend {}, req.body, req.query

    meshbluHttp.message message, (error, body) =>
      return res.status(401).json(error: 'unauthorized') if error?.message == 'unauthorized'
      return res.status(error.code ? 500).send(error.message) if error?
      return res.status(201).json(body)

module.exports = TriggersController
