const {environment} = require('@rails/webpacker');
const webpack = require('webpack');
const CssUrlRelativePlugin = require('css-url-relative-plugin');
const VueLoaderPlugin = require('vue-loader/lib/plugin');

environment.plugins.append('CssUrlRelativePlugin', new CssUrlRelativePlugin());

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    axios: 'axios'
  })
);

environment.loaders.get('sass').use.splice(2, 1, {
  loader: 'resolve-url-loader',
  options: {}
});

environment.loaders.get('sass').use.splice(-1, 0,
  {
    loader: 'postcss-loader',
    options: {
      sourceMap: true
    }
  });

environment.loaders.append("vue", {
  test: /\.vue(\.erb)?$/,
  use: [{
    loader: 'vue-loader'
  }]
});

environment.plugins.append("vue",
  new VueLoaderPlugin()
);

environment.loaders.delete('nodeModules');

module.exports = environment;
