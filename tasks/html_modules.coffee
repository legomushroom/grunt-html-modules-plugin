#
# * html-modules
# * https://github.com/legomushroom/grunt-plugin
# *
# * Copyright (c) 2013 LegoMushroom
# * Licensed under the MIT license.
# 
"use strict"

module.exports = (grunt) ->
    # Please see the Grunt documentation for more information regarding task
    # creation: http://gruntjs.com/creating-tasks
    grunt.registerMultiTask "html_modules", "allows to include small html parts in other html", ->
    
        # Merge task-specific and/or target-specific options with these defaults.
        options = @options
            punctuation: "."
            separator: ", "

        fs = require 'fs'
        $ = require 'jquery-deferred'
        data = {}
        class Files
            constructor:(o)->
                @o = o
                @fs = fs
                @dir = 'tasks/src/'
                @files = {}

            readFiles:->
                @dfr = new $.Deferred

                @fs.readdir @dir, (err, files)=>
                    if err then throw err;
                    files = @getValidFiles files
                    files.forEach (file, i)=>
                        fs.readFile @dir+file, 'utf-8', (err, html)=>
                            err and (throw err)
                            @files[file.split('.')[0]] = html
                            if i is files.length-1 then @dfr.resolve()

                @dfr.promise()

            getValidFiles:(files)->
                files.filter (file)->
                    file.match /.html$/gi
        filesStorage = new Files
        filesStorage.readFiles()
    
        # Iterate over all specified file groups.
        @files.forEach (f) ->
      
            # Read file source.
            src = f.src.filter((filepath) ->
                unless grunt.file.exists(filepath)
                    grunt.log.warn "Source file \"" + filepath + "\" not found."
                    false
                else
                    true
            ).map((filepath) ->
                grunt.file.read filepath )
            
            file = src[0]
            console.log file

