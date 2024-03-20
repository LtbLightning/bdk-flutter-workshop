# Instructions

## Starting point

### Head start

To implement a complete app including UI components, state management, controllers, repositories etc. we would need a lot more time and it would take us too far from the Bitcoin and `bdk_flutter` specific code. Therefore you get a head start. All needed widgets, screens, entities, view_models, repositories, controllers and state classes are already implemented and ready for you.

Take a look at the different files and folders in the [`lib`](./lib/) folder. This is the folder where the code of a Flutter/Dart app should be located.

> [!NOTE]
> If you cloned this repository, the `bdk_flutter` package is already added to the dependencies in the [`pubspec.yaml`](./pubspec.yaml) file and is ready to be used.

> [!NOTE]
> The minSdkVersion in the [`android/app/build.gradle`](./android/app/build.gradle) file is also changed to 23 already. This is the minimum version required by the `bdk_flutter` package to work on Android.

### Run the app

Start the app to make sure the provided code is working. You should see the user interface of the app, but it does not really permits you to make any transactions yet.

### Wallet service

In the [`lib/services/wallets`](./lib/services/wallets) folder you can find the `wallet_service.dart` file. It provides an abstract `WalletService` class with the main functions a wallet service needs. In the [`impl`](./lib/services/wallets/impl/) folder a class `BitcoinWalletService` is provided to add concrete implementations of those functions for a Bitcoin on-chain wallet. We have left some code out of the `BitcoinWalletService` class. This is what you will complete yourself during the workshop by using the `bdk_flutter` package.

## Let's code

The missing code parts in the `BitcoinWalletService` class have numbered comments to guide you through the implementation one function at a time.

Solutions are also provided in the [`solutions`](./solutions/) folder, but try to implement the functions yourself first. If you get stuck, take a look at the solutions to get an idea of how to proceed.

## Generate a new private key

Bitcoin wallets generally use BIP39 mnemonics or seed phrases to generate and backup the private keys. The BDK library provides a `Mnemonic` class to work with mnemonics.
Use this class to complete step 1 in the `addWallet` function of the `BitcoinWalletService` class:

```dart
@override
Future<void> addWallet() async {
    // 1. Replace the hardcoded test mnemonic with the code to create a new
    //   mnemonic with 12 words every time this function is called.
    final mnemonic = await Mnemonic.fromString(
        'test test test test test test test test test test test test',
    );

    await _mnemonicRepository.setMnemonic(mnemonic.asString());

    await _initWallet(mnemonic);

    print(
        'Wallet added with mnemonic: ${mnemonic.asString()} and initialized!',
    );
}
```

As you can see in the rest of the function, the generated mnemonic is stored in secure storage through a `MnemonicRepository` instance and then used to initialize the wallet. The `MnemonicRepository` class is already implemented in the [`lib/repositories`](./lib/repositories) folder and uses the `flutter_secure_storage` package to store the mnemonic securely. For extra security in a production app though, you should consider encrypting the mnemonic with a PIN encrypted master key instead of storing it in plain text.

## Initialize a BIP84 (Native SegWit) wallet

The `BitcoinWalletService` class has a private field `_wallet` to hold an instance of type `Wallet`. The `Wallet` class is provided by the `bdk_flutter` package and is the main class to work with for a Bitcoin wallet. It can derive addresses, track transactions and utxos related to those addresses and sign transactions. It does this all based on descriptors, which are a way to describe a set of addresses and keys in a wallet.

Now in the `_initWallet` function, you need to initialize the `_wallet` field with a new instance of the `Wallet` class. The wallet should be initialized with a BIP84 descriptor, which is a descriptor for a Native SegWit wallet.

Make sure you use a different output descriptor for external/receive addresses than for internal/change addresses. This is to be able to differentiate between incoming and outgoing transactions (track or audit what you received without revealing what you've spend). The `bdk_flutter` package provides a `Descriptor` class to work with descriptors and the `DescriptorSecretKey` class to create a master secret key from a mnemonic. Use this to implement steps 2 to 5 in the `_initWallet` function:

```dart
Future<void> _initWallet(Mnemonic mnemonic) async {
    // 2. Create the master secret key from the mnemonic

    // 3. Get a BIP84 template descriptor to derive Native SegWit addresses from the secret key to receive external funds (external keychain)

    // 4. Get a BIP84 template descriptor to derive Native SegWit addresses from the secret key to receive change (internal keychain)

    // 5. Create a `Wallet` instance with the descriptors to initialize the `_wallet` field
    //  Use an in-memory database for testing purposes.
}
```

## Initialize a Blockchain data source

To be able to get the utxo's and transaction history of our wallet and to be able to send transactions to the Bitcoin network, we need a Bitcoin node.
As we are building a mobile app, running a full Bitcoin node on the device is currently not feasible. Instead, we will use a remote blockchain data source to get the information we need. The `bdk_flutter` package provides a `Blockchain` class that can be configured with different data sources to connect to like an Esplora or Electrum server or just an RPC connection to a Bitcoin Core node.

Since we may need to interact with this `Blockchain` class in multiple places in the `BitcoinWalletService` class, we already created a private field `_blockchain` in the class to hold an instance of the `Blockchain` class. We also created a private function `_initBlockchain` to initialize this field. It is up to you now to complete this function and initialize the `_blockchain` field with a `Blockchain` instance with the following Esplora server on [Mutinynet](https://blog.mutinywallet.com/mutinynet/) (a custom `Signet` by Mutiny wallet): https://mutinynet.com/api. Please complete step 6 in the `_initBlockchain` function:

```dart
Future<void> _initBlockchain() async {
    // 6. Initialize the `_blockchain` field by creating a new instance of the
    //  `Blockchain` class and configuring it to use an Esplora server on Signet.
    //  For testing purposes, you can use the following Esplora server url:
    //  https://mutinynet.com/api
}
```

## Sync the wallet

The `Wallet` instance can now use the `Blockchain` instance to sync whenever we want to refresh the wallet data like utxo's and transaction history. The `Wallet` class provides a `sync` function to do this. Use this function in the `sync` function of the `BitcoinWalletService` class to complete step 7:

```dart
@override
Future<void> sync() async {
    if (!hasWallet) return;

    // 7. Sync the wallet with the blockchain
}
```

## Get the spendable balance

The `Wallet` class can be used to get the balance of the wallet. Different types of balances exist based on the status of the transactions and utxo's that the wallet received or send. The BDK library provides a `Balance` class that contains the confirmed, spendable, immature, trusted pending, untrusted pending and total balance of the wallet. For our simple on-chain wallet, we are only interested in the spendable balance. Please obtain and return the spendable balance of the wallet in step 8 in the `getSpendableBalanceSat` function of the `BitcoinWalletService` class:

```dart
@override
Future<int> getSpendableBalanceSat() async {
    if (!hasWallet) return 0;

    // 8. Get the balance of the wallet and return the spendable part of it.
    //  For testing purposes, you can just print out the other parts of the balance as well.
    return 0;
}
```
