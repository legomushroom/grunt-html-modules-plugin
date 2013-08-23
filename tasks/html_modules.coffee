#
# * html-modules
# * https://github.com/legomushroom/grunt-plugin
# *
# * Copyright (c) 2013 LegoMushroom
# * Licensed under the MIT license.
# 
"use strict"

module.exports = (grunt) ->
    console.log 'run'
    fs = require 'fs'
    data = {}
    class Files
        constructor:(o)->
            @o = o
            @fs = fs
            @dir = 'tasks/src/'
            @pt = {}
            @readFiles()

        readFiles:->
            @fs.readdir @dir, (err, files)=>
                if err then throw err;
                c = 0
                files.forEach (file)=>
                    if !file.match /.html$/gi then return
                    c++
                    fs.readFile @dir+file, 'utf-8', (err, html)=>
                        err and (throw err)
                        @pt[file.split('.')[0]] = html
                        console.log '1'


    files = new Files

    console.log '2'
    




    # Please see the Grunt documentation for more information regarding task
    # creation: http://gruntjs.com/creating-tasks
    grunt.registerMultiTask "html_modules", "allows to include small html parts in other html", ->
    
        # Merge task-specific and/or target-specific options with these defaults.
        options = @options
            punctuation: "."
            separator: ", "
    
        # Iterate over all specified file groups.
        @files.forEach (f) ->
      
            # Concat specified files.
          
            # Warn on and remove invalid source files (if nonull was set).
          
            # Read file source.
            src = f.src.filter((filepath) ->
                unless grunt.file.exists(filepath)
                    grunt.log.warn "Source file \"" + filepath + "\" not found."
                    false
                else
                    true
            ).map((filepath) ->
                grunt.file.read filepath
            ).join(grunt.util.normalizelf(options.separator))
            
            console.log src
          
            # Write the destination file.
            # grunt.file.write f.dest, src
              
            # Print a success message.
            grunt.log.writeln "File \"" + f.dest + "\" created."

