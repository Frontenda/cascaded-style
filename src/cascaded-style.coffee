# Return the cascaded style for an element. Uses getMatchedCSSRules in chrome
# and a polyfill in firefox.
#
# options:
#   polyfill - bool; will use the polyfill getMatchedCSSRules.
#              Useful for when crossdomain sheets.
#              default: false
#   properties - List of properties to return; If a property's cascaded style
#                is not available from a stylesheet, will return computed style.
#                default: null
#   replaceInherit - bool; will replace css values 'inherit' with their computed counterpart
#                    default: false
#   window - the window you want to grab style rules from. Will use this window unless specified.
$.fn.cascadedStyle = (options) ->
  _inspectCSS($(this), options)

# Private: Inspects the CSS of a given DOM element.
#
# el - A DOM element.
#
# Returns an object whose properties are CSS property names and values are
# their coresponding CSS values.
_inspectCSS = (el, options={}) ->
  func = _getWindow(options).getMatchedCSSRules
  func = _getMatchedCSSRulesPolyfill unless func and not options.polyfill
  options.function = func

  _inspect(el, options)

_getWindow = (options={}) ->
  options.window or window

# Private: Polyfill for getMatchedCSSRules. Also useful for when some of the
# stylesheets are crossdomain. In the case of crossdomain stylesheets, the
# real getMatchedCSSRules will just return null. Maddening.
#
# Code from: https://gist.github.com/3033012 revision 732e1c
#
# Returns nothing.
_getMatchedCSSRulesPolyfill = (element) ->
  return [] unless element

  result = []
  styleSheets = Array::slice.call(this.document.styleSheets)

  while sheet = styleSheets.shift()
    sheetMedia = sheet.media.mediaText

    try
      sheet.cssRules
    catch e
      # Fail on this sheet. Likely a security error from a cross domain sheet.
      continue

    continue if sheet.disabled or not sheet.cssRules

    # most browsers have window.matchMedia, but some (jasmine headless webkit) dont
    continue if sheetMedia.length and (not this.matchMedia or not this.matchMedia(sheetMedia).matches)

    for rule in sheet.cssRules
      if rule.stylesheet
        # Is an imported sheet (@import). add imported stylesheet to the
        # stylesheets array
        styleSheets.push(rule.stylesheet)
        # and skip this rule
        continue
      else if rule.media
        # Is a media query. add this rule to the stylesheets array since it quacks
        # like a stylesheet (has media & cssRules attibutes)
        styleSheets.push(rule)
        # and skip it
        continue

      fn = element.matchesSelector or element.mozMatchesSelector or element.webkitMatchesSelector
      try
        # in try/catch as there might be an 'invalid' selector.
        result.push(rule) if fn.call(element, rule.selectorText)
      catch e
        ;

  result

# Private: Sort a list of css rules by their specificity. Most specific is
# last.
#
# rules - a list of CssRules.
# element - an HTMLElement not jquery obj
#
# Returns a sorted list of rules
_sortBySpecificity = (rules, element) ->
  spec = {}
  getSpec = (rule) =>
    unless spec[rule.selectorText]?
      spec[rule.selectorText] = $.specificity(rule.selectorText, element: element)
    spec[rule.selectorText]

  cmp = (a, b) ->
    diff = getSpec(a) - getSpec(b)
    diff = a.__pos - b.__pos unless diff
    diff

  # store position for stable sorting
  for i in [0...rules.length]
    rules[i].__pos = i

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
_inspect = (element, options={}) ->
  win = _getWindow(options)
  options.function = win.getMatchedCSSRules unless options.function
  element = element[0] if element instanceof jQuery

  results = {}
  important = {}
  matchedRules = options.function.call(win, element, null)
  matchedRules = Array::slice.call(matchedRules) # convert into a real array
  matchedRules = _sortBySpecificity(matchedRules, element)

  # Append style from the element. End of the array -> most important.
  matchedRules.push(element)
  matchedRules.reverse()

  for matchedRule in matchedRules
    continue unless matchedRule and matchedRule.style

    style = matchedRule.style

    # Will get all the atomic properties (i.e. background-position-x, not
    # background). Atomic properties are important for accuracy. Otherwise we
    # might get in the situation where one rule specifies border:none, and
    # another specifies borders via border-width, border-style, and border-
    # color, but all the rules make it into the result.
    for property in style
      isImportant = style.getPropertyPriority(property)

      value = style.getPropertyValue(property)
      if not results[property]? and value
        results[property] = value
      else if value and isImportant and not important[property]
        results[property] = value
        important[property] = true

  results = _replaceWithComputed(element, results, 'initial')
  results = _replaceWithComputed(element, results, 'inherit') if options.replaceInherit
  results = _filterProperties(element, results, options.properties) if options.properties
  results

# Private: Returns a dict of css properties with only the properties
# specified. If a property is not already in css, it's computed style will be
# pulled from el. Think of it like a specialized _.pick()
#
# el - a jquery element
# css - the css dict with all cascaded styles
# properties - a list of properties
#
# Returns a dict
_filterProperties = (el, css, properties) ->
  return css unless properties and properties.length

  style = $(el).computedStyle()

  # Will try to composite the property from the atomic properties if possible.
  # Otherwise, just use computed style.
  computeStyle = (property) ->
    value = _compositeProperty(property, css)
    value = _getComputedFromStyle(style, property) unless value?
    value

  results = {}
  for prop in properties
    results[prop] = if prop of css then css[prop] else computeStyle(prop)

  results

# Private: Replaced any 'inherit's with their computed style.
#
# el - a jquery element
# css - the css dict with all cascaded styles
#
# Returns a dict of css
_replaceWithComputed = (el, css, valueToReplace) ->
  style = $(el).computedStyle()

  for prop, value of css
    css[prop] = _getComputedFromStyle(style, prop) if value? and (value.indexOf(valueToReplace) == 0)

  css

_getComputedFromStyle = (style, property) ->
  if style.getPropertyValue then style.getPropertyValue(property) else style[property]

# Private: compose a value for property based on the atomic css properties
# passed in.
#
# property - string property like 'background-position'
# css - dict of css properties {'background-position-x': '100%', ...}
#
# Returns a value for the property if it can compose one.
_compositeProperty = (property, css) ->
  if COMPOSITES[property]
    return COMPOSITES[property](css)
  null

COMPOSITES =
  'background-position': (css) ->
    if css['background-position-x'] and css['background-position-y']
      return "#{css['background-position-x']} #{css['background-position-y']}"
    null

  # firefox uses border-left-width-value as an atomic value. Ugh. Top and
  # bottom are like webkit.
  'border-left-width': (css) ->
    return css['border-left-width-value'] if css['border-left-width-value']
    null
  'border-left-color': (css) ->
    return css['border-left-color-value'] if css['border-left-color-value']
    null
  'border-left-style': (css) ->
    return css['border-left-style-value'] if css['border-left-style-value']
    null

  # firefox uses border-right-width-value as an atomic value. Ugh.
  'border-right-width': (css) ->
    return css['border-right-width-value'] if css['border-right-width-value']
    null
  'border-right-color': (css) ->
    return css['border-right-color-value'] if css['border-right-color-value']
    null
  'border-right-style': (css) ->
    return css['border-right-style-value'] if css['border-right-style-value']
    null


