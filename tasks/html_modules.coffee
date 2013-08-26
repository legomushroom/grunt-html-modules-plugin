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
                @trail = []
                @trails = []
                @curTrail = 0
                @prevTrail = -1
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

                        grunt.file.write "dest/#{f.src[z]}", newFile


            renderFile:(o)->
                $destFile   =   @wrapFile o.file
                $tags       =   @getTagsInFile $destFile

                @compileTags 
                        $tags: $tags


            compileTags:(o)->
                trail = o.trail or []

                for $tag, i in o.$tags
                    jsonTag  =  @getJSONTags 
                                        tag: $tag
                                        parent: o.parent

                    @trails[i] = ''
                    @curTrail = @trails.length

                    if @curTrail > @prevTrail
                        @prevTrail = @curTrail
                        trail.length = 0

                    compiledTag = @compileTag 
                            $tag:       $tag
                            jsonTag:    jsonTag
                            trail:      trail

                    console.log @curTrail
                    console.log trail




            compileTag:(o)->
                if o.trail.indexOf(o.jsonTag.key) isnt -1
                    console.error 'error'

                o.trail.push o.jsonTag.key
                tag = filesStorage.files[o.jsonTag.key]

                # replace variables
                for name, value of o.jsonTag
                    patt = new RegExp "\\$#{name}", 'gi'
                    tag = tag?.replace patt, value

                $(o.$tag).replaceWith tag

                $dest = @wrapFile tag
                $tags = @getTagsInFile $dest
                if $tags.length
                    @compileTags 
                        $tags: $tags
                        trail: o.trail

                tag

            getJSONTags:(o)->
                jsonTag = {}
                for attr, i in o.tag.attributes
                    jsonTag[attr.nodeName] = attr.nodeValue
                    jsonTag['parentName']  = o.parent

                jsonTag

            wrapFile:(file)->
                $(file).wrap('<div>').parent()

            getTagsInFile:($file)->
                $file.find('layout')

        filesChanged = new  FilesChanged 
                                files: @files

