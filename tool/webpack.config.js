const path = require('path');
const webpack = require('webpack');
const LicenseWebpackPlugin = require('license-webpack-plugin').LicenseWebpackPlugin;
const TerserPlugin = require('terser-webpack-plugin');

class DartFromatPlugin {
    apply(compiler) {
        compiler.hooks.afterEmit.tapAsync('DartFormat', (compilation, callback) => {
            var dartAssets = [];
            compilation.getAssets().forEach((asset) => {
                if (asset.name.endsWith('.dart')) {
                    dartAssets.push(path.join(process.cwd(), asset.name));
                }
            });
            dartFormatAll(dartAssets, callback);
        });
    }
}

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
    },
    optimization: {
        minimize: true,
        minimizer: [
            new TerserPlugin({
                extractComments: false,
                terserOptions: {
                    format: {
                        comments: false,
                    },
                },
            }),
        ],
    },
    plugins: [
        new LicenseWebpackPlugin({
            perChunkOutput: false, // combine all license information into one file
            renderLicenses: formatLicenses,
            outputFilename: '../lib/src/js_licenses.dart'
        }),
        new webpack.ProvidePlugin({
            Buffer: ['buffer', 'Buffer']
        }),
        new DartFromatPlugin()
    ]
}


function formatLicenses(modules) {
    var licenses = [];
    modules.forEach((module) => {
        var text;
        if (module.licenseText) {
            text = module.licenseText;
        } else {
            text = '';
            authorOrUrl = false;
            if (module.packageJson.author) {
                text += module.packageJson.author;
                text += ' - ';
                authorOrUrl = true;
            }
            if (typeof module.licenseId !== 'undefined') {
                text += module.licenseId;
            } else {
                console.log(module);
                throw new Error('Can not find licenseId for ' + module.packageJson.name);
            }
            if (module.packageJson.homepage) {
                text += '\n\n';
                text += module.packageJson.homepage;
                authorOrUrl = true;
            } else if (module.packageJson.repository && module.packageJson.repository.url) {
                text += '\n\n';
                text += module.packageJson.repository.url;
                authorOrUrl = true;
            }
            if (!authorOrUrl) {
                //console.log(module);
                //throw new Error('Can not find author or url for ' + module.packageJson.name);
                fallback = 'https://www.npmjs.com/package/' + module.name;
                logImportant('Can not find author or url for ' + module.packageJson.name + '! Falling back to ' + fallback + '. Make sure that this website actually exists!');
                text += '\n\n';
                text += fallback;
            }
        }
        const entry = 'LicenseEntryWithLineBreaks([\'' + module.packageJson.name + '\'],\'\'\'' + text.trim() + '\'\'\')';
        if (module.licenseText) {
            licenses.unshift(entry);
        } else {
            licenses.push(entry);
        }
    });
    return dartCodeStart + licenses.join(',\r\n') + dartCodeEnd;
}

const dartCodeStart = '//\r\n// GENERATED FILE. DO NOT EDIT!\r\n//\r\n\r\n// ignore_for_file: directives_ordering\r\n// ignore_for_file: lines_longer_than_80_chars\r\n// ignore_for_file: depend_on_referenced_packages\r\n\r\nimport \'package:flutter/foundation.dart\';\r\n\r\nvoid registerJavaScriptLicenses() {\r\n  LicenseRegistry.addLicense(() => new Stream.fromIterable(_entries));\r\n}\r\n\r\nconst List<LicenseEntry> _entries = [';
const dartCodeEnd = '];';

//https://nodejs.org/docs/v0.4.6/api/child_processes.html#child_process.exec
function dartFormatAll(dartFiles, callback) {
    const exec = require('child_process').exec;
    function formatRecursion(files, recursionCallback, errorCount) {
        if (files.length == 0) {
            recursionCallback(errorCount);
        } else {
            var current = files.pop();
            exec('dart format ' + current, (error) => {
                if (error !== null) {
                    logImportant('Could not format ' + current + ' due to:');
                    console.warn(error);
                    errorCount++;
                }
                formatRecursion(files, recursionCallback, errorCount);
            });
        }
    }
    formatRecursion(dartFiles, (errorCount) => {
        if (errorCount > 0) {
            logImportant('Code generation successful, but formating of some dart files failed. Try to format the respective files manually!');
        }
        callback();
    }, 0);
}

function logImportant(msg) {
    console.warn('\033[35mIMPORTANT: ' + msg + '\033[0m');
}
