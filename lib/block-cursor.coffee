'use strict'
{CompositeDisposable} = require 'atom'

class BlockCursor
  cursorStyle = null
  cursorTypeMap =
    '\u25AE - Block': 'block'
    '\u25AF - Bordered box': 'bordered-box'
    '| - I-beam': 'i-beam'
    '_ - Underline': 'underline'
  primarySelector = 'atom-text-editor::shadow .cursors .cursor'
  secondarySelector = 'atom-text-editor::shadow .cursors.blink-off .cursor'

  config:
    cursorType:
      type: 'string'
      default: '\u25AE - Block'
      enum: (key for own key of cursorTypeMap)
    primaryColor:
      description: 'Primary color of the cursor'
      type: 'color'
      default: '#393939'
    secondaryColor:
      description: 'Secondary color of the cursor'
      type: 'color'
      default: 'transparent'
    blinkInterval:
      description: 'Cursor blinking interval in milliseconds. Set to 0 to disable blinking. Doesn\'t work for mini editors, except for disabling cursor blinking'
      type: 'integer'
      default: 800
      minimum: 0
    pulseDuration:
      description: 'Duration of the pulse transition in milliseconds, set to 0 to disable pulse'
      type: 'integer'
      default: 0
      minimum: 0
    cursorThickness:
      description: 'Thickness of the cursor in pixels. Doesn\'t apply to "block" cursor type'
      type: 'integer'
      default: 1
      minimum: 1
    zzzpreview:
      title: 'Preview'
      description: 'This field does nothing, it\'s just here to preview your cursor'
      type: 'string'
      default: ''

  activate: ->
    @subs = new CompositeDisposable()
    @subs.add [
      atom.config.observe 'block-cursor.cursorType', @applyCursorType
      atom.config.observe 'block-cursor.primaryColor', @applyPrimaryColor
      atom.config.observe 'block-cursor.secondaryColor', @applySecondaryColor
      atom.config.observe 'block-cursor.blinkInterval', @applyBlinkInterval.bind @
      atom.config.observe 'block-cursor.pulseDuration', @applyPulseDuration
      atom.config.observe 'block-cursor.cursorThickness', @applyCursorThickness
    ]
    atom.config.set 'block-cursor.zzzpreview', 'The quick brown fox jumps over the lazy dog'

  deactivate: ->
    @subs.dispose()
    if cursorStyle?
      cursorStyle.parentNode.removeChild cursorStyle
      cursorStyle = null

  applyCursorType: (cursorTypeName) ->
    cursorType = cursorTypeMap[cursorTypeName] ? cursorTypeName
    workspaceView = atom.views.getView atom.workspace
    workspaceView.className = workspaceView.className.replace /block-cursor-(block|bordered-box|i-beam|underline)/, ''
    workspaceView.className += " block-cursor-#{cursorType}"

  applyPrimaryColor: (color) =>
    color = color.toRGBAString?() or @toRGBAString color
    @updateStylesheet primarySelector, 'background-color', color
    @updateStylesheet primarySelector, 'border-color', color

  applySecondaryColor: (color) =>
    if atom.config.get 'block-cursor.blinkInterval' is 0
      color = atom.config.get 'block-cursor.primaryColor'
    color = color.toRGBAString?() or @toRGBAString color
    @updateStylesheet secondarySelector, 'background-color', color
    @updateStylesheet secondarySelector, 'border-color', color

  applyBlinkInterval: do ->
    sub = null

    (interval) ->
      sub?.dispose?()
      sub = atom.workspace.observeTextEditors (editor) ->
        setTimeout ->
          editorPresenter = atom.views.getView(editor).component.presenter
          editorPresenter.stopBlinkingCursors true
          if interval > 0
            editorPresenter.cursorBlinkPeriod = interval
          else
            editorPresenter.cursorBlinkPeriod = -1 + Math.pow 2, 31
          editorPresenter.startBlinkingCursors()
        , 0
      @subs.add sub

  applyPulseDuration: (duration) =>
    @updateStylesheet primarySelector, 'transition-duration', "#{duration}ms"

  applyCursorThickness: (thickness) =>
    @updateStylesheet primarySelector, 'border-width', "#{thickness}px"

  getCursorStyle: ->
    return cursorStyle if cursorStyle?
    cursorStyle = document.createElement 'style'
    cursorStyle.type = 'text/css'
    document.querySelector('head atom-styles').appendChild cursorStyle
    cursorStyle

  updateStylesheet: (selector, property, value) ->
    sheet = @getCursorStyle().sheet
    sheet.insertRule "#{selector} { #{property}: #{value}; }", sheet.cssRules.length

  toRGBAString: (color) ->
    return color if typeof color is 'string'
    return unless color.red and color.green and color.blue and color.alpha
    "rgba(#{color.red}, #{color.green}, #{color.blue}, #{color.alpha})"

module.exports = new BlockCursor()
