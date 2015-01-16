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
    pulseDuration:
      description: 'Duration of the pulse in milliseconds, set to 0 to disable pulse'
      type: 'integer'
      default: 0
      minimum: 0
      maximum: 500

  activate: ->
    @primaryColorObserveSubscription =
      atom.config.observe 'block-cursor.primaryColor', (val) => @applyPrimaryColor val
    @secondaryColorObserveSubscription =
      atom.config.observe 'block-cursor.secondaryColor', (val) => @applySecondaryColor val
    @pulseDurationObserveSubscription =
      atom.config.observe 'block-cursor.pulseDuration', (val) => @applyPulse val

  deactivate: ->
    @primaryColorObserveSubscription.dispose()
    @secondaryColorObserveSubscription.dispose()
    @pulseDurationObserveSubscription.dispose()

  applyPrimaryColor: (primaryColor) ->
    @updateLessVariable 'block-cursor-primary-color', primaryColor.toRGBAString()

  applySecondaryColor: (secondaryColor) ->
    @updateLessVariable 'block-cursor-secondary-color', secondaryColor.toRGBAString()

  applyPulse: (duration) ->
    @updateLessVariable 'block-cursor-pulse', "background-color #{(duration / 1000).toString()}s"

  updateLessVariable: (varName, value) ->
    text = fs.readFileSync @varsStylesheet, 'utf8'
    regex = new RegExp "@#{varName}:\s?.*;\n?"
    text = text.replace regex, "@#{varName}: #{value};\n"
    fs.writeFileSync @varsStylesheet, text
    @reloadStylesheet()

  reloadStylesheet: ->
    atom.themes.removeStylesheet @mainStylesheet
    atom.themes.requireStylesheet @mainStylesheet

module.exports = new BlockCursor()
