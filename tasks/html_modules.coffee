#
# * html-modules
# * https://github.com/legomushroom/grunt-plugin
# *
# * Copyright (c) 2013 LegoMushroom
# * Licensed under the MIT license.
# 
"use strict"

# console.log path.basename(o.fileSrc.src, '.html')
# console.log @jsonTags[tagNum].key
# if path.basename(o.fileSrc.src, '.html') is @jsonTags[tagNum].key
    # console.log 'is!!'
    # break
#complie tag

module.exports = (grunt) ->
    fs      = require 'fs'
    $       = require 'jquery'
    path    = require 'path'
    _       = require 'lodash'

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
                    fileName = file.split('.html')[0]
                    fs.readFile @dir+file, 'utf-8', (err, html)=>
                        err and (throw err)
                        @files[fileName] = html
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
                @trail = []
                
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
                        newFile = @renderFile
                            file: file
                            fileSrc: f
                            i: z

                        grunt.file.write "dest/#{f.src[z]}", newFile


            renderFile:(o)->
                @trail = o.trail or []

                $destFile   =   @wrapFile o.file
                $tags       =   @getTagsInFile $destFile

                
                @compileTags 
                        $tags: $tags
                        i: o.i

                if @getTagsInFile($destFile).length > 0
                    return @renderFile 
                        file: $destFile.html()
                        fileSrc: o.fileSrc
                        i: o.i
                        trail: @trail

                $destFile.html()

            compileTags:(o)->
                @jsonTags   =   @getJSONTags 
                                        tags: o.$tags
                                        parent: o.parent
                                        i: o.i

                @checkTrailLoop o.i

                # loop thrue json tags
                for jsonTag, tagNum in @jsonTags
                    compiledTag = @compileTag 
                            tagNum:     tagNum
                            fileSrc:    o.fileSrc
                            $tag:       o.$tags[tagNum]

            checkTrailLoop:(i)->
                console.log @trail
                @trail = _.compact @trail
                for trail, i in @trail
                    console.log 'trail ----->'
                    console.log trail
                    console.log trail.childs
                    # for child, j in trail.childs
                    #     console.log "child #{child} got parent #{trail.parent}"
                    #     console.log @trail.parent

                #     console.log "#{trail.parent} got #{trail.childs}"

                    # for key, value of trail
                        # console.log key
                #         console.log value


            compileTag:(o)->
                tag = filesStorage.files[@jsonTags[o.tagNum].key]
                # replace variables
                for name, value of @jsonTags[o.tagNum]
                    patt = new RegExp "\\$#{name}", 'gi'
                    tag = tag.replace patt, value

                $(o.$tag).replaceWith tag

                $dest = @wrapFile tag
                $tags = @getTagsInFile $dest
                
                if $tags.length
                    jsonTags = @getJSONTags
                            tags: $tags
                            parent: @jsonTags[o.tagNum].key

                tag
            
            getJSONTags:(o)->
                jsonTags = []
                for tagNum in [0...o.tags.length]
                    #add new tags json record
                    jsonTags[tagNum] = {}
                    for attr, i in o.tags[tagNum].attributes
                        jsonTags[tagNum][attr.nodeName] = attr.nodeValue
                        jsonTags[tagNum]['parentName']  = o.parent
                    
                    if o.parent 
                        @trail[o.i] = {}
                        @trail[o.i].parent = o.parent
                        @trail[o.i].childs ?= []
                        @trail[o.i].childs.push jsonTags[tagNum].key

                jsonTags

            


            wrapFile:(file)->
                $(file).wrap('<div>').parent()

            getTagsInFile:($file)->
                $file.find('layout')

        filesChanged = new  FilesChanged 
                                files: @files

