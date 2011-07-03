# Server-side Code

g_users = []

exports.authenticate = true

exports.actions =

  init: (cb) ->
    @session.on 'disconnect', (session) ->
      # TODO: removeメソッド無いので実装すること
      g_users.remove session.user_id
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
    g_users.push user
    g_users.unique()
    cb {user: user, users: g_users}


