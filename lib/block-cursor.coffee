path = require 'path'

class BlockCursor
  styleElement: null

  config:
    cursorColor:
      description: 'color of the cursor'
      type: 'color'
      default: '#666'
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

  getStyle: ->
    @styleElement ?= document.createElement 'style'
    @styleElement.type = 'text/css'
    document.querySelector('head atom-styles').appendChild @styleElement
    @styleElement

  applyCursorColor: (color) ->
    stylesheet = @getStyle().sheet
    selector = '.block-cursor atom-text-editor::shadow .cursors .cursor'
    colorStr = "rgba(#{color.red}, #{color.green}, #{color.blue}, #{color.alpha})"
    stylesheet.deleteRule 0 if stylesheet.cssRules.length isnt 0
    stylesheet.insertRule "#{selector} { background-color: #{colorStr}; }", 0

  applyCursorBlink: (blinkEnabled) ->
    atomWorkspaceView = atom.views.getView atom.workspace
    if blinkEnabled
      atomWorkspaceView.classList.remove 'no-blink'
    else
      atomWorkspaceView.classList.add 'no-blink'

module.exports = new BlockCursor()