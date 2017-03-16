'use strict'
debug = require('debug')('loopback:component:remoteCtx')
injectRemoteCtx = require('./inject-remote-ctx')

module.exports = (app, options) ->
  debug 'initializing component'
  loopback = app.loopback
  # loopbackMajor = loopback and loopback.version and loopback.version.split('.')[0] or 1

  if !options or options.enabled isnt false
    injectRemoteCtx(app, options)
  else
    debug 'component not enabled.'
  return
