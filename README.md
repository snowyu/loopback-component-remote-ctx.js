# Loopback Component Remote context

This loopback component enables you to add the remote context to the specified remote methods of the loopback application.


Note: this hack would add a new argument to the remote method.


### Installation

1. Install in you loopback project:

  `npm install --save loopback-component-remote-ctx`

2. Create a component-config.json file in your server folder (if you don't already have one)

3. Configure options inside `component-config.json`:

  ```json
  {
    "loopback-component-remote-ctx": {
      "enabled": true,
      "whiteList": ["YourModel", "OrYourModel.remoteMethod"],
      "blackList": ["YourModel", "OrYourModel.remoteMethod"],
      "argName": "remoteCtx"
    }
  }
  ```
  - `enabled` *[Boolean]*: whether enable this component. *defaults: true*
  - `whiteList` *[Array of String]* : Only add the remote context to these methods
  - `blackList` *[Array of String]* : Don't add the remote context to these methods.
  - `argName` *[String]*: the new argument name added to remote method. *defaults: remoteCtx*


Note: the `options` argument of remote method is always be inject. DO NOT USE `options` as the argument name.

### Usage

```js

Model.observe('access', function(ctx, next){
  console.log(ctx.options.remoteCtx) //the remoteCtx
})

Model.beforeRemote('*', function(ctx, next){
  Model.findById('id', null, {remoteCtx: ctx}, function(err, result){
    if (err) return next(err);
    next(result);
  })
})

Model.yourRemoteMethod = function(msg, ctx){
  //if your write this before injected via the component:
  return Model.findById('id', null, ctx)
  //else should be this, your controller::
  // return Model.findById('id', null, {remoteCtx: ctx})
}

Model.remoteMethod(
  'yourRemoteMethod',
  {
    accepts: [
      {arg: 'msg', type: String},
      {arg: 'ctx', type: Object, http:{source: 'context'} }
    ],
    returns: {arg: 'greeting', type: 'string'}
  }
);

```
**NOTE**: the options argument of the model's method is an undocument and it should be added before callback.






### History


* v0.2.0

* **broken**:  put the remote context to the options.remoteCtx instead of options.
* [bug] the original options of the model method is lost.


### Refs

* https://github.com/strongloop/loopback/issues/1495
