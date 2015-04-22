'use strict'
PackageConfigObserver = require 'atom-package-config-observer'

class BlockCursor
  config: require './config'

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

  updateGlobalCursorStyle: (globalConfig) =>
    @updateCursorStyleForScope globalConfig, [atom.workspace], ''
    for own scopeName, editors of @configObserver.editorsForObservedScopes()
      scopedConfig = @configObserver.configForScope scopeName
      @updateCursorStyleForScope scopedConfig, editors, scopeName

  updateCursorStyleForScope: (scopedConfig, editors, scopeName) =>
    @updateStylesheet scopeName, scopedConfig
    for editor in editors
      @updateEditor editor, scopedConfig

  updateStylesheet: (scopeName, scopedConfig) ->
    scopedConfig = @prepareConfig scopedConfig
    @removeCSSRulesForScope scopeName
    @insertCSSRulesForScope scopeName, scopedConfig

  prepareConfig: (config) ->
    {cursorType, primaryColor, primaryColorAlpha, secondaryColor, secondaryColorAlpha,
      blinkInterval, pulseDuration, cursorThickness, useHardwareAcceleration, cursorLineFix} = config
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
    # if harware acceleration is enabled
    if useHardwareAcceleration and secondaryColor.alpha is 0
      secondaryColor.property = 'opacity'
      secondaryColor.toRGBAString = -> 0

    # return new config object
    config = {cursorType, primaryColor, secondaryColor,
      blinkInterval, useHardwareAcceleration, cursorLineFix}
    if pulseDuration > 0 then config.pulseDuration = "#{pulseDuration}ms"
    if cursorType isnt 'block' then config.cursorThickness = "#{cursorThickness}px"
    config

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
        #{if pulseDuration? then "transition-duration: #{pulseDuration};" else ''}
        #{if cursorThickness? then "border-width: #{cursorThickness};" else ''}
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
    if editorView.component?.presenter?
      process.nextTick ->
        editorPresenter = editorView.component.presenter
        editorPresenter.stopBlinkingCursors true
        editorPresenter.cursorBlinkPeriod = blinkInterval
        editorPresenter.startBlinkingCursors()
    editorView.classList[if cursorLineFix then 'add' else 'remove']('cursor-line-fix')

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
