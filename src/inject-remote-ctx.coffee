###
Usage on operator hooks:
 the `ctx.options` is the remoteCtx.
    console.log('remoteCtx', ctx.options.remoteCtx.req.currentUser)

###

debug       = require('debug')('loopback:component:remoteCtx')
isFunction  = require 'util-ex/lib/is/type/function'

module.exports = (app, options) ->
  ARG_NAME    = options.argName || 'remoteCtx'
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

  debug 'argName:%s', ARG_NAME
  debug 'methodBlackList: %s', methodBlackList
  debug 'methodWhiteList: %s', methodWhiteList
  debug 'modelBlackList: %s', modelBlackList
  debug 'modelWhiteList: %s', modelWhiteList

  inject = (ctx, next) ->
    remoteCtx = hasHttpCtxOption(ctx.method.accepts) and ctx
    if remoteCtx
      vOptions = remoteCtx.options || {}
      vOptions[ARG_NAME] = remoteCtx
      ctx.args[ARG_NAME] = vOptions
    next()
    return

  hasHttpCtxOption = (accepts) ->
    i = 0
    while i < accepts.length
      argDesc = accepts[i]
      if argDesc.arg == ARG_NAME and argDesc.injectCtx
        return true
      i++
    return

  app.remotes().before '**', (ctx, instance, next) ->
    if isFunction(instance)
      next = instance
    inject ctx, next
    return
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
        arg: ARG_NAME
        description: '**Do not implement in clients**.'
        type: Object
        injectCtx: true
        source: 'context'
    return
  return

###
Contractor.afterRemote('**', function (ctx, next) {
  var Contract = Contractor.app.models.Contract
  var filter = {};
  var options = ctx;
  // the example above was also missing the `err` argument
  Contract.find(filter, options, function (err, contracts) {
    console.log(contracts);
  });
});
###

