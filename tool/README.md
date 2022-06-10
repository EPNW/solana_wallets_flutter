This project is used to generate a single JavaScript file containing all stuff needed to use the functionallity provided by `@solana/wallet-adapter-wallets`. The version `"@solana/wallet-adapter-wallets": "0.16.1"` is hardcoded to ensure compability. To generate the output file directly into flutters asset folder run 
```bash
yarn install
npx webpack
```
Don't forget to merge the `loader.js.LICENSE.txt` with the `LICENSE` file in this flutter packages root.