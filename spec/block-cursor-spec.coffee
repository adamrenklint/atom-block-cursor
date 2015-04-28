helpers = require './helpers'

describe 'block-cursor', ->
  [workspaceView, editorView, cursors, cursor, cursorStyle] = []
  [t, r, b, l] = []

  getBorderWidth = ->
    # [top, right, bottom, left]
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

    describe 'when set to "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'block'
        [t, r, b, l] = getBorderWidth()

      describe 'the border-width of the cursor', ->
        it 'should equal 0', ->
          expect(t is r is b is l is 0).toBe(true)

    describe 'when not set to "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'i-beam'

      describe 'the background-color of the cursor', ->
        it 'should be transparent', ->
          bgColor = cursorStyle.backgroundColor
          expect(helpers.colorEquals bgColor, helpers.transparent).toBe(true)

    describe 'when set to "bordered-box"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'bordered-box'
        [t, r, b, l] = getBorderWidth()

      describe 'the border-width of the cursor', ->
        it 'should be the same on all sides', ->
          expect(t is r is b is l).toBe(true)

        it 'should be greater than 0', ->
          expect(t > 0).toBe(true)

    describe 'when set to "i-beam"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'i-beam'
        [t, r, b, l] = getBorderWidth()

      describe 'the border-width of the cursor', ->
        it 'should be 0 on the top, right and bottom sides', ->
          expect(t is r is b is 0).toBe(true)

        it 'should be greater than 0 on the left side', ->
          expect(l).toBeGreaterThan(0)

    describe 'when its value is "underline"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'underline'
        [t, r, b, l] = getBorderWidth()

      describe 'the border-width of the cursor', ->
        it 'should be 0 on the top, right and left sides', ->
          expect(t is r is l is 0).toBe(true)

        it 'should be greater than 0 on the bottom side', ->
          expect(b).toBeGreaterThan(0)

  describe 'the primaryColor and primaryColorAlpha settings', ->
    beforeEach ->
      atom.config.set 'block-cursor.primaryColor', helpers.primaryColor
      atom.config.set 'block-cursor.primaryColorAlpha', helpers.primaryColor.alpha
      cursors.classList.remove 'blink-off'

    describe 'when cursorType is "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'block'

      it 'should set background-color on the cursor', ->
        bgColor = cursorStyle.backgroundColor
        expect(helpers.colorEquals bgColor, helpers.primaryColor).toBe(true)

    describe 'when cursorType isn\'t "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'i-beam'

      it 'should set border-color on the cursor', ->
        borderColor = cursorStyle.borderColor
        expect(helpers.colorEquals borderColor, helpers.primaryColor).toBe(true)

  describe 'the secondaryColor and secondaryColorAlpha settings', ->
    beforeEach ->
      atom.config.set 'block-cursor.secondaryColor', helpers.secondaryColor
      atom.config.set 'block-cursor.secondaryColorAlpha', helpers.secondaryColor.alpha
      cursors.classList.add 'blink-off'

    describe 'when cursorType is "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'block'

      it 'should set background-color on the cursor', ->
        bgColor = cursorStyle.backgroundColor
        expect(helpers.colorEquals bgColor, helpers.secondaryColor).toBe(true)

    describe 'when cursorType isn\'t "block"', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorType', 'i-beam'

      it 'should set border-color on the cursor', ->
        borderColor = helpers.parseColor cursorStyle.borderColor
        expect(helpers.colorEquals borderColor, helpers.secondaryColor).toBe(true)

  describe 'the blinkInterval setting', ->
    describe 'when it is greater than 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.blinkInterval', 1000

      it 'should set editorView.component.presenter.cursorBlinkPeriod equal to the config value', ->
        expect(editorView.component.presenter.cursorBlinkPeriod).toBe(1000)

    describe 'when set to 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.blinkInterval', 0

      it 'should set editorView.component.presenter.cursorBlinkPeriod to (2^31)-1', ->
        expect(editorView.component.presenter.cursorBlinkPeriod).toBe(-1 + Math.pow 2, 31)

      it 'should set secondaryColor equal to primaryColor', ->
        atom.config.set 'block-cursor.primaryColor', helpers.primaryColor
        cursors.classList.remove 'blink-off'
        primaryBgColor = cursorStyle.backgroundColor
        cursors.classList.add 'blink-off'
        secondaryBgColor = cursorStyle.backgroundColor
        expect(helpers.colorEquals primaryBgColor, secondaryBgColor).toBe(true)

  describe 'the pulseDuration setting', ->
    describe 'when it is greater than 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.pulseDuration', 500

      it 'should set transition-duration on the cursor', ->
        expect(Number.parseFloat cursorStyle.transitionDuration).toBe(.5)

    describe 'when it is 0', ->
      beforeEach ->
        atom.config.set 'block-cursor.pulseDuration', 0

      it 'should not set transition-duration on the cursor', ->
        expect(Number.parseFloat cursorStyle.transitionDuration).toBe(0)

  describe 'the cursorThickness setting', ->
    beforeEach ->
      atom.config.set 'block-cursor.cursorThickness', 2

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
        expect(t is r is b is l is 2).toBe(true)

  describe 'the useHardwareAcceleration setting', ->
    describe 'when enabled', ->
      beforeEach ->
        atom.config.set 'block-cursor.useHardwareAcceleration', true

      describe 'when secondaryColorAlpha is 0', ->
        beforeEach ->
          atom.config.set 'block-cursor.secondaryColorAlpha', 0
          cursors.classList.add 'blink-off'

        it 'should animate opacity instead of background-color on the cursor', ->
          expect(parseFloat cursorStyle.opacity).toBe(0)

  describe 'the cursorLineFix setting', ->
    describe 'when enabled', ->
      beforeEach ->
        atom.config.set 'block-cursor.cursorLineFix', true

      it 'should add the .cursor-line-fix class to workspaceView', ->
        expect(workspaceView.classList.contains 'cursor-line-fix').toBe(true)