// Generated by CoffeeScript 1.6.2
(function() {
  "use strict";  module.exports = function(grunt) {
    var $, Files, data, filesStorage, fs, path, _;

    fs = require('fs');
    $ = require('jquery');
    path = require('path');
    _ = require('lodash');
    data = {};
    Files = (function() {
      function Files(o) {
        this.o = o;
        this.fs = fs;
        this.dir = 'tasks/src/';
        this.files = {};
      }

      Files.prototype.readFiles = function() {
        var _this = this;

        this.dfr = new $.Deferred;
        this.fs.readdir(this.dir, function(err, files) {
          if (err) {
            throw err;
          }
          files = _this.getValidFiles(files);
          return files.forEach(function(file, i) {
            var fileName;

            fileName = file.split('.html')[0];
            return fs.readFile(_this.dir + file, 'utf-8', function(err, html) {
              err && ((function() {
                throw err;
              })());
              _this.files[fileName] = html;
              if (i === files.length - 1) {
                return _this.dfr.resolve(_this.files);
              }
            });
          });
        });
        return this.dfr.promise();
      };

      Files.prototype.getValidFiles = function(files) {
        return files.filter(function(file) {
          return file.match(/.html$/gi);
        });
      };

      return Files;

    })();
    filesStorage = new Files;
    return grunt.registerMultiTask("html_modules", "allows to include small html parts in other html", function() {
      var FilesChanged, filesChanged;

      FilesChanged = (function() {
        function FilesChanged(o) {
          var _this = this;

          this.o = o;
          this.jsonTags = [];
          this.trail = [];
          filesStorage.readFiles().then(function(files) {
            return _this.getFiles();
          });
        }

        FilesChanged.prototype.getFiles = function() {
          var _this = this;

          return this.o.files.forEach(function(f) {
            var file, newFile, src, z, _i, _len, _results;

            _this.f = f;
            src = f.src.filter(function(filepath) {
              filepath = filepath;
              if (!grunt.file.exists(filepath)) {
                grunt.log.warn("Source file \"" + filepath + "\" not found.");
                return false;
              } else {
                return true;
              }
            }).map(function(filepath) {
              return grunt.file.read(filepath);
            });
            _results = [];
            for (z = _i = 0, _len = src.length; _i < _len; z = ++_i) {
              file = src[z];
              newFile = _this.renderFile({
                file: file,
                fileSrc: f,
                i: z
              });
              _results.push(grunt.file.write("dest/" + f.src[z], newFile));
            }
            return _results;
          });
        };

        FilesChanged.prototype.renderFile = function(o) {
          var $destFile, $tags;

          $destFile = this.wrapFile(o.file);
          $tags = this.getTagsInFile($destFile);
          this.compileTags({
            $tags: $tags
          });
          if (this.getTagsInFile($destFile).length > 0) {
            return this.renderFile({
              file: $destFile.html(),
              fileSrc: o.fileSrc,
              i: ++o.i,
              trail: this.trail
            });
          }
          return $destFile.html();
        };

        FilesChanged.prototype.compileTags = function(o) {
          var compiledTag, jsonTag, tagNum, _i, _len, _ref;

          this.jsonTags = this.getJSONTags({
            tags: o.$tags,
            parent: o.parent
          });
          _ref = this.jsonTags;
          for (tagNum = _i = 0, _len = _ref.length; _i < _len; tagNum = ++_i) {
            jsonTag = _ref[tagNum];
            compiledTag = this.compileTag({
              tagNum: tagNum,
              fileSrc: o.fileSrc,
              $tag: o.$tags[tagNum]
            });
          }
          return this.jsonTags;
        };

        FilesChanged.prototype.compileTag = function(o) {
          var $dest, $tags, jsonTags, name, patt, tag, value, _ref;

          tag = filesStorage.files[this.jsonTags[o.tagNum].key];
          _ref = this.jsonTags[o.tagNum];
          for (name in _ref) {
            value = _ref[name];
            patt = new RegExp("\\$" + name, 'gi');
            tag = tag != null ? tag.replace(patt, value) : void 0;
          }
          $(o.$tag).replaceWith(tag);
          $dest = this.wrapFile(tag);
          $tags = this.getTagsInFile($dest);
          if ($tags.length) {
            jsonTags = this.getJSONTags({
              tags: $tags,
              parent: this.jsonTags[o.tagNum].key
            });
          }
          return tag;
        };

        FilesChanged.prototype.getJSONTags = function(o) {
          var attr, i, jsonTags, tagNum, _i, _j, _len, _ref, _ref1;

          jsonTags = [];
          for (tagNum = _i = 0, _ref = o.tags.length; 0 <= _ref ? _i < _ref : _i > _ref; tagNum = 0 <= _ref ? ++_i : --_i) {
            jsonTags[tagNum] = {};
            _ref1 = o.tags[tagNum].attributes;
            for (i = _j = 0, _len = _ref1.length; _j < _len; i = ++_j) {
              attr = _ref1[i];
              jsonTags[tagNum][attr.nodeName] = attr.nodeValue;
              jsonTags[tagNum]['parentName'] = o.parent;
            }
            console.log(jsonTags[tagNum].key);
          }
          return jsonTags;
        };

        FilesChanged.prototype.wrapFile = function(file) {
          return $(file).wrap('<div>').parent();
        };

        FilesChanged.prototype.getTagsInFile = function($file) {
          return $file.find('layout');
        };

        return FilesChanged;

      })();
      return filesChanged = new FilesChanged({
        files: this.files
      });
    });
  };

}).call(this);
