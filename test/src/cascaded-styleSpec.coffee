describe 'getMatchedStyle', ->

  it 'exists', ->
    loadFixtures('base.html')
    expect($('#test')).toExist()
    expect($('#test').getMatchedStyle).toBeDefined()

