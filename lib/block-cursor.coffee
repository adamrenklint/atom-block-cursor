'use strict'
PackageConfigObserver = require 'atom-package-config-observer'

class BlockCursor
  config: require './config'

  activate: ->
    @setupStylesheet()
    @configObserver = new PackageConfigObserver 'block-cursor'
    @configObserver.observeGlobalConfig @updateGlobalCursorStyle
    @configObserver.observeScopedConfig @updateCursorStyleForScope

  deactivate: ->
    @disposeStylesheet()
    @configObserver.dispose()

  setupStylesheet: ->
    @stylesheet = document.createElement 'style'
    @stylesheet.type = 'text/css'
    document.querySelector('head atom-styles').appendChild @stylesheet

  disposeStylesheet: ->
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
    {cursorType, primaryColor, primaryColorAlpha, secondaryColor, secondaryColorAlpha, blinkInterval, pulseDuration, cursorThickness} = scopedConfig
    primaryColor.alpha = primaryColorAlpha
    if blinkInterval is 0
      secondaryColor = primaryColor
    else
      secondaryColor.alpha = secondaryColorAlpha
    [colorProperty, transProperty] = switch cursorType
      when 'block' then ['background-color', 'border-color']
      else ['border-color', 'background-color']
    @stylesheet.innerHTML += """
      #{@selectorForScope scopeName} {
        #{colorProperty}: #{primaryColor.toRGBAString()};
        #{transProperty}: transparent;
        transition-duration: #{pulseDuration}ms;
        border-width: #{cursorThickness}px;
      }
      #{@selectorForScope scopeName, true} {
        #{
          # if possible, animate opacity instead of
          # background/border-color as it is much smoother
          if secondaryColor.alpha > 0
            "#{colorProperty}: #{secondaryColor.toRGBAString()};"
            'opacity: 1;'
          else
            "#{colorProperty}: #{primaryColor.toRGBAString()};"
            'opacity: 0;'
        }
        #{transProperty}: transparent;
      }
    """

  selectorForScope: (scopeName, blinkOff = '') ->
    if scopeName isnt ''
      scopeName = scopeName.split('.').map((scope) -> "[data-grammar~=\"#{scope}\"]").join('')
    if blinkOff isnt ''
      blinkOff = '.blink-off'
    "atom-text-editor#{scopeName}::shadow .cursors#{blinkOff} .cursor"

  updateEditor: (editor, config) ->
    {cursorType, blinkInterval, cursorLineFix} = config
    editorView = atom.views.getView editor
    editorView.classList.remove 'cursor-block', 'cursor-bordered-box', 'cursor-i-beam', 'cursor-underline'
    editorView.classList.add "cursor-#{cursorType}"
    if editorView.component?.presenter?
      process.nextTick ->
        if blinkInterval is 0
          blinkInterval = -1 + Math.pow 2, 31
        editorPresenter = editorView.component.presenter
        editorPresenter.stopBlinkingCursors true
        editorPresenter.cursorBlinkPeriod = blinkInterval
        editorPresenter.startBlinkingCursors()
    editorView.classList[if cursorLineFix then 'add' else 'remove']('cursor-line-fix')

module.exports = new BlockCursor()
