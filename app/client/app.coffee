# Client-side Code

# Bind to events
# SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
# SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  # Make a call to the server to retrieve a message
  SS.server.app.init (user) ->
    if user then $('#main').show() else displaySignInForm()


initEditor = (id, mode) ->
  editor = ace.edit id
  editor.setTheme 'ace/theme/twilight'
  Mode = require("ace/mode/#{mode}").Mode
  editor.getSession().setMode(new Mode())
  editor

displaySignInForm = ->
  $('#signIn').show().submit ->
    username = $('#signIn').find('input').val()
    SS.server.app.signIn username, ({user, users}) ->
      for tmp in users
        e = $("<li>#{tmp}</li>")
        e.appendTo $('#userlist')
      displayMainScreen(user)
    false

displayMainScreen = (user) ->
  $('#signIn').fadeOut(230) and $('#main').show()
  $('#username').text("username: #{user}")

  editor = initEditor 'editor', 'coffee'
  editor_js = initEditor 'editor-js', 'javascript'
  editor.getSession().on 'change', ->
    try
      compiled = CoffeeScript.compile(editor.getSession().getValue(), {bare: on})
      editor_js.getSession().setValue compiled
    catch e
      console.log e
