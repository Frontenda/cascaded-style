jquery plugin to get CascadedStyle

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