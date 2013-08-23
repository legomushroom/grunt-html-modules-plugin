#
# * html-modules
# * https://github.com/legomushroom/grunt-plugin
# *
# * Copyright (c) 2013 LegoMushroom
# * Licensed under the MIT license.
# 
"use strict"

module.exports = (grunt) ->
    fs      = require 'fs'
    $       = require 'jquery'
    cheerio = require 'cheerio'

    data = {}
    class Files
        constructor:(o)->
            @o = o
            @fs = fs
            @dir = 'tasks/src/'
            @files = []

        readFiles:->
            @dfr = new $.Deferred

            @fs.readdir @dir, (err, files)=>
                if err then throw err;
                files = @getValidFiles files
                files.forEach (file, i)=>
                    fs.readFile @dir+file, 'utf-8', (err, html)=>
                        err and (throw err)
                        @files[i] = {}
                        @files[i][file.split('.')[0]] = html
                        if i is files.length-1 then @dfr.resolve()

            @dfr.promise()

        getValidFiles:(files)->
            files.filter (file)->
                file.match /.html$/gi
    
    filesStorage = new Files
    filesStorage.readFiles().then =>
        console.log filesStorage.files
    # Please see the Grunt documentation for more information regarding task
    # creation: http://gruntjs.com/creating-tasks
    grunt.registerMultiTask "html_modules", "allows to include small html parts in other html", ->
    
        # Merge task-specific and/or target-specific options with these defaults.
        options = @options
            punctuation: "."
            separator: ", "

        class FilesChanged 
            constructor:(o)->
                @o = o
                @files = []

                @getFiles().then =>
                    console.log @files

            getFiles:->
                @dfr = new $.Deferred

                # Iterate over all specified file groups.
                @o.files.forEach (f) =>
              
                    # Read file source.
                    src = f.src.filter((filepath) ->
                        unless grunt.file.exists(filepath)
                            grunt.log.warn "Source file \"" + filepath + "\" not found."
                            false
                        else
                            true
                    ).map((filepath) ->
                        grunt.file.read filepath )
                    
                    $tag = $(src[0])
                    @$tag = $tag

                    if $tag[0].tagName.toLowerCase() isnt 'layout'
                        $tags = $tag.find('layout')
                    else $tags = [$tag]

                    for j in [0...$tags.length]
                        @files[j] = []
                        for attr, i in $tags[j].attributes
                            @files[j][i] = 
                                name:   attr.nodeName
                                val:    attr.nodeValue

                        @compile $tags[j]

                        if j is $tags[j].attributes.length-1 then @dfr.resolve @files

                @dfr.promise()

            compile:(tag)->
                console.log $(tag).replaceWith 'a'
                console.log @$tag.wrap("<div>").parent().html()



        filesChanged = new  FilesChanged 
                                files: @files

