# Client-side Code

# Bind to events
# SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
# SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

g_user = 'test'
g_viewer = null

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  # Make a call to the server to retrieve a message
  SS.server.app.init (user) ->
    if user then $('#main').show() else displaySignInForm()

  SS.events.on 'newuser', addUser
  SS.events.on 'update', updateViewer


initEditor = (id, mode) ->
  editor = ace.edit id
  editor.setTheme 'ace/theme/twilight'
  Mode = require("ace/mode/#{mode}").Mode
  editor.getSession().setMode(new Mode())
  editor

displaySignInForm = ->
  $('#signIn').show().submit ->
    username = $('#signIn').find('input').val()
    SS.server.app.signIn username, ({users}) ->
      displayMainScreen(username)
    false

displayMainScreen = (user) ->
  $('#signIn').fadeOut(230) and $('#main').show()
  $('#username').text("username: #{user}")

  editor = initEditor 'editor', 'coffee'
  editor_js = initEditor 'editor-js', 'javascript'
  editor_js.setReadOnly true
  editor.getSession().on 'change', ->
    try
      source = editor.getSession().getValue()
      compiled = CoffeeScript.compile(source, {bare: on})
      editor_js.getSession().setValue compiled
      SS.server.app.update source, (response) ->
    catch e
      console.log e

  g_viewer = initEditor 'viewer', 'coffee'
  viewer_js = initEditor 'viewer-js', 'javascript'
  g_viewer.setReadOnly true
  viewer_js.setReadOnly true
  g_viewer.getSession().on 'change', ->
    try
      compiled = CoffeeScript.compile(g_viewer.getSession().getValue(), {bare: on})
      viewer_js.getSession().setValue compiled
    catch e
      console.log e


addUser = ({users}) ->
  $('#userlist').empty()
  for user in users
    do (user) ->
      e = $("<li>#{user}</li>")
      e.appendTo $('#userlist')
      e.click ->
        g_user = user

updateViewer = ({user, text}) ->
  console.log user
  if g_user is user
    g_viewer.getSession().setValue text
