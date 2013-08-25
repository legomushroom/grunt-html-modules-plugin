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
                        if i is files.length-1 then @dfr.resolve @files

            @dfr.promise()

        getValidFiles:(files)->
            files.filter (file)->
                file.match /.html$/gi
    
    filesStorage = new Files
    
    # Please see the Grunt documentation for more information regarding task
    # creation: http://gruntjs.com/creating-tasks
    grunt.registerMultiTask "html_modules", "allows to include small html parts in other html", ->

        class FilesChanged 
            constructor:(o)->
                @o = o
                @files = []
                @compiled = ''

                filesStorage.readFiles().then (files)=>
                    @getFiles().then =>


            getFiles:->
                @dfr = new $.Deferred

                # Iterate over all specified file groups.
                @o.files.forEach (f) =>
                    @f = f
                    # check file source.
                    src = f.src.filter((filepath) ->
                        filepath = filepath
                        unless grunt.file.exists(filepath)
                            grunt.log.warn "Source file \"" + filepath + "\" not found."
                            false
                        else return true
                    # Read file source.
                    ).map (filepath) -> grunt.file.read filepath

                    for file, z in src

                        @$destFile = @wrapFile file
                        @$tags = @getTagsInFile @$destFile
                        
                        # look thrue tags in file
                        for tagNum in [0...@$tags.length]
                            @files[j] = {}
                            for attr, i in @$tags[j].attributes
                                @files[j][attr.nodeName] = attr.nodeValue


                            @compile j, f

                            if j is @$tags[j].attributes.length-1 then @dfr.resolve @files
                        
                        grunt.file.write "dest/#{@f.src[0]}", @$destFile.html() 


                @dfr.promise()

            wrapFile:($file)->
                $(file).wrap('<div>').parent()

            getTagsInFile:($file)->
                $file.find('layout')


            compile:(j, f)->
                file = filesStorage.files[@files[j].key]
                for name, value of @files[j]
                    patt = new RegExp "\\$#{name}", 'gi'
                    file = file.replace patt, value

                $(@$tags[j]).replaceWith file



        filesChanged = new  FilesChanged 
                                files: @files

