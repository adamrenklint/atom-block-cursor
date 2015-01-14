path = require 'path'

class BlockCursor
  cursorColorStyleElement = null

  config:
    cursorColor:
      description: 'Color of the cursor'
      type: 'color'
      default: '#666'
    cursorBlink:
      description: 'Enable/disable cursor blink'
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

  getCursorColorStyleElement: ->
    return cursorColorStyleElement if cursorColorStyleElement?
    cursorColorStyleElement = document.createElement 'style'
    cursorColorStyleElement.type = 'text/css'
    document.querySelector('head atom-styles').appendChild cursorColorStyleElement
    return cursorColorStyleElement

  applyCursorColor: (color) ->
    stylesheet = @getCursorColorStyleElement().sheet
    selector = '.block-cursor atom-text-editor::shadow .cursors .cursor'
    stylesheet.deleteRule 0 if stylesheet.cssRules.length isnt 0
    stylesheet.insertRule "#{selector} { background-color: #{color.toHexString()}; }", 0

  applyCursorBlink: (blinkEnabled) ->
    atomWorkspaceView = atom.views.getView atom.workspace
    if blinkEnabled
      atomWorkspaceView.classList.remove 'block-cursor-no-blink'
    else
      atomWorkspaceView.classList.add 'block-cursor-no-blink'

module.exports = new BlockCursor()