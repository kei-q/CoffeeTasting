# Client-side Code

# Bind to events
# SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
# SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

g_editor = null
g_viewer = null

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  SS.server.app.init (user) -> displaySignInForm()

  SS.events.on 'addUser', addUser
  SS.events.on 'remUser', remUser
  SS.events.on 'update', updateViewer

displaySignInForm = ->
  $('#signIn').show().submit ->
    SS.server.app.signIn $('#signIn').find('input').val(), displayMainScreen
    false

displayMainScreen = ({user}) ->
  $('#signIn').fadeOut(230) and $('#main').show()
  $('#username').text("username: #{user}")
  SS.server.app.getUserList (users) ->
    addUser {user: user} for user in users
  SS.server.app.subscribe user, updateViewer

  g_editor = initEditor 'editor', 'coffee'
  editor_js = initEditor 'editor-js', 'javascript'

  g_editor.getSession().on 'change', ->
    try
      source = g_editor.getSession().getValue()
      compiled = CoffeeScript.compile(source, {bare: on})
      editor_js.getSession().setValue compiled
      SS.server.app.update source, (response) ->
    catch e
      console.log e

  g_viewer = initEditor 'viewer', 'coffee'
  viewer_js = initEditor 'viewer-js', 'javascript'

  g_viewer.getSession().on 'change', ->
    try
      compiled = CoffeeScript.compile(g_viewer.getSession().getValue(), {bare: on})
      viewer_js.getSession().setValue compiled
    catch e
      console.log e

initEditor = (id, mode) ->
  editor = ace.edit id
  editor.setTheme 'ace/theme/twilight'
  {Mode} = require "ace/mode/#{mode}"
  editor.getSession().setMode(new Mode())
  editor

addUser = ({user}) ->
   e = $("<li>#{user}</li>").addClass("user-#{user}")
   e.appendTo $('#userlist')
   e.click ->
     e.css {backgroundColor: '#fedcba'}
     SS.server.app.subscribe user, updateViewer

remUser = (user) ->
  $(".user-#{user}").remove()

updateViewer = ({text}) ->
  g_viewer.getSession().setValue text

