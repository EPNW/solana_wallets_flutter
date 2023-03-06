This tool is used to generate a single JavaScript file containing all stuff needed to use the functionallity provided by `@solana/wallet-adapter-wallets`.
The version `"@solana/wallet-adapter-wallets": "0.19.15"` is fixed to ensure compability.

## Usage
First, install dependencies using
```bash
yarn install
```

Then use
```bash
yarn run list-wallets
```
to list all wallets in the used version of the `@solana/wallet-adapter-wallets` package.
Use this information to update `.\src\loader.js`.

Finally, to generate the output file directly into flutters asset folder run 
```bash
npx webpack
```
LICENSES of the used node packages will be automatically added to flutter (by writing them to `.\lib\src\js_licenses.dart`). Make sure to check to console output of webpack for `IMPORTANT` messages about urls!