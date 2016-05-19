(function() {

  var process = require('process');

  if ( process.argv.length < 4 ) {

    process.stderr.write("usage: tools/tc.js <module> <template file>\n");
    process.exit(1);

  }

  var fs = require('fs');

  var input = fs.readFileSync(process.argv[3], {encoding:'utf8'});

  var tc = require('./../vendor/tc.js');

  var template = tc.precompile(input);

  process.stdout.write(
    'export default ' +
    template +
    ';');

}).call(this);
