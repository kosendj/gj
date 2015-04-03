module.exports = {
  entry: {
    screen: './src/screen.ls',
    index: './src/index.ls'
  },
  output: {
    path: __dirname + '/build/js',
    filename: '[name].js'
  },
  resolve: {
    extensions: ['', '.ls', '.vue', '.js']
  },
  module: {
    loaders: [
      {
        test: /\.ls$/,
        loader: 'livescript-loader'
      }, {
        test: /\.vue$/,
        loader: 'vue-loader'
      }
    ]
  }
}
