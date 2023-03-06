import { BaseWalletAdapter } from '@solana/wallet-adapter-base';
import * as potentialAdapters from '@solana/wallet-adapter-wallets';

const exclude: string[] = ['UnsafeBurnerWalletAdapter', 'BaseSolletWalletAdapter'];

console.log('Generating javascript for loader.js....')

const adapters: string[] = [];
for (const member in potentialAdapters) {
  if (exclude.includes(member)) {
    continue;
  }
  try {
    const maybeAdapter = new (<any>potentialAdapters)[member]();
    if (maybeAdapter instanceof BaseWalletAdapter) {
      adapters.push(member);
    }
  } catch (e: any) {
    if (e instanceof TypeError) {
      if (!e.message.endsWith('is not a constructor')) {
        throw e;
      }
    } else {
      throw e;
    }
  }
}

if (adapters.length == 0) {
  throw new Error('No adapter found?!');
}

console.log('#########################################');
console.log('import {');
for (const adapter of adapters) {
  console.log('    ' + adapter + ',');
}
console.log('} from \'@solana/wallet-adapter-wallets\';');
console.log();
console.log('const _wallets = [');
for (const adapter of adapters) {
  console.log('    new ' + adapter + '(),');
}
console.log('];');
console.log('#########################################');