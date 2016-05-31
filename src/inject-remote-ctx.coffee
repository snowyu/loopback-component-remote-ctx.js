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
    if item.indexOf '.'
      methodBlackList.push item
    else
      modelBlackList.push item
  for item in WHITE_LIST
    if item.indexOf '.'
      methodWhiteList.push item
    else
      modelWhiteList.push item


  inject = (ctx, next) ->
    remoteCtx = hasHttpCtxOption(ctx.method.accepts) and ctx
    if remoteCtx
      ctx.args[ARG_NAME] = remoteCtx
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
    return unless vModelName in modelWhiteList
    return unless vMethodName in methodWhiteList
    return if vModelName in modelBlackList
    return if vMethodName in methodBlackList
    if !hasHttpCtxOption(method.accepts)
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

