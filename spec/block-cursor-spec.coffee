normalizeColor = ({red, green, blue, alpha}) ->
  red = parseInt red
  green = parseInt green
  blue = parseInt blue

  alpha = parseFloat alpha
  if Number.isNaN alpha
    alpha = 1
  alpha = alpha.toFixed 2

  {red, green, blue, alpha}

transparent = normalizeColor
  red: 0
  green: 0
  blue: 0
  alpha: 0

randomInt = (min, max) ->
  unless max?
    max = min
    min = 0
  Math.floor min + Math.random() * (max - min + 1)

randomColor = =>
  normalizeColor
    red: randomInt 255
    green: randomInt 255
    blue: randomInt 255
    alpha: Math.random()

parseRGBAString = (color) ->
  if typeof color isnt 'string'
    return color

  rgbaRegex = /rgba?\((\d{1,3}),\s(\d{1,3}),\s(\d{1,3})(?:,\s([\d.]+))?\)/
  [match, red, green, blue, alpha] = rgbaRegex.exec color

  normalizeColor {red, green, blue, alpha}

config =
  primaryColor: randomColor()
  secondaryColor: randomColor()
  blinkInterval: randomInt(1000, 2000)
  pulseDuration: randomInt(100, 1000)
  cursorThickness: randomInt(1, 3)

