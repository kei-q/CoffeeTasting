# Server-side Code

exports.actions =

  init: (cb) ->
    if @session.user_id
      R.get "user:#{@session.user_id}", (err, data) =>
        if data
          cb data
        else
          cb false
    else
      cb false

  signIn: (user, cb) ->
    @session.setUserId user
    cb user


