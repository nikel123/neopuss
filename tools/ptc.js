var process = require('process');
var fs = require('fs');
var tc = require('./../vendor/tc.js');

var argv = process.argv;
var stdout = process.stdout;
var i = 2;
var e = argv.length;
var input;
var fname;

var reg_name = function() {
  var name;
  if ( arguments[3] == 'component' ) {
    name = 'components/' + arguments[2].replace('/', '-');
  } else {
    name = arguments[2];
  }
  return 'App.register(\'template:'+name+'\', Ember.HTMLBars.template(';
}

for(; i < e; ++i) {

  fname = argv[i];
  input = fs.readFileSync(fname, {encoding:'utf8'});
  stdout.write(
      fname.replace(
          /^([^\/]*\/)app\/(.*)[\.\/]([^\.]+)\.hbs$/,
          reg_name) +
      tc.precompile(input) +
    '));\n');

}
