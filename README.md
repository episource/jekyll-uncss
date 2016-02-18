# jekyll-uncss

A Jekyll plugin that uses [uncss](https://github.com/giakki/uncss) to remove unused css rules in selected stylesheets.

## Setup

    cd YOUR_JEKYLL_DIR/_plugins && git submodule add https://github.com/episource/jekyll-uncss.git
    
This plugin depends on uncss. See [uncss](https://github.com/giakki/uncss) for installation instructions.

## Configure

Configure uncss by adding a `uncss` node to your _config.yml. The `stylesheets` option is mandatory, all others are optional. By default all html files (`**/*.html`) are considered. Use the `files` option to change this.

For most option there's a corresponding [uncss option](https://github.com/giakki/uncss) and the configuration is just passed through (maybe with some path adjustments). A noticable exception is the `stylesheets` option: Instead of passing all css files to uncss at once (which would result in the stylesheets being merged), the css files are passed one by one. So each file given is processed separately. 

    uncss:
      stylesheets:            # a list of stylesheets to be processed; mandatory
        - assets/css/main.css
      files:                  # html files to consider, globs are supported; default: **/*.html
        - "**/*.html"
        - "**/*.htm"
      compress: true          # compress resulting css with sass; default: false
      ignore:                 # always keep rules for these selectors; default: none
        - ".is-loading"
        - "#titleBar"
      media:                  # additional media queries to consider; default: undefined
        - print
      timeout: 30             # how long to wait for the JS to be loaded; default: undefined

Note: The `ignore` option can also be included as a css comment. See [uncss](https://github.com/giakki/uncss) documentation for details.