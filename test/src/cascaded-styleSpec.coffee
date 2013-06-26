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
    # webkit is annoying in this case. it makes top right -> 100% 0%
    style = $('.has-multiple-style-rules').cascadedStyle
      properties: ['background-position-x', 'background-position-y', 'background-position']

    # Man this is not good.
    if style['background-position-x'] # webkit
      expect(style['background-position-x']).toEqual('100%')
      expect(style['background-position-y']).toEqual('0%')
    else # firefox
      expect(style['background-position']).toEqual('right top')

  describe 'handling initial', ->
    it 'will pick up proper border values', ->
      style = $('.has-multiple-style-rules').cascadedStyle
        polyfill: true,
        properties: ['border-left-width', 'border-left-style']

      expect(style['border-left-width']).toEqual('1px')
      expect(style['border-left-style']).toEqual('dashed')

    it 'will not store initial values', ->
      style = $('.has-style-attribute').css(border: 'none').cascadedStyle
        properties: ['border-left-width', 'border-left-style']

      # in firefox, this is medium. Why? Who knows.
      #expect(style['border-left-width']).toEqual('0px')
      expect(style['border-left-style']).toEqual('none')

  describe 'handling background and background images', ->
    it 'will return the background-image', ->
      style = $('.has-background-image').cascadedStyle
        polyfill: true
        properties: ['background', 'background-image', 'background-color']
      expect(style['background-color']).toEqual('rgb(15, 15, 15)')
      expect(style['background-image']).toContain('gradient(')

    it 'will return the background-image when there is no bg image', ->
      style = $('.has-background-image').css(background:'#fff').cascadedStyle
        polyfill: true
        properties: ['background', 'background-image', 'background-color']

      # in firefox, the background is empty. WTF!?
      #expect(style['background']).toContain('rgb(255, 255, 255)')
      #expect(style['background']).not.toContain('gradient')
      expect(style['background-color']).toEqual('rgb(255, 255, 255)')
      expect(style['background-image']).toEqual('none')

  describe 'handling box-shadows', ->
    it 'will return the box-shadows', ->
      style = $('.has-box-shadows').cascadedStyle
        polyfill: true
        properties: ['box-shadow']

      expect(style['box-shadow']).toContain('0px 0px 10px 0px')
      expect(style['box-shadow']).toContain('rgba(255, 25, 25, 0.2)')

  describe 'handling inherits', ->
    it 'returns raw inherits', ->
      style = $('.has-multiple-style-rules').cascadedStyle()
      expect(style['font-family']).toEqual('inherit')

    it 'replaces inherits with computed style', ->
      style = $('.has-multiple-style-rules').cascadedStyle(replaceInherit: true)

      # Times in webkit, serif in firefox
      expect(style['font-family']).toMatch(/Times|serif/g)

  describe 'passing a list of properties to pull', ->
    it 'only returns props passed in', ->
      style = $('.has-multiple-style-rules').cascadedStyle(properties: ['line-height'])
      expect(style).toEqual('line-height': '1.6')

    it 'fills in non-cascaded styles with computed styles', ->
      style = $('.has-style-attribute').cascadedStyle(properties: ['line-height'])
      # normal in webkit, 19.2 in firefox
      expect(style['line-height']).toMatch(/normal|19.2px/)

    describe 'dealing with composite properties', ->
      it 'composites background-position', ->
        style = $('.has-multiple-style-rules').cascadedStyle(properties: ['background-position'])
        # 100% 0% in webkit, right top in firefox
        expect(style['background-position']).toMatch(/100% 0%|right top/)

  describe 'using polyfill', ->
    it 'handles multiple style rules', ->
      style = $('.has-multiple-style-rules').cascadedStyle(polyfill:true)
      expect(style['background-color']).toEqual('blue')
      expect(style['line-height']).toEqual('1.6')

    it 'sorting of rules is stable', ->
      style = $('.has-multiple-style-rules').cascadedStyle()
      expect(style['border-bottom-style']).toEqual('dotted')

    it 'handles important rules', ->
      style = $('.has-multiple-style-rules').cascadedStyle(polyfill:true)
      expect(style['font-size']).toEqual('3em')

    it 'handles style attributes', ->
      style = $('.has-style-attribute').cascadedStyle(polyfill:true)
      expect(style['background-color']).toEqual('green')

    it 'handles background position in style rule', ->
      # webkit is annoying in this case. it makes top right -> 100% 0%
      style = $('.has-multiple-style-rules').cascadedStyle
        polyfill:true
        properties: ['background-position-x', 'background-position-y', 'background-position']

      # Man this is not good.
      if style['background-position-x'] # webkit
        expect(style['background-position-x']).toEqual('100%')
        expect(style['background-position-y']).toEqual('0%')
      else # firefox
        expect(style['background-position']).toEqual('right top')

    it 'border bug?', ->
      style = $('.has-multiple-style-rules').css(border: 'none').cascadedStyle
        polyfill:true
        #properties: ['border-left-width', 'border-right-width', 'border-bottom-width', 'border-top-width']
      console.log style


