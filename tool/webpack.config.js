const path = require('path');
const fs = require('fs');
const LicenseWebpackPlugin = require('license-webpack-plugin').LicenseWebpackPlugin;
const TerserPlugin = require('terser-webpack-plugin');
const eightyHyphens = new Array(81).join('-');

const additionalLicense = '../PACKAGE_LICENSE';

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
            outputFilename: '../LICENSE'
        })
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
            } else if (module.packageJson.repository.url) {
                text += '\n\n';
                text += module.packageJson.repository.url;
                authorOrUrl = true;
            }
            if (!authorOrUrl) {
                console.log(module);
                throw new Error('Can not find author or url for ' + module.packageJson.name);
            }
        }
        const entry = (module.packageJson.name + '\n\n' + text).trim();
        if (module.licenseText) {
            licenses.unshift(entry);
        } else {
            licenses.push(entry);
        }
    });
    if (typeof (additionalLicense) !== 'undefined') {
        licenses.unshift(fs.readFileSync(additionalLicense).toString());
    }
    return licenses.join('\n' + eightyHyphens + '\n');
}