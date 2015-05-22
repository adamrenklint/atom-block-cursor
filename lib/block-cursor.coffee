'use strict'
PackageConfigObserver = require 'atom-package-config-observer'

equals = (obj, ref) ->
  if obj is ref
    return true
  for own key, val of obj
    if typeof val is 'object'
      if not equals ref[key], val
        return false
    else if ref[key] isnt val
      return false
  return true

class BlockCursor
  config:
    cursorType:
      type: 'string'
      default: 'block'
      enum: [
        'block'
        'bordered-box'
        'i-beam'
        'underline'
      ]
      order: 0

    primaryColor:
      type: 'color'
      default: '#393939'
      order: 1

    primaryColorAlpha:
      description: '0 means invisible, 1 means fully opaque.'
      type: 'number'
      default: 1
      minimum: 0
      maximum: 1
      order: 2

    secondaryColor:
      type: 'color'
      default: 'transparent'
      order: 3

    secondaryColorAlpha:
      description: '0 means invisible, 1 means fully opaque.'
      type: 'number'
      default: 0
      minimum: 0
      maximum: 1
      order: 4

    blinkInterval:
      description: 'Set to 0 to disable cursor blinking.'
      type: 'integer'
      default: 800
      minimum: 0
      order: 5

    pulseDuration:
      description: 'Set to 0 to disable pulse effect.'
      type: 'integer'
      default: 0
      minimum: 0
      order: 6

    cursorThickness:
      description: 'Doesn\'t apply to "block" cursor type.'
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
      description: 'Fix to render the cursor above the text when the cursor line has a background-color. See readme for more info.'
      type: 'boolean'
      default: false
      order: 9


  activate: ->
    @setupStylesheet()
    @configObserver = new PackageConfigObserver 'block-cursor'
    @configObserver.observeGlobalConfig @updateGlobalCursorStyle
    @configObserver.observeScopedConfig @updateCursorStyleForScope
    @configObserver.onDidDisposeScope (scopeName) =>
      @cssRulesIndexes[scopeName] = null

  deactivate: ->
    @disposeStylesheet()
    @configObserver.dispose()

  setupStylesheet: ->
    @cssRulesIndexes = {}
    @stylesheet = document.createElement 'style'
    @stylesheet.type = 'text/css'
    document.querySelector('head atom-styles').appendChild @stylesheet

  disposeStylesheet: ->
    @cssRulesIndexes = {}
    @stylesheet.parentNode.removeChild @stylesheet
    @stylesheet = null

  updateGlobalCursorStyle: (@globalConfig) =>
    @updateCursorStyleForScope globalConfig, [atom.workspace], ''
    for own scopeName, editors of @configObserver.editorsForObservedScopes()
      scopedConfig = @configObserver.configForScope scopeName
      @updateCursorStyleForScope scopedConfig, editors, scopeName

  updateCursorStyleForScope: (scopedConfig, editors, scopeName) =>
    if scopedConfig isnt @globalConfig and equals scopedConfig, @globalConfig, scopeName
      return
    scopedConfig = @prepareConfig scopedConfig
    @updateStylesheet scopeName, scopedConfig
    for editor in editors
      @updateEditor editor, scopedConfig

  updateStylesheet: (scopeName, scopedConfig) ->
    @removeCSSRulesForScope scopeName
    @insertCSSRulesForScope scopeName, scopedConfig

  prepareConfig: (config) ->
    {cursorType, primaryColor, primaryColorAlpha, secondaryColor, secondaryColorAlpha,
      blinkInterval, pulseDuration, cursorThickness, cursorLineFix} = config
    # clone colors to not accidentally call atom.config.set()
    primaryColor = @cloneColor primaryColor
    secondaryColor = @cloneColor secondaryColor

    # set alpha
    primaryColor.alpha = primaryColorAlpha
    secondaryColor.alpha = secondaryColorAlpha

    if blinkInterval is 0
      blinkInterval = -1 + Math.pow 2, 31 # ~max value for setInterval (25 days)
      secondaryColor = primaryColor # disable cursor blinking in editor.mini

    # color property that should be set (either background-color for block cursor
    # or border-color for others)
    primaryColor.property = secondaryColor.property = switch cursorType
      when 'block' then 'background-color'
      else 'border-color'

    # transition opacity instead of background-color to transparent
    if secondaryColor.alpha is 0
      secondaryColor.property = 'opacity'
      secondaryColor.toRGBAString = -> 0
    # return new config object
    {cursorType, primaryColor, secondaryColor, blinkInterval,
      pulseDuration, cursorThickness, cursorLineFix}

  removeCSSRulesForScope: (scopeName) ->
    # get index for the rules for this scope
    index = @cssRulesIndexes[scopeName]
    return unless index?
    # when the second deleteRule is called a rule is already
    #removed so the second rule's index will be equal to index
    @stylesheet.sheet.deleteRule index
    @stylesheet.sheet.deleteRule index

  insertCSSRulesForScope: (scopeName, scopedConfig) ->
    {primaryColor, secondaryColor, pulseDuration, cursorThickness} = scopedConfig
    @cssRulesIndexes[scopeName] ?= @stylesheet.sheet.cssRules.length

    @stylesheet.sheet.insertRule """
      #{@selectorForScope scopeName} {
        #{primaryColor.property}: #{primaryColor.toRGBAString()};
        transition-duration: #{pulseDuration}ms;
        border-width: #{cursorThickness}px;
      }
    """, @cssRulesIndexes[scopeName]

    @stylesheet.sheet.insertRule """
      #{@selectorForScope scopeName, true} {
        #{secondaryColor.property}: #{secondaryColor.toRGBAString()};
      }
    """, @cssRulesIndexes[scopeName]

  updateEditor: (editor, config) ->
    {cursorType, blinkInterval, cursorLineFix} = config
    editorView = atom.views.getView editor

    editorView.classList.remove 'cursor-block', 'cursor-bordered-box', 'cursor-i-beam', 'cursor-underline'
    editorView.classList.add "cursor-#{cursorType}"

    if cursorLineFix
      editorView.classList.add 'cursor-line-fix'
    else
      editorView.classList.remove 'cursor-line-fix'

    editorPresenter = editorView.component?.presenter
    if editorPresenter?
      editorPresenter.stopBlinkingCursors true
      editorPresenter.cursorBlinkPeriod = blinkInterval
      editorPresenter.startBlinkingCursors()

  selectorForScope: (scopeName, blinkOff = '') ->
    if scopeName isnt ''
      scopeName = scopeName.split('.').map((scope) -> "[data-grammar~=\"#{scope}\"]").join('')
    if blinkOff isnt ''
      blinkOff = '.blink-off'
    "atom-text-editor#{scopeName}::shadow .cursors#{blinkOff} .cursor"

  cloneColor: (color) ->
    red: color.red
    green: color.green
    blue: color.blue
    alpha: color.alpha
    toRGBAString: -> color.toRGBAString.call @

module.exports = new BlockCursor()
