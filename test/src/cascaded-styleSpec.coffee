describe 'cascadedStyle', ->
  beforeEach ->
    runs ->
      loadStyleFixtures('base.css')
      loadFixtures('base.html')

    # Adding this will make all the tests async. Dont take it out all will
    # fail. It apparently takes chrome a bit to apply the styles to the dom
    # elements. Not ideal.
    waits 0

  it 'exists', ->
    expect($('#test')).toExist()
    expect($('#test').cascadedStyle).toBeDefined()

  it 'handles multiple style rules', ->
    style = $('.has-multiple-style-rules').cascadedStyle()
    expect(style['background-color']).toEqual('blue')
    expect(style['line-height']).toEqual('1.6')

  it 'handles important rules', ->
    style = $('.has-multiple-style-rules').cascadedStyle()
    console.log style
    expect(style['font-size']).toEqual('3em')

  it 'handles style attributes', ->
    style = $('.has-style-attribute').cascadedStyle()
    expect(style['background-color']).toEqual('green')

  it 'handles background position in style rule', ->
    # the browser is annoying in this case. it makes top right -> 100% 0%
    style = $('.has-multiple-style-rules').cascadedStyle()
    expect(style['background-position-x']).toEqual('100%')
    expect(style['background-position-y']).toEqual('0%')

  describe 'handling inherits', ->
    it 'returns raw inherits', ->
      style = $('.has-multiple-style-rules').cascadedStyle()
      expect(style['font-family']).toEqual('inherit')

    it 'replaces inherits with computed style', ->
      style = $('.has-multiple-style-rules').cascadedStyle(replaceInherit: true)
      expect(style['font-family']).toEqual('Times')

  describe 'passing a list of properties to pull', ->
    it 'only returns props passed in', ->
      style = $('.has-multiple-style-rules').cascadedStyle(properties: ['line-height'])
      expect(style).toEqual('line-height': '1.6')

    it 'fills in non-cascaded styles with computed styles', ->
      style = $('.has-style-attribute').cascadedStyle(properties: ['line-height'])
      expect(style).toEqual('line-height': 'normal')

    describe 'dealing with composite properties', ->
      it 'composites background-position', ->
        style = $('.has-multiple-style-rules').cascadedStyle(properties: ['background-position'])
        expect(style).toEqual('background-position': '100% 0%')

  describe 'using polyfill', ->
    it 'handles multiple style rules', ->
      style = $('.has-multiple-style-rules').cascadedStyle(polyfill:true)
      expect(style['background-color']).toEqual('blue')
      expect(style['line-height']).toEqual('1.6')

    it 'handles important rules', ->
      style = $('.has-multiple-style-rules').cascadedStyle(polyfill:true)
      expect(style['font-size']).toEqual('3em')

    it 'handles style attributes', ->
      style = $('.has-style-attribute').cascadedStyle(polyfill:true)
      expect(style['background-color']).toEqual('green')

    it 'handles background position in style rule', ->
      # the browser is annoying in this case. it makes top right -> 100% 0%
      style = $('.has-multiple-style-rules').cascadedStyle()
      expect(style['background-position-x']).toEqual('100%')
      expect(style['background-position-y']).toEqual('0%')

    it 'border bug?', ->
      style = $('.has-multiple-style-rules').css(border: 'none').cascadedStyle
        polyfill:true
        #properties: ['border-left-width', 'border-right-width', 'border-bottom-width', 'border-top-width']
      console.log style


