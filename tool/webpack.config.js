const path = require('path');

module.exports = {
    entry: './src/loader.js',
    output: {
        filename: 'loader.js',
        path: path.join(process.cwd(), '../assets'),
        asyncChunks: false
    },
    resolve: {
        fallback: {
            "stream": require.resolve("stream-browserify"),
            "crypto": require.resolve("crypto-browserify")
        }
    }
}