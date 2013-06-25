# cascaded-style

## Introduction

This allows you to get the 'cascaded style' for an HTML element. Fetching the
computed style only allows you to retrieve the computed pixel value that the
browser uses. So if you had an element like this

```html
<style>
.myel{
  line-height: 1.6;
}
</style>
<div class="myel">Hello</div>
```

And you grabbed the computed style for, say `line-height`, it would return something like `25px` rather than the `1.6` value you wanted.

This `cascaded-style` library allows you to get the value specified in the css, in the case above, `1.6`.

It looks through the stylesheets and computes the value of each css property. In webkit, it uses `getMatchedCSSRules()`. In firefox, it uses a [polyfill][polyfill].

## Usage

Usage is simple: a single function

```javascript
$('.myel').cascadedStyle()
```

This will return an object of all the properties that are specified in css.

```javascript
{
  'line-height': '1.6'
}
```

## Options

### polyfill

Use the polyfill algorithm. This really only applies to webkit. This is useful
when you have some crossdomain sheets. `getMatchedCSSRules()` just returns
null when there are any cross-domain sheets in the chain.

```javascript
$('.myel').cascadedStyle({polyfill: true})
```

### properties

A list of properties to return; If a property's cascaded style is not
available from a stylesheet, it will return the computed style.

```javascript
$('.myel').cascadedStyle({properties: ['line-height', 'background-color']})
```

### replaceInherit

A boolean. Setting to true will force replacement of 'inherit' with their
computed counterpart

```javascript
$('.myel').cascadedStyle({replaceInherit: true})
```

### window

The window you want to grab style rules from. Will use this window unless
specified. Useful if you're using with an iframe

```javascript
$('.myel').cascadedStyle({window: someIframeWindow})
```

## Cross-domain stylesheets

Browsers are paranoid about letting js access cross-domain stylesheets.
`cascaded-styles` will not be able to read styles from a cross domain sheet.

## Meta

### Contents

* a README
* a simple test structure you dont need any other packages to run: [jasmine][jasmine]
* coffeescript
  * [install coffeescript][install]
  * `make watch` and `make test-watch`

### Structure

* /test/src - coffeescript jasmine tests
* /test/suite - runs the tests
* /src - your coffeescript
* cascaded-style.js - generated js

### Running the tests

Run `make watch` and `make test-watch`. Start a server from the root:

```
cd cascaded-style
python -m SimpleHTTPServer 8080
```

Visit `http://localhost:8080/test/suite.html`

### Contributing

* adhere to our [styleguide][styleguide]
* Send a pull request.
* Write tests. New untested code will not be merged.

MIT License

[jasmine]: http://pivotal.github.com/jasmine/
[install]: http://jashkenas.github.com/coffee-script/#installation
[skeleton]: http://buttersafe.com/2008/03/13/romance-on-the-floating-island/
[styleguide]: https://github.com/easelinc/coffeescript-style-guide
[polyfill]: https://gist.github.com/ydaniv/3033012