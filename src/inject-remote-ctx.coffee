###
Usage on operator hooks:
 the `ctx.options` is the remoteCtx.
    console.log('remoteCtx', ctx.options.remoteCtx.req.currentUser)

###

debug       = require('debug')('loopback:component:remoteCtx')
isFunction  = require 'util-ex/lib/is/type/function'
extend      = require 'util-ex/lib/_extend'
semver      = require 'semver'

module.exports = (app, options) ->
  loopback    = app.loopback
  unless semver.gte loopback.version, '2.37.0'
    throw new Error('loopback-component-remeote-ctx requires loopback 2.37.0 or newer')

  ARG_NAME    = options.argName || 'remoteCtx'
  # REMOTE_ARG  = ARG_NAME # the loopback internal used the options always, so.....
  REMOTE_ARG  = 'options' # DONT CHANGE!!
  BLACK_LIST  = options.blackList || []
  WHITE_LIST  = options.whiteList || []

  methodBlackList = []
  methodWhiteList = []
  modelBlackList = []
  modelWhiteList = []

  for item in BLACK_LIST
    if item.indexOf('.') isnt -1
      methodBlackList.push item
    else
      modelBlackList.push item
  for item in WHITE_LIST
    if item.indexOf('.') isnt -1
      methodWhiteList.push item
    else
      modelWhiteList.push item

  for Model in app.models()
    vModelName = Model.modelName
    continue unless !modelWhiteList.length or vModelName in modelWhiteList
    continue if modelBlackList.length and vModelName in modelBlackList
    Model.createOptionsFromRemotingContext = (ctx)->
      result = {accessToken: ctx.req.accessToken}
      result[ARG_NAME] = ctx
      result


  debug 'argName:%s', ARG_NAME
  debug 'methodBlackList: %s', methodBlackList
  debug 'methodWhiteList: %s', methodWhiteList
  debug 'modelBlackList: %s', modelBlackList
  debug 'modelWhiteList: %s', modelWhiteList

  hasHttpCtxOption = (accepts) ->
    i = 0
    while i < accepts.length
      argDesc = accepts[i]
      if argDesc.arg == 'options' and argDesc.http and
      (argDesc.http == 'optionsFromRequest' or
      (isFunction(argDesc.http) && argDesc.http.name == 'createOptionsViaModelMethod')
      )
        return true
      i++
    return

  unless process.env.GENERATING_SDK
    # unfortunately this requires us to add the options object
    # to the remote method definition
    app.remotes().methods().forEach (method) ->
      vModelName = method.sharedClass.name
      vMethodName = method.stringName
      return unless !modelWhiteList.length or vModelName in modelWhiteList
      return unless !methodWhiteList.length or vMethodName in methodWhiteList
      return if modelBlackList.length and vModelName in modelBlackList
      return if methodBlackList.length and vMethodName in methodBlackList
      if !hasHttpCtxOption(method.accepts)
        debug 'method %s injected.', vMethodName
        method.accepts.push
          arg: REMOTE_ARG
          description: '**Do not implement in clients**.'
          type: Object
          # http: 'optionsFromRequest'
          # too late herer so tricky from lib/model.js
          http: `function createOptionsViaModelMethod(ctx){
                var EMPTY_OPTIONS = {};
                var ModelCtor = ctx.method && ctx.method.ctor;
                if (!ModelCtor)
                  return EMPTY_OPTIONS;
                if (typeof ModelCtor.createOptionsFromRemotingContext !== 'function')
                  return EMPTY_OPTIONS;
                debug('createOptionsFromRemotingContext for %s', ctx.method.stringName);
                return ModelCtor.createOptionsFromRemotingContext(ctx);
                }`
      return
  return

