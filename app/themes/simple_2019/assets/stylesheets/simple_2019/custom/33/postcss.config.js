let path = require('path');
let fs = require('fs');
let outputPath = "public/packs/" + path.dirname(__filename).split(path.sep).pop();

if (!fs.existsSync(outputPath)) {
  fs.mkdirSync(outputPath, {recursive: true}, (err) => {
    if (err) throw err;
  });
}

module.exports = {
  plugins: {
    //require('postcss-import'),
    'postcss-flexbugs-fixes': {},
    'postcss-critical-css': {
      outputPath: "public/packs/" + path.dirname(__filename).split(path.sep).pop(),
      outputDest: "critical.css",
      preserve: false
    },
    'postcss-preset-env': {
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }
  }
};
