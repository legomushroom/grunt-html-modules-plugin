// Generated by CoffeeScript 1.6.2
(function() {
  "use strict";  module.exports = function(grunt) {
    var $, Files, data, filesStorage, fs;

    fs = require('fs');
    $ = require('jquery');
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
            return fs.readFile(_this.dir + file, 'utf-8', function(err, html) {
              err && ((function() {
                throw err;
              })());
              _this.files[file.split('.')[0]] = html;
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
      var FilesChanged, filesChanged, options;

      options = this.options({
        punctuation: ".",
        separator: ", "
      });
      FilesChanged = (function() {
        function FilesChanged(o) {
          var _this = this;

          this.o = o;
          this.files = [];
          this.compiled = '';
          filesStorage.readFiles().then(function(files) {
            return _this.getFiles().then(function() {});
          });
        }

        FilesChanged.prototype.getFiles = function() {
          var _this = this;

          this.dfr = new $.Deferred;
          this.o.files.forEach(function(f) {
            var $destFile, $tags, attr, i, j, src, _i, _j, _len, _ref, _ref1, _results;

            src = f.src.filter(function(filepath) {
              if (!grunt.file.exists(filepath)) {
                grunt.log.warn("Source file \"" + filepath + "\" not found.");
                return false;
              } else {
                return true;
              }
            }).map(function(filepath) {
              return grunt.file.read(filepath);
            });
            $destFile = $(src[0]).wrap('<div>').parent();
            _this.$destFile = $destFile;
            $tags = $destFile.find('layout');
            _this.$tags = $tags;
            _results = [];
            for (j = _i = 0, _ref = $tags.length; 0 <= _ref ? _i < _ref : _i > _ref; j = 0 <= _ref ? ++_i : --_i) {
              _this.files[j] = {};
              _ref1 = $tags[j].attributes;
              for (i = _j = 0, _len = _ref1.length; _j < _len; i = ++_j) {
                attr = _ref1[i];
                _this.files[j][attr.nodeName] = attr.nodeValue;
              }
              _this.compile(j, f);
              if (j === $tags[j].attributes.length - 1) {
                _results.push(_this.dfr.resolve(_this.files));
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          });
          return this.dfr.promise();
        };

        FilesChanged.prototype.compile = function(j, f) {
          var file, name, patt, value, _ref;

          file = filesStorage.files[this.files[j].key];
          _ref = this.files[j];
          for (name in _ref) {
            value = _ref[name];
            patt = new RegExp("\\$" + name, 'gi');
            file = file.replace(patt, value);
          }
          $(this.$tags[j]).replaceWith(file);
          return grunt.file.write(f.dest + 'aa.html', this.$destFile.html());
        };

        return FilesChanged;

      })();
      return filesChanged = new FilesChanged({
        files: this.files
      });
    });
  };

}).call(this);
