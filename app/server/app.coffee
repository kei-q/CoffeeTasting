# Server-side Code

exports.authenticate = true

exports.actions =
  init: (cb) ->
    @session.on 'disconnect', (session) ->
      SS.publish.broadcast 'remUser', session.user_id
      session.user.logout()

    cb true

  signIn: (user, cb) ->
    @session.setUserId user
    R.set "code:#{user}", ''
    SS.publish.broadcast 'addUser', user
    cb user

  update: (text, cb) ->
    SS.publish.channel @session.user_id, 'update', text
    R.set "code:#{@session.user_id}", text
    cb true

  subscribe: (user, cb) ->
    R.get "code:#{user}", (err, data) -> cb data
    @session.channel.unsubscribe @session.channel.list()
    @session.channel.subscribe user, cb

  getUserList: SS.users.online.now
