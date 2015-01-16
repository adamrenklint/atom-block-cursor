fs = require 'fs'
path = require 'path'

class BlockCursor
  mainStylesheet: path.join __dirname, '..', 'styles', 'block-cursor.less'
  varsStylesheet: path.join __dirname, '..', 'styles', 'includes', 'vars.less'

  config:
    primaryColor:
      description: 'Primary color of the cursor'
      type: 'color'
      default: '#393939'
    secondaryColor:
      description: 'Secondary color of the cursor'
      type: 'color'
      default: '#393939'
    enablePulse:
      description: 'Fade from primary color to secondary color'
      type: 'boolean'
      default: false

  activate: ->
    @primaryColorObserveSubscription =
      atom.config.observe 'block-cursor.primaryColor', (val) => @applyPrimaryColor val
    @secondaryColorObserveSubscription =
      atom.config.observe 'block-cursor.secondaryColor', (val) => @applySecondaryColor val
    @enablePulseObserveSubscription =
      atom.config.observe 'block-cursor.enablePulse', (val) => @applyPulse val

  deactivate: ->
    @primaryColorObserveSubscription.dispose()
    @secondaryColorObserveSubscription.dispose()
    @enablePulseObserveSubscription.dispose()

  applyPrimaryColor: (primaryColor) ->
    @updateLessVariable 'block-cursor-primary-color', primaryColor.toRGBAString()

  applySecondaryColor: (secondaryColor) ->
    @updateLessVariable 'block-cursor-secondary-color', secondaryColor.toRGBAString()

  applyPulse: (enabled) ->
    transition = if enabled then 'background-color .5s' else 'none'
    @updateLessVariable 'block-cursor-pulse', transition

  updateLessVariable: (varName, value) ->
    text = fs.readFileSync @varsStylesheet, 'utf8'
    regex = "^@#{varName}:\s.*;$"
    text.replace regex, ''
    text += "\n@#{varName}: #{value};"
    fs.writeFileSync @varsStylesheet, text
    @reloadStylesheet()

  reloadStylesheet: ->
    atom.themes.removeStylesheet @mainStylesheet
    atom.themes.requireStylesheet @mainStylesheet

module.exports = new BlockCursor()