describe 'block-cursor', ->
  [workspaceView, editorView, cursors, cursor, cursorStyle, t, r, b, l] = []

  getBorderWidth = ->
    [
      parseInt cursorStyle.borderTopWidth
      parseInt cursorStyle.borderRightWidth
      parseInt cursorStyle.borderBottomWidth
      parseInt cursorStyle.borderLeftWidth
    ]

  beforeEach ->
    workspaceView = atom.views.getView atom.workspace
    jasmine.attachToDOM workspaceView

    waitsForPromise ->
      atom.packages.activatePackage 'block-cursor'

    waitsForPromise ->
      atom.workspace.open 'dummy.js'

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView editor
      cursors = editorView.shadowRoot.querySelector '.cursors'
      cursor = cursors.querySelector '.cursor'
      cursorStyle = window.getComputedStyle cursor

  describe 'the cursorType setting', ->
    it 'should set a class identifying the selected cursor type to the workspaceView', ->
      for cursorType in ['block', 'bordered-box', 'i-beam', 'underline']
        atom.config.set 'block-cursor.cursorType', cursorType
        expect(workspaceView.classList.contains("cursor-#{cursorType}")).toBe(true)

    describe 'when it is "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'block'
        [t, r, b, l] = getBorderWidth()

      describe 'the border-width of the cursor', ->
        it 'should equal 0', ->
          expect(t is r is b is l is 0).toBe(true)

    describe 'when it isnt "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'i-beam'

      describe 'the background-color of the cursor', ->
        it 'should be transparent', ->
          bgColor = parseRGBAString cursorStyle.backgroundColor
          expect(bgColor).toEqual(transparent)

    describe 'when it is "bordered-box"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'bordered-box'
        [t, r, b, l] = getBorderWidth()

      describe 'the border-width of the cursor', ->
        it 'should be the same on all sides', ->
          expect(t is r is b is l).toBe(true)

        it 'should be greater than 0', ->
          expect(t > 0).toBe(true)

    describe 'when it is "i-beam"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'i-beam'
        [t, r, b, l] = getBorderWidth()

      describe 'the border-width of the cursor', ->
        it 'should be 0 on the top, right and bottom sides', ->
          expect(t is r is b is 0).toBe(true)

        it 'should be greater than 0 on the left side', ->
          expect(l > 0).toBe(true)

    describe 'when it is "underline"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'underline'
        [t, r, b, l] = getBorderWidth()

      describe 'the border-width of the cursor', ->
        it 'should be 0 on the top, right and left sides', ->
          expect(t is r is l is 0).toBe(true)

        it 'should be greater than 0 on the bottom side', ->
          expect(b > 0).toBe(true)

  describe 'the primaryColor and primaryColorAlpha settings', ->
    beforeEach ->
      atom.config.set 'block-cursor.primaryColor', config.primaryColor
      atom.config.set 'block-cursor.primaryColorAlpha', config.primaryColor.alpha
      cursors.classList.remove 'blink-off'

    describe 'when cursorType is "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'block'

      it 'should set background-color on the cursor', ->
        bgColor = parseRGBAString cursorStyle.backgroundColor
        expect(bgColor).toEqual(config.primaryColor)

    describe 'when cursorType isn\'t "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'i-beam'

      it 'should set border-color on the cursor', ->
        borderColor = parseRGBAString cursorStyle.borderColor
        expect(borderColor).toEqual(config.primaryColor)

  describe 'the secondaryColor and secondaryColorAlpha settings', ->
    beforeEach ->
      atom.config.set 'block-cursor.secondaryColor', config.secondaryColor
      atom.config.set 'block-cursor.secondaryColorAlpha', config.secondaryColor.alpha
      cursors.classList.add 'blink-off'

    describe 'when cursorType is "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'block'

      it 'should set background-color on the cursor', ->
        bgColor = parseRGBAString cursorStyle.backgroundColor
        expect(bgColor).toEqual(config.secondaryColor)

    describe 'when cursorType isn\'t "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'i-beam'

      it 'should set border-color on the cursor', ->
        borderColor = parseRGBAString cursorStyle.borderColor
        expect(borderColor).toEqual(config.secondaryColor)

    describe 'when secondaryColorAlpha is 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.secondaryColorAlpha', 0
        cursors.classList.add 'blink-off'

      it 'should set opacity instead of background-color', ->
        expect(parseFloat cursorStyle.opacity).toBe(0)

  describe 'the blinkInterval setting', ->
    describe 'when it is greater than 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.blinkInterval', config.blinkInterval

      it 'should set editorView.component.presenter.cursorBlinkPeriod equal to the config value', ->
        expect(editorView.component.presenter.cursorBlinkPeriod).toBe(config.blinkInterval)

    describe 'when it is 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.blinkInterval', 0

      it 'should set editorView.component.presenter.cursorBlinkPeriod to (2^31)-1', ->
        expect(editorView.component.presenter.cursorBlinkPeriod).toBe(-1 + Math.pow 2, 31)

      it 'should set secondaryColor equal to primaryColor', ->
        atom.config.set 'block-cursor.primaryColor', config.primaryColor
        cursors.classList.remove 'blink-off'
        primaryBgColor = parseRGBAString cursorStyle.backgroundColor
        cursors.classList.add 'blink-off'
        secondaryBgColor = parseRGBAString cursorStyle.backgroundColor
        expect(primaryBgColor).toEqual(secondaryBgColor)

  describe 'the pulseDuration setting', ->
    describe 'when it is greater than 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.pulseDuration', config.pulseDuration

      it 'should set transition-duration on the cursor', ->
        expect(Number.parseFloat cursorStyle.transitionDuration).toBe(config.pulseDuration / 1000)

    describe 'when it is 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.pulseDuration', 0

      it 'should not set transition-duration on the cursor', ->
        expect(Number.parseFloat cursorStyle.transitionDuration).toBe(0)

  describe 'the cursorThickness setting', ->
    beforeEach ->
      atom.config.set 'block-cursor.cursorThickness', config.cursorThickness

    describe 'when cursorType is "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'block'
        [t, r, b, l] = getBorderWidth()

      it 'should not set border-width on the cursor', ->
        expect(t is r is b is l is 0).toBe(true)

    describe 'when cursorType isn\'t "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'bordered-box'
        [t, r, b, l] = getBorderWidth()

      it 'should set border-width on the cursor', ->
        expect(t is r is b is l is config.cursorThickness).toBe(true)

  describe 'the cursorLineFix setting', ->
    describe 'when it is enabled', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorLineFix', true

      it 'should add the .cursor-line-fix class to workspaceView', ->
        expect(workspaceView.classList.contains 'cursor-line-fix').toBe(true)
