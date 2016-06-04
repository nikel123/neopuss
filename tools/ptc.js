var process = require('process');
var fs = require('fs');
var tc = require('./../vendor/tc.js');

var argv = process.argv;
var stdout = process.stdout;
var i = 2;
var e = argv.length;
var input;
var fname;

for(; i < e; ++i) {

  fname = argv[i];
  input = fs.readFileSync(fname, {encoding:'utf8'});
  stdout.write(
      fname.replace(
          /^([^\/]*\/)app\/(.*)[\.\/]([^\.]+)\.hbs$/,
          'App.register(\'$3:$2\', Ember.HTMLBars.template(') +
      tc.precompile(input) +
    '));\n');

}
