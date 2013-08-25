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
                @jsonTags = []
                
                filesStorage.readFiles().then (files)=>
                    @getFiles()

            getFiles:->
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
                        @renderFile
                            file: file
                            fileSrc: f


            renderFile:(o)->
                @$destFile  =   @wrapFile o.file
                @$tags      =   @getTagsInFile @$destFile
                @jsonTags   =   @getJSONTags 
                                        tags: @$tags
                                        # fileSrc: o.fileSrc

                for jsonTag, tagNum in @jsonTags
                    compiledFile = @compile 
                            tagNum:     tagNum
                            fileSrc:    o.fileSrc
                            tags:       @$tags


                    if @wrapFile(compiledFile).find('layout').length > 0
                        console.log 'then'
                        console.log compiledFile
                        @renderFile 
                                file: compiledFile
                                fileSrc: o.fileSrc

                    else 
                        console.log 'else'
                        console.log compiledFile
                        $(@$tags[tagNum]).replaceWith compiledFile
                        grunt.file.write "dest/#{o.fileSrc.src[0]}", @$destFile.html() 

            getJSONTags:(o)->
                jsonTags = []
                for tagNum in [0...o.tags.length]
                    #add new tags json record
                    jsonTags[tagNum] = {}
                    for attr, i in o.tags[tagNum].attributes
                        jsonTags[tagNum][attr.nodeName] = attr.nodeValue

                jsonTags

            wrapFile:(file)->
                $(file).wrap('<div>').parent()

            getTagsInFile:($file)->
                $file.find('layout')

            compile:(o)->
                file = filesStorage.files[@jsonTags[o.tagNum].key]
                for name, value of @jsonTags[o.tagNum]
                    patt = new RegExp "\\$#{name}", 'gi'
                    file = file.replace patt, value

                file


                



        filesChanged = new  FilesChanged 
                                files: @files

