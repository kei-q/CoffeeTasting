# Client-side Code

# Bind to events
# SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
# SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

g_user = 'test'
g_editor = null
g_viewer = null

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  # Make a call to the server to retrieve a message
  SS.server.app.init (user) ->
    if user then $('#main').show() else displaySignInForm()

  SS.events.on 'newuser', addUser
  SS.events.on 'update', updateViewer

displaySignInForm = ->
  $('#signIn').show().submit ->
    SS.server.app.signIn $('#signIn').find('input').val() , ({user}) ->
      displayMainScreen user

displayMainScreen = (user) ->
  $('#signIn').fadeOut(230) and $('#main').show()
  $('#username').text("username: #{user}")

  g_editor = initEditor 'editor', 'coffee', false
  editor_js = initEditor 'editor-js', 'javascript'

  editorS = g_editor.getSession()
  editorS.on 'change', ->
    try
      source = editorS.getValue()
      compiled = CoffeeScript.compile(source, {bare: on})
      editor_js.getSession().setValue compiled
      SS.server.app.update source, (response) ->
    catch e
      console.log e

  g_viewer = initEditor 'viewer', 'coffee'
  viewer_js = initEditor 'viewer-js', 'javascript'

  viewerS = g_viewer.getSession()
  viewerS.on 'change', ->
    try
      compiled = CoffeeScript.compile(viewerS.getValue(), {bare: on})
      viewer_js.getSession().setValue compiled
    catch e
      console.log e

initEditor = (id, mode, readonly = true) ->
  editor = ace.edit id
  editor.setTheme 'ace/theme/twilight'
  {Mode} = require "ace/mode/#{mode}"
  editor.getSession().setMode(new Mode())
  editor.setReadOnly readonly
  editor

addUser = ({users}) ->
  $('#userlist').empty()
  for own user of users
    do (user) ->
      e = $("<li>#{user}</li>")
      e.appendTo $('#userlist')
      e.click ->
        e.css {backgroundColor: '#fedcba'}
        SS.server.app.requestSource user, (source) ->
          updateViewer g_user, source
        g_user = user

updateViewer = ({user, text}) ->
  if g_user is user
    g_viewer.getSession().setValue text

