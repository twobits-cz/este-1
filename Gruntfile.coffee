module.exports = (grunt) ->

  stylusStyles = [
   'bower_components/este-library/este/**/*.styl'
   'client/tripomatic2/css/**/*.styl'
  ]

  coffeeScripts = [
    'bower_components/este-library/este/**/*.coffee'
    'client/tripomatic2/js/**/*.coffee'
    'server/**/*.coffee'
  ]

  ourCoffeeScripts = [
    'client/tripomatic2/js/**/*.coffee'
  ]

  soyTemplates = [
    'bower_components/este-library/este/**/*.soy'
    'client/tripomatic2/js/**/*.soy'
  ]

  clientDirs = [
    'bower_components/closure-library'
    'bower_components/closure-templates'
    'bower_components/este-library/este'
    'client/tripomatic2/js'
  ]

  clientDepsPath =
    'client/deps.js'

  clientDepsPrefix =
    '../../../../'



    #build tasks
  config =
    clean:
      app:
        options:
          force: true
        src: [
          'bower_components/este-library/este/**/*.{js,css}'
          'client/**/build/**.*'
          'client/**/{js}/**/*.{js}'
          'server/**/*.js'
        ]
    stylus:
      options:
        'include css': true
        'compress': false
      all:
        files: [
          expand: true
          src: stylusStyles
          ext: '.css'
        ]
      app:
        files: [
          expand: true
          src: 'client/tripomatic2/css/app.styl'
          ext: '.css'
        ]


    coffee:
      options:
        bare: true
      app:
        files: [
          expand: true
          src: coffeeScripts
          ext: '.js'
        ]

    coffee2closure:
      app:
        files: [
          expand: true
          src: coffeeScripts
          ext: '.js'
        ]

    coffeelint:
      options:
        no_backticks:
          level: 'ignore'
        max_line_length:
          level: 'ignore'
        no_tabs:
          level: 'ignore'
        indentation:
          level: 'ignore'
       cyclomatic_complexity:
         value: 16
         level: 'error'
        line_endings:
          level: 'error'
        space_operators:
          level: 'error'
      all:
        files: [
          expand: true
          src: ourCoffeeScripts
        ]

    esteTemplates:
      app:
        src: soyTemplates

    esteDeps:
      all:
        options:
          outputFile: clientDepsPath
          prefix: clientDepsPrefix
          root: clientDirs

    esteUnitTests:
      options:
        depsPath: clientDepsPath
        prefix: clientDepsPrefix
      app:
        src: [
          'bower_components/este-library/este/**/*_test.js'
          'client/**/*_test.js'
        ]

    # build --stage tasks

    cssmin:
      app:
          files:
            'client/tripomatic2/build/css/style.css': [
              'bower_components/este-library/este/demos/css/lightbox.css',
              'bower_components/closure-library/closure/goog/css/menu.css',
              'bower_components/closure-library/closure/goog/css/menuitem.css',
              'bower_components/closure-library/closure/goog/css/menuseparator.css',
              'bower_components/este-library/este/css/scrollbar.css',
              'client/tripomatic2/css/style.css',
              'client/tripomatic2/css/animations.css'
            ]

    esteBuilder:
      options:
        root: clientDirs
        depsPath: clientDepsPath

        # Enable faster compilation for Windows with Java 1.7+.
        # javaFlags: ['-XX:+TieredCompilation']
        compilerFlags: do ->

          # Default compiler settings. You will love advanced compilation with
          # verbose warning level.
          flags = [
            '--output_wrapper=(function(){%output%})();'
            '--compilation_level=ADVANCED_OPTIMIZATIONS'
            '--warning_level=VERBOSE'
            # experimental stuff
            # '--use_types_for_optimization'
          ]

          # Remove some code workarounds for ancient browsers.
          # IE<8 and very old Gecko and Webkit.
          flags = flags.concat [
            '--define=goog.net.XmlHttp.ASSUME_NATIVE_XHR=true'
            '--define=este.json.SUPPORTS_NATIVE_JSON=true'
            '--define=goog.style.GET_BOUNDING_CLIENT_RECT_ALWAYS_EXISTS=true'
          ]

          # Enable debug compiled mode for --stage=debug.
          if grunt.option('stage') == 'debug'
            flags = flags.concat [
              '--debug=true'
              '--formatting=PRETTY_PRINT'
              '--define=goog.DEBUG=true'
            ]
          else
            flags = flags.concat [
              '--define=goog.DEBUG=false'
              '--externs=client/tripomatic2/externs.js'
            ]

          # Compiler Externs. They allow us to use thirdparty code without []
          # syntax.
          flags.concat [
            '--externs=bower_components/este-library/externs/react.js'
          ]

      app:
        options:
          namespace: 'tb.tripomatic.planner.start'
          outputFilePath: 'client/tripomatic2/build/app.js'
      map:
        options:
          namespace: 'tb.demos.app.map.start'
          outputFilePath: 'client/tripomatic2/build/map.js'
      myTrips:
        options:
          namespace: 'tb.myTrips.start'
          outputFilePath: 'client/tripomatic2/build/myTrips.js'
      login:
        options:
          namespace: 'tb.demos.app.loginDemo.start'
          outputFilePath: 'client/tripomatic2/build/signinup.js'
      activityDetail:
        options:
          namespace: 'tb.demos.app.activityDetail.start'
          outputFilePath: 'client/tripomatic2/build/activityDetail.js'
      activityInTripSwitch:
        options:
          namespace: 'tb.demos.app.activityInTripSwitch.start'
          outputFilePath: 'client/tripomatic2/build/activityInTripSwitch.js'

      # Use this task to build specific language, /client/build/app_de.js etc.
      # appLocalized:
      #   options:
      #     namespace: 'app.start'
      #     outputFilePath: 'client/tripomatic2/build/app.js'
      #     messagesPath: 'messages/app'
      #     locales: ['cs', 'de']

    # run tasks

    replace:
      esteLibraryVersion:
        src: 'server/app/views/index.jade'
        overwrite: true
        replacements: [
          from: /\(v.+\)/g
          to: ->
            version = require('./bower_components/este-library/bower.json').version
            "(v#{version})"
        ]

    env:
      development:
        NODE_ENV: 'development'
      stage:
        NODE_ENV: 'stage'
      production:
        NODE_ENV: 'production'

    bgShell:
      app:
        cmd: 'node server/app'
        bg: true

    esteWatch:
      options:
        dirs: [
          'bower_components/closure-library/**/'
          'bower_components/este-library/este/**/'
          'client/**/{js,css}/**/'
          'server/**/'
        ]

      coffee: (filepath) ->
        files = [
          expand: true
          src: filepath
          ext: '.js'
        ];
        grunt.config ['coffee', 'app', 'files'], files
        grunt.config ['coffee2closure', 'app', 'files'], files
        ['coffee:app', 'coffee2closure:app']

      soy: (filepath) ->
        grunt.config ['esteTemplates', 'app'], filepath
        ['esteTemplates:app']

      js: (filepath) ->
        grunt.config ['esteDeps', 'all', 'src'], filepath
        grunt.config ['esteUnitTests', 'app', 'src'], filepath
        tasks = ['esteDeps:all', 'esteUnitTests:app']
        if grunt.option 'stage'
          tasks.push 'esteBuilder:app'
        tasks

      styl: (filepath) ->
        grunt.config ['stylus', 'all', 'files'], [
           expand: true
           src: filepath
           ext: '.css'
        ]
        ['stylus:all', 'stylus:app']

      css: (filepath) ->
        if grunt.option('stage')
          return 'cssmin:app'

    # other tasks

    esteExtractMessages:
      app:
        options:
          root: [
            'bower_components/este-library/este'
            'client/tripomatic2/js'
          ]
          messagesPath: 'messages/app'
          languages: ['en', 'cs']

    release:
      options:
        bump: true
        add: true
        commit: true
        tag: true
        push: true
        pushTags: true
        npm: false

    'npm-contributors':
      options:
        file: 'package.json'
        commit: false
        commitMessage: 'Update contributors'

  demosExtends = ['clean', 'coffee', 'coffee2closure', 'esteTemplates', 'esteUnitTests', 'cssmin']
  for ext in demosExtends
    config[ext].map = config[ext].app
    config[ext].activityDetail = config[ext].app
    config[ext].activityInTripSwitch = config[ext].app
    config[ext].myTrips = config[ext].app
    config[ext].login = config[ext].app


  grunt.initConfig config

  grunt.loadNpmTasks 'grunt-bg-shell'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-env'
  grunt.loadNpmTasks 'grunt-este'
  grunt.loadNpmTasks 'grunt-este-watch'
  grunt.loadNpmTasks 'grunt-npm'
  grunt.loadNpmTasks 'grunt-release'
  grunt.loadNpmTasks 'grunt-text-replace'

  grunt.registerTask 'build', 'Build app.', (app = 'app') ->
    tasks = [
      "clean:#{app}"
      "stylus:all"
      "coffee:#{app}"
      "coffee2closure:#{app}"
      "esteTemplates:#{app}"
      "esteDeps"
      "esteUnitTests:#{app}"
    ]
    if grunt.option 'stage'
      tasks = tasks.concat [
        "cssmin:#{app}"
        "esteBuilder:#{app}"
      ]
    grunt.task.run tasks

  grunt.registerTask 'run', 'Run stack.', (app = 'app') ->
    grunt.task.run [
      "replace:esteLibraryVersion"
      if grunt.option 'stage' then 'env:stage' else 'env:development'
      "bgShell:#{app}"
      "esteWatch"
    ]

  grunt.registerTask 'default', 'Build app and run stack.', (app = 'app') ->
    grunt.task.run [
      "build:#{app}"
      "run:#{app}"
    ]
