
$.fn.getMatchedStyle = ->
  _inspectCSS($(this))

# Private: Inspects the CSS of a given DOM element.
#
# el - A DOM element.
#
# Returns an object whose properties are CSS property names and values are
# their coresponding CSS values.
_inspectCSS = (el) ->
  _ensureGetMatchedCSSRules()
  try
    _inspectWithGetMatchedCSSRules(el)
  catch error
    _inspectWithListOfRules(el)

# Private: Ensures that getMatchedCSSRules is defined.
# Code from: https://gist.github.com/3033012 revision 732e1c
#
# Returns nothing.
_ensureGetMatchedCSSRules = ->
  unless window.getMatchedCSSRules
    window.getMatchedCSSRules = (element) ->
      result = []
      style_sheets = [].slice.call(document.styleSheets)

      while ( sheet = style_sheets.shift() )
        sheet_media = sheet.media.mediaText
        media = [].slice.call(sheet_media)
        continue if ( sheet.disabled )
        continue if ( sheet_media.length && ! window.matchMedia(sheet_media).matches )
        rules = [].slice.call(sheet.cssRules)
        while rule = rules.shift()
          if rule.stylesheet
            # add imported stylesheet to the stylesheets array
            style_sheets.push(rule.stylesheet)
            # and skip this rule
            continue
          else if rule.media
            # add this rule to the stylesheets array since it quacks like
            # a stylesheet (has media & cssRules attibutes)
            style_sheets.push(rule)
            # and skip it
            continue

          if element.mozMatchesSelector(rule.selectorText)
            result.push(rule)

      _sortBySpecificity(result)

# Private: Sort a list of css rules by their specificity. Most specific is
# last.
#
# rules - a list of CssRules.
#
# Returns a sorted list of rules
_sortBySpecificity = (rules) ->
  spec = {}
  getSpec = (rule) =>
    unless spec[rule.selectorText]?
      spec[rule.selectorText] = $.specificity(rule.selectorText)
    spec[rule.selectorText]

  cmp = (a, b) ->
    return getSpec(a) - getSpec(b)

  rules.sort(cmp)
  rules

# Private: Inspects the CSS of a given DOM element using the WebKit's
# getMatchedCSSRules.
#
# el - A DOM element.
# isRoot - inspecting the root element?
#
# Returns an object whose properties are CSS property names and values are
# their corresponding CSS values.
_inspectWithGetMatchedCSSRules = (el) ->
  results = {}
  $el = $(el)
  matchedRules = window.getMatchedCSSRules(el, null)
  for matchedRule in matchedRules
    properties = {}
    cssText = matchedRule.cssText
    cssText = cssText.match(/{([^}]*)}/)[1] if cssText.indexOf('{') > -1
    for property in cssText.split(';')
      # we cant simply split on the colon for the sake of urls.
      sprop = property.split(':')
      name = sprop[0]
      properties[name.trim()] = sprop.slice(1).join(':')

    for property, value of properties
      #continue unless @_includeCssProperty(property)
      #if value == 'inherit'
      #  results[property] = $el.computedStyle(property)

      results[property] = value if value

  results

# Private: Inspects the CSS of a given DOM element using the DOM standard.
#
# el - A DOM element.
# isRoot - inspecting the root element?
#
# Returns an object whose properties are CSS property names and values are
# their coresponding CSS values.
_inspectWithListOfRules: (el, isRoot) ->
  el = $(el)

  style = el.computedStyle()
  results = {}
  $.each style, (key) =>
    property = style[key]
    return unless @_includeCssProperty(property)
    results[property] = style.getPropertyValue(property)

  results

