# Server-side Code

exports.authenticate = true

exports.actions =
  init: (cb) ->
    @session.on 'disconnect', (session) ->
      SS.publish.broadcast 'remUser', session.user_id
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
    SS.publish.broadcast 'addUser', {user: user}
    cb {user: user}

  update: (text, cb) ->
    SS.publish.channel @session.user_id, 'update', {text: text}
    cb true

  subscribe: (user, cb) ->
    @session.channel.unsubscribe @session.channel.list()
    @session.channel.subscribe user, cb

  getUserList: (cb) ->
    SS.users.online.now cb
