blockCursor = require '../lib/block-cursor'

describe 'Block Cursor', ->
  cursorColorStyleElement = blockCursor.getCursorColorStyleElement()

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage 'block-cursor'

  it 'adds the block-cursor class to the workspaceView', ->
    workspaceView = atom.views.getView atom.workspace
    expect(workspaceView.className).toMatch /\s*block-cursor\s*/

  it 'adds a style element to the atom-styles element in the head element', ->
    foundStyleElement = false
    for styleElement in document.querySelector('head atom-styles').childNodes when styleElement is cursorColorStyleElement
      foundStyleElement = true
      break
    expect(foundStyleElement).toEqual(true)

  describe 'Configuration', ->
    describe 'the cursorBlink option', ->
      it 'removes the block-cursor-no-blink class from the workspaceView when enabled', ->
        workspaceView = atom.views.getView atom.workspace
        atom.config.set 'block-cursor.cursorBlink', true
        expect(workspaceView.className).not.toMatch /\s*block-cursor-no-blink\s*/

      it 'adds the block-cursor-no-blink class to the workspaceView when disabled', ->
        workspaceView = atom.views.getView atom.workspace
        atom.config.set 'block-cursor.cursorBlink', false
        expect(workspaceView.className).toMatch /\s*block-cursor-no-blink\s*/

    describe 'the cursorColor option', ->
      it 'changes the first rule of the stylesheet that is inserted by the package', ->
        initialColor = atom.config.get 'block-cursor.cursorColor'
        initialFirstRule = cursorColorStyleElement.sheet.cssRules[0].cssText
        newColor = initialColor
        newColor.red = (initialColor.red + 1) % 255
        atom.config.set 'block-cursor.cursorColor', newColor
        newFirstRule = cursorColorStyleElement.sheet.cssRules[0].cssText
        newColorFromRule = newFirstRule.match /rgb\((\d{1,3}),\s?(\d{1,3}),\s?(\d{1,3})\)/

        expect(newFirstRule).not.toEqual initialFirstRule
        expect(parseInt newColorFromRule[1], 10).toEqual newColor.red
        expect(parseInt newColorFromRule[2], 10).toEqual newColor.green
        expect(parseInt newColorFromRule[3], 10).toEqual newColor.blue