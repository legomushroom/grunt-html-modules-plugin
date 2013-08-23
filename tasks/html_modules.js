// Generated by CoffeeScript 1.6.2
(function() {
  "use strict";  module.exports = function(grunt) {
    var Files, data, files, fs;

    console.log('run');
    fs = require('fs');
    data = {};
    Files = (function() {
      function Files(o) {
        this.o = o;
        this.fs = fs;
        this.dir = 'tasks/src/';
        this.pt = {};
        this.readFiles();
      }

      Files.prototype.readFiles = function() {
        var _this = this;

        return this.fs.readdir(this.dir, function(err, files) {
          var c;

          if (err) {
            throw err;
          }
          c = 0;
          return files.forEach(function(file) {
            if (!file.match(/.html$/gi)) {
              return;
            }
            c++;
            return fs.readFile(_this.dir + file, 'utf-8', function(err, html) {
              err && ((function() {
                throw err;
              })());
              _this.pt[file.split('.')[0]] = html;
              return console.log('1');
            });
          });
        });
      };

      return Files;

    })();
    files = new Files;
    console.log('2');
    return grunt.registerMultiTask("html_modules", "allows to include small html parts in other html", function() {
      var options;

      options = this.options({
        punctuation: ".",
        separator: ", "
      });
      return this.files.forEach(function(f) {
        var src;

        src = f.src.filter(function(filepath) {
          if (!grunt.file.exists(filepath)) {
            grunt.log.warn("Source file \"" + filepath + "\" not found.");
            return false;
          } else {
            return true;
          }
        }).map(function(filepath) {
          return grunt.file.read(filepath);
        }).join(grunt.util.normalizelf(options.separator));
        console.log(src);
        return grunt.log.writeln("File \"" + f.dest + "\" created.");
      });
    });
  };

}).call(this);
