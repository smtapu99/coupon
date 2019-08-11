let fs = require('fs');
let outputPath = "public/packs/";

if (!fs.existsSync(outputPath)) {
  fs.mkdirSync(outputPath, {recursive: true}, (err) => {
    if (err) throw err;
  });
}

module.exports = {
  plugins: {
    //require('postcss-import'),
    'postcss-critical-css': {
      outputPath: outputPath,
      outputDest: "critical.css",
      preserve: false
    },
    'postcss-flexbugs-fixes': {},
    'postcss-preset-env': {
      autoprefixer: true,
      stage: 3
    }
  }
};
