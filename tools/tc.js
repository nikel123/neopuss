(function(namespace,suffix) {

  var process = require('process');

  if ( process.argv.length < 3 ) {
    process.stderr.write("usage: tools/tc.js <module name> <template file>\n");
    process.exit(1);
  }

  var fname = process.argv[2];

  var fs = require('fs');
  var input = fs.readFileSync(fname, {encoding:'utf8'});

  var tc = require('./../vendor/tc.js');

  process.stdout.write(
      fname.replace(
          /^([^\/]*\/)app\/(.*)[\.\/]([^\.]+)\.hbs$/,
          'App.register(\'$3:$2\', Ember.HTMLBars.template(') +
      tc.precompile(input) +
    '));\n');

})();
