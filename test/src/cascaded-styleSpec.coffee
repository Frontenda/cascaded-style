describe 'getMatchedStyle', ->
  beforeEach ->
    runs ->
      loadStyleFixtures('base.css')
      loadFixtures('base.html')

    # Every test that fetches style must be async (using `runs ->`). It
    # apparently takes chrome a bit to apply the styles to the dom elements.
    # Not ideal.
    waits 0

  it 'exists', ->
    expect($('#test')).toExist()
    expect($('#test').getMatchedStyle).toBeDefined()

  it 'handles multiple style rules', ->
    runs ->
      style = $('.has-multiple-style-rules').getMatchedStyle()
      expect(style['background-color']).toEqual('blue')
      expect(style['line-height']).toEqual('1.6')

  it 'handles important rules', ->
    runs ->
      style = $('.has-multiple-style-rules').getMatchedStyle()
      console.log style
      expect(style['font-size']).toEqual('3em')

  it 'handles style attributes', ->
    runs ->
      style = $('.has-style-attribute').getMatchedStyle()
      expect(style['background-color']).toEqual('green')

  it 'handles background position in style rule', ->
    runs ->
      # the browser is annoying in this case. it makes top right -> 100% 0%
      style = $('.has-multiple-style-rules').getMatchedStyle()
      expect(style['background-position']).toEqual('100% 0%')

  it 'handles background position on style attribute', ->
    runs ->
      style = $('.has-style-attribute').getMatchedStyle()
      expect(style['background-position']).toEqual('top center')

  describe 'using polyfill', ->
    it 'handles multiple style rules', ->
      runs ->
        style = $('.has-multiple-style-rules').getMatchedStyle(polyfill:true)
        expect(style['background-color']).toEqual('blue')
        expect(style['line-height']).toEqual('1.6')

    it 'handles important rules', ->
      runs ->
        style = $('.has-multiple-style-rules').getMatchedStyle(polyfill:true)
        expect(style['font-size']).toEqual('3em')

    it 'handles style attributes', ->
      runs ->
        style = $('.has-style-attribute').getMatchedStyle(polyfill:true)
        expect(style['background-color']).toEqual('green')

    it 'handles background position in style rule', ->
      runs ->
        # the browser is annoying in this case. it makes top right -> 100% 0%
        style = $('.has-multiple-style-rules').getMatchedStyle()
        expect(style['background-position']).toEqual('100% 0%')

    it 'handles background position on style attribute', ->
      runs ->
        style = $('.has-style-attribute').getMatchedStyle()
        expect(style['background-position']).toEqual('top center')


