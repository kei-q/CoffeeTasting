# Client-side Code

g_editor = null
g_viewer = null

exports.init = ->
  SS.server.app.init (user) -> displaySignInForm()

  SS.events.on 'addUser', addUser
  SS.events.on 'remUser', remUser
  SS.events.on 'update', updateViewer

displaySignInForm = ->
  $('#signIn').show().submit ->
    SS.server.app.signIn $('#signIn').find('input').val(), displayMainScreen
    false

displayMainScreen = (user) ->
  $('#signIn').fadeOut(230) and $('#main').show()
  $('#username').text("username: #{user}")

  SS.server.app.getUserList (users) ->
    users.forEach addUser

  g_editor = initEditor 'editor', 'coffee'
  editor_js = initEditor 'editor-js', 'javascript'
  compile g_editor, editor_js, (source) ->
    SS.server.app.update source, (response) ->

  g_viewer = initEditor 'viewer', 'coffee'
  viewer_js = initEditor 'viewer-js', 'javascript'
  compile g_viewer, viewer_js

initEditor = (id, mode) ->
  editor = ace.edit id
  editor.setTheme 'ace/theme/twilight'
  {Mode} = require "ace/mode/#{mode}"
  editor.getSession().setMode(new Mode())
  editor

compile = (from, to, block) ->
  from.getSession().on 'change', ->
    try
      source = from.getSession().getValue()
      compiled = CoffeeScript.compile source, {bare: on}
      to.getSession().setValue compiled
      block?(source)
    catch e
      console.log e

addUser = (user) ->
   e = $("<li>#{user}</li>").addClass("user-#{user}").addClass('username')
   e.appendTo $('#userlist')
   e.click ->
     $('.username').removeClass 'selected'
     e.addClass 'selected'
     SS.server.app.subscribe user, updateViewer

remUser = (user) ->
  $(".user-#{user}").remove()

updateViewer = (text) ->
  g_viewer.getSession().setValue text

