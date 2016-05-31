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


### Usage

```js

Model.observe('access', function(ctx, next){
  console.log(ctx.options) //the remoteCtx
})

```


