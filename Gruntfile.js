/*
 * html-modules
 * https://github.com/legomushroom/grunt-plugin
 *
 * Copyright (c) 2013 LegoMushroom
 * Licensed under the MIT license.
 */

'use strict';

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({

    // Before generating any new files, remove any previously-created files.
    clean: {
      tests: ['tmp'],
    },

    // Configuration to be run (and then tested).
    html_modules: {
      watch_folder: 'html-test/**/*.html',
      settings:{
        particles: 'html-test/particles/',
        monolits: 'build'
      }
    },

    // Unit tests.
    nodeunit: {
      tests: ['test/*_test.js'],
    },

    watch: {
      tasks: ['html_modules']
    }

  });

  // Actually load this plugin's task(s).
  grunt.loadTasks('tasks');

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');
  grunt.loadNpmTasks('grunt-contrib-watch');


  

};
