path = require 'path'

class BlockCursor
  styleElement: null

  config:
    cursorColor:
      description: 'color of the cursor (#XXXXXX)'
      type: 'string'
      default: ''
    cursorBlink:
      description: 'enable/disable cursor blink'
      type: 'boolean'
      default: false

  activate: ->
    atomWorkspaceView = atom.views.getView atom.workspace
    atomWorkspaceView.classList.add 'block-cursor'

    @cursorColorObserveSubscription =
      atom.config.observe 'block-cursor.cursorColor', (val) => @applyCursorColor val
    @cursorBlinkObserveSubscription =
      atom.config.observe 'block-cursor.cursorBlink', (val) => @applyCursorBlink val

  deactivate: ->
    atomWorkspaceView = atom.views.getView atom.workspace
    atomWorkspaceView.classList.add 'block-cursor'

    @cursorColorObserveSubscription.dispose()
    @cursorBlinkObserveSubscription.dispose()

  applyCursorColor: (color) ->
    style = @getStyle()
    selector = '.block-cursor atom-text-editor::shadow .cursors .cursor'
    style.sheet.deleteRule 0 if style.sheet.cssRules.length isnt 0
    style.sheet.insertRule "#{selector} { background-color: #{color}; }", 0

  getStyle: ->
    @styleElement ?= document.createElement 'style'
    @styleElement.type = 'text/css'
    document.querySelector('head atom-styles').appendChild @styleElement
    @styleElement

  applyCursorBlink: (blinkEnabled) ->
    atomWorkspaceView = atom.views.getView atom.workspace
    if blinkEnabled
      atomWorkspaceView.classList.remove 'no-blink'
    else
      atomWorkspaceView.classList.add 'no-blink'

module.exports = new BlockCursor()