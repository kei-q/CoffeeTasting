# Server-side Code

g_users = {}

exports.authenticate = true

exports.actions =

  init: (cb) ->
    @session.on 'disconnect', (session) ->
      delete g_users[session.user_id]
      session.user.logout()

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
    g_users[user] = true
    SS.publish.broadcast 'newuser', {users: g_users}
    cb {user: user}

  update: (text, cb) ->
    SS.publish.broadcast 'update', {user: @session.user_id, text: text}
    cb true

