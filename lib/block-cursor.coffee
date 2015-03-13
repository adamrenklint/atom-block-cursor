'use strict'
{CompositeDisposable} = require 'atom'

class BlockCursor
  cursorStyle = null
  cursorTypeMap =
    '\u25AE - Block': 'block' # ▮
    '\u25AF - Bordered box': 'bordered-box' # ▯
    '| - I-beam': 'i-beam'
    '_ - Underline': 'underline'
  primarySelector = 'atom-text-editor::shadow .cursors .cursor'
  secondarySelector = 'atom-text-editor::shadow .cursors.blink-off .cursor'

  config:
    cursorType:
      type: 'string'
      default: '\u25AE - Block'
      enum: (key for own key of cursorTypeMap)
      order: 0
    primaryColor:
      description: 'Primary color of the cursor'
      type: 'color'
      default: '#393939'
      order: 1
    primaryColorAlpha:
      description: 'Alpha of the primary color in percentage, because the Linux color picker has no opacity'
      type: 'number'
      default: 1
      minimum: 0
      maximum: 1
      order: 2
    secondaryColor:
      description: 'Secondary color of the cursor'
      type: 'color'
      default: 'transparent'
      order: 3
    secondaryColorAlpha:
      description: 'Alpha of the secondary color in percentage, because the Linux color picker has no opacity'
      type: 'number'
      default: 0
      minimum: 0
      maximum: 1
      order: 4
    blinkInterval:
      description: 'Cursor blinking interval in milliseconds. Set to 0 to disable blinking.'
      type: 'integer'
      default: 800
      minimum: 0
      order: 5
    pulseDuration:
      description: 'Duration of the pulse transition in milliseconds, set to 0 to disable pulse'
      type: 'integer'
      default: 0
      minimum: 0
      order: 6
    cursorThickness:
      description: 'Thickness of the cursor in pixels. Doesn\'t apply to "block" cursor type'
      type: 'integer'
      default: 1
      minimum: 1
      order: 7
    preview:
      description: 'This field does nothing, it\'s just here to preview your cursor. The blinkInterval setting does not work in this field.'
      type: 'string'
      default: ''
      order: 8
    cursorLineFix:
      description: 'Fix to render the cursor above the text when .cursor-line has a background-color. See readme for more info'
      type: 'boolean'
      default: false
      order: 9

  activate: ->
    @subs = new CompositeDisposable()
    @observeConfigs
      'cursorType': @applyCursorType
      'primaryColor': @applyPrimaryColor
      'primaryColorAlpha': @applyPrimaryColorAlpha
      'secondaryColor': @applySecondaryColor
      'secondaryColorAlpha': @applySecondaryColorAlpha
      'blinkInterval': @applyBlinkInterval.bind @
      'pulseDuration': @applyPulseDuration
      'cursorThickness': @applyCursorThickness
      'cursorLineFix': @applyCursorLineFix
    @setConfig 'preview', 'The quick brown fox jumps over the lazy dog'
    atom.config.unset 'block-cursor.zzzpreview' # renamed to 'preview', so leave this here for few versions

  deactivate: ->
    @subs.dispose()
    if cursorStyle?
      cursorStyle.parentNode.removeChild cursorStyle
      cursorStyle = null

  applyCursorType: (cursorTypeName) ->
    cursorType = cursorTypeMap[cursorTypeName] ? cursorTypeName
    workspaceView = atom.views.getView atom.workspace
    workspaceView.className = workspaceView.className.replace /block-cursor-(?:block|bordered-box|i-beam|underline)/, ''
    workspaceView.classList.add "block-cursor-#{cursorType}"

  applyPrimaryColor: (color = @getConfig 'primaryColor') =>
    color = color.toRGBAString()
    @updateStylesheet primarySelector, 'background-color', color
    @updateStylesheet primarySelector, 'border-color', color
    if 0 is @getConfig 'blinkInterval'
      @updateStylesheet secondarySelector, 'background-color', color
      @updateStylesheet secondarySelector, 'border-color', color

  applyPrimaryColorAlpha: (alpha) =>
    primaryColor = @getConfig 'primaryColor'
    primaryColor.alpha = alpha
    @setConfig 'primaryColor', primaryColor

  applySecondaryColor: (color) =>
    if 0 is @getConfig 'blinkInterval'
      color = @getConfig 'primaryColor'
    color = color.toRGBAString()
    @updateStylesheet secondarySelector, 'background-color', color
    @updateStylesheet secondarySelector, 'border-color', color

  applySecondaryColorAlpha: (alpha) =>
    secondaryColor = @getConfig 'secondaryColor'
    secondaryColor.alpha = alpha
    @setConfig 'secondaryColor', secondaryColor

  applyBlinkInterval: do ->
    sub = null

    (interval) ->
      sub?.dispose()
      sub = atom.workspace.observeTextEditors (editor) =>
        setTimeout =>
          editorPresenter = atom.views.getView(editor).component.presenter
          editorPresenter.stopBlinkingCursors true
          if interval > 0
            @applySecondaryColor @getConfig 'secondaryColor'
            editorPresenter.cursorBlinkPeriod = interval
          else
            @applyPrimaryColor @getConfig 'primaryColor'
            editorPresenter.cursorBlinkPeriod = -1 + Math.pow 2, 31
          editorPresenter.startBlinkingCursors()
        , 0
      @subs.add sub

  applyPulseDuration: (duration) =>
    @updateStylesheet primarySelector, 'transition-duration', "#{duration}ms"

  applyCursorThickness: (thickness) =>
    @updateStylesheet primarySelector, 'border-width', "#{thickness}px"

  applyCursorLineFix: (doFix) ->
    workspaceView = atom.views.getView atom.workspace
    if doFix
      workspaceView.classList.add 'block-cursor-cursor-line-fix'
    else
      workspaceView.classList.remove 'block-cursor-cursor-line-fix'

  getCursorStyle: ->
    return cursorStyle if cursorStyle?
    cursorStyle = document.createElement 'style'
    cursorStyle.type = 'text/css'
    document.querySelector('head atom-styles').appendChild cursorStyle
    cursorStyle

  updateStylesheet: (selector, property, value) ->
    sheet = @getCursorStyle().sheet
    sheet.insertRule "#{selector} { #{property}: #{value}; }", sheet.cssRules.length

  getConfig: (key) ->
    atom.config.get "block-cursor.#{key}"

  setConfig: (key, value) ->
    atom.config.set "block-cursor.#{key}", value

  observeConfigs: (obj) ->
    for own key, cb of obj
      @subs.add atom.config.observe "block-cursor.#{key}", cb

module.exports = new BlockCursor()
