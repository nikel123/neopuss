(function() {

  var process = require('process');

  if ( process.argv.length < 3 ) {

    process.stderr.write("usage: tools/tc.js <template file>\n");
    process.exit(1);

  }

  var fs = require('fs');

  var input = fs.readFileSync(process.argv[2], {encoding:'utf8'});

  var tc = require('./../vendor/tc.js');

  var template = tc.precompile(input);

  process.stdout.write(
    'export default ' +
    template +
    ';');

}).call(this);
