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

Solutions are also provided in the [solutions](SOLUTIONS.md) file, but try to implement the functions yourself first. If you get stuck, take a look at the solutions to get an idea of how to proceed.

## 1. Generate a new private key

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

## 2-5. Initialize a BIP84 (Native SegWit) wallet

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

## 6. Initialize a Blockchain data source

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

## 7. Sync the wallet

The `Wallet` instance can now use the `Blockchain` instance to sync whenever we want to refresh the wallet data like utxo's and transaction history. The `Wallet` class provides a `sync` function to do this. Use this function in the `sync` function of the `BitcoinWalletService` class to complete step 7:

```dart
@override
Future<void> sync() async {
    if (!hasWallet) return;

    // 7. Sync the wallet with the blockchain
}
```

## 8. Get the spendable balance

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

## 9. Generate a new address

The `Wallet` class can be used to derive new addresses from the descriptors or to get the addresses at specific indexes.

For our app now, use a new `AddressIndex` instance. This will increment the descriptor and generate a different address every time we request a new address. This is important for privacy reasons, since we don't want to reuse addresses.

```dart
@override
Future<String> generateInvoice() async {
    // 9. Get a new unused address from the wallet and return it as a String.

    return '';
}
```

## 10. Get the transaction history

The `Wallet` class can be used to list all the transactions of the wallet. It will return some `TransactionDetails` instances that contain information about the transaction like the transaction id, the sum of owned transaction outputs in the transaction, the sum of spent transaction inputs, the confirmation timestamp, the fee if confirmed and optionally the serialized transaction hex. The latter can be used to parse the transaction yourself and get more details about it.
For this workshop we are only interested in the transaction id, the received and sent amounts and the timestamp. Please implement step 10 in the `getTransactions` function of the `BitcoinWalletService` class:

```dart
@override
Future<List<TransactionEntity>> getTransactions() async {
    // 10. Get the list of transactions from the wallet and return them as a list of `TransactionEntity` instances.

    return [];
}
```

## 11-21. Pay to an address

The BDK library offers a `TxBuilder` class to help with building different kind of transactions making it very flexible.
For example, you can build a transaction with RBF (Replace-By-Fee) enabled on the transaction, which allows you to bump the fee of the transaction later if it is not confirming fast enough. This way your user can try to send the transaction with a low fee first and then bump the fee if needed.

Once a transaction is built, it can be signed with a `Wallet` instance and be distributed to the Bitcoin network through a `Blockchain` instance.

Try to implement the following steps in the `pay` function of the `BitcoinWalletService` class:

```dart
@override
Future<String> pay(
String invoice, {
required int amountSat,
double? satPerVbyte,
int? absoluteFeeSat,
}) async {
    // 11. Convert the invoice String to a BDK Address type

    // 12. Use the address to get the script that would lock a transaction output to the address

    // 13. Initialize a `TxBuilder` instance.

    // 14. Add the recipient and the amount to send to the transaction builder.

    // 15. Set the fee rate for the transaction based on the provided fee rate or absolute fee on the transaction builder.

    // 16. Enable RBF (Replace-By-Fee) on the transaction builder

    // 17. Finish the transaction building

    // 18. Sign the transaction with the wallet

    // 19. Extract the transaction as bytes from the finalized and signed PSBT

    // 20. Broadcast the transaction to the network with the `Blockchain` instance

    // 21. Return the transaction id
    return '';
}
```

> [!NOTE]
> If you enabled RBF and want to bump the fee of a transaction, you should build a new transaction to replace the original one. This can not be done by the regular `TxBuilder` class, but a special `BumpFeeTxBuilder` class is provided by the BDK library for this purpose where you pass the id of the transaction to replace and the new, higher fee rate: `BumpFeeTxBuilder(txid: <txId>, feeRate: <feeRate>);`. After this you can build the rest of the transaction, like enabling RBF again, and sign it as usual.
>
> There is one thing to keep in mind when bumping the fee of a transaction and that is that the new transaction will have a different transaction id than the original transaction. This means that the new transaction will be a different transaction than the original and the original will not be confirmed. This is because the transaction id is a hash of the transaction data and the transaction data includes the fee. So if the fee changes, the transaction id changes.

## Wrap-up

That's it! You have now implemented the basic functionalities of a Bitcoin on-chain wallet in Flutter using the `bdk_flutter` package. You can now run the app and test the different functions of the wallet. You can generate new addresses, send transactions, get the transaction history and the balance of the wallet and more. Try sending and receiving between other participants of the workshop, since you are all connected to `Signet`, you can test this between each other without any real costs.

## Extra

In the following sections we will discuss some extra functionalities that are not implemented in the workshop, but are good to know about when building a Bitcoin wallet app.

### Transaction fees

#### Setting the fee rate

We already have the code in place to set the fee rate for a transaction in the `pay` method of the `BitcoinWalletService`. We can set the fee rate in satoshis per vbyte or we can set the absolute fee in satoshis. **But how do we know what the fee rate to set should be? How does our user now what fee to set?** This is a very important question and a very difficult one to answer. The fee rate is a very dynamic thing and depends on a lot of factors. It is not only the size of the transaction that determines the fee rate, but also the demand for block space. The demand for block space can change from minute to minute and so it is difficult to predict. This is why it is very difficult to estimate the fee rate and why it is a good practice to let the user set the fee rate themselves.

Let's do a quick intermezzo about fee rates in Bitcoin to understand this better.

##### Fee rate intermezzo

In Bitcoin, when making a transaction you are competing with other transactions to be included in a block. Bitcoin has a limited block size and miners try to maximize the profit they can make with the limited space they have in a block. So generally you will have to pay a higher absolute fee for a bigger transaction (for example a tx with more inputs or outputs) then for a smaller transaction both wanting to be confirmed at a certain instance. So with the fee you are actually paying for the space you are taking up in a block. That's why fee rates are expressed in satoshis per vbyte. Like this you can compare the fee rates of different transactions, even if they have different sizes and different absolute fees.

Before SegWit, the size of a transaction was the size of the transaction in bytes and a block could only contain one megabyte of transactions. This meant that the fee rate was calculated by dividing the fee in satoshis by the size of the transaction in real bytes.

With SegWit, vbytes got introduced as the measuring unit instead. A vbyte is a virtual byte and one byte in a legacy transaction is equivalent to 4 weight units in a SegWit transaction. This is because the witness data of a SegWit transaction is discounted in the fee calculation, since it is not stored in the blockchain, but kept by the nodes that validate the transactions. Implicitly increasing the size that all transactions in a block can have to 4 megabytes, without increasing the block size limit itself, hereby avoiding a hard fork.

Except for making SegWit transactions occupy less space in a block and thus be cheaper, it also solved a problem of transaction malleability and made it possible to implement the Lightning Network. Diving deeper into SegWit is out of scope for this workshop, but it is good to know that the fee rate is expressed in satoshis per vbyte and that the fee rate is calculated by dividing the fee in satoshis by the size of the transaction in vbytes.

#### Fee estimation

Although different factors can influence the fee rate one needs or wants to set, we can use data from the mempool to give an estimate of which fee rate to set to get included within a certain number of future blocks. The mempool is the place on every node where all unconfirmed transactions are stored and so how much they are offering to pay in fees. The node our application is connected to through the BDK library also has its own copy of the mempool and can give us access to this data. This data can be used to estimate the fee rate we should set for our transaction to be confirmed in a certain amount of blocks. BDK exposes this data through the `Blockchain` class and its `estimateFee` method as you can see in the `calculateFeeRates` function of the `BitcoinWalletService` class:

```dart
Future<RecommendedFeeRatesEntity> calculateFeeRates() async {
    final [highPriority, mediumPriority, lowPriority, noPriority] =
        await Future.wait(
      [
        _blockchain.estimateFee(1),
        _blockchain.estimateFee(2),
        _blockchain.estimateFee(3),
        _blockchain.estimateFee(4),
      ],
    );

    return RecommendedFeeRatesEntity(
      highPriority: highPriority.asSatPerVb(),
      mediumPriority: mediumPriority.asSatPerVb(),
      lowPriority: lowPriority.asSatPerVb(),
      noPriority: noPriority.asSatPerVb(),
    );
}
```

The `estimateFee` method takes a target as a parameter, which is the amount of blocks transactions with the returned fee would most probably be confirmed in. Of course this is an estimation and not a guarantee, but it can give you an idea of what fee rate you should set.

As the targets of blocks to get confirmed in we just took 1, 2, 3 and 4 blocks. This is just an example and you could use different targets based on your own criteria or based on the backend you are connected to. This latter is something important to mention, because the mempool of different nodes can have different data based on their mempool policies, and the way they calculate fees can also be different. So it is important to know which node you are connected to and to know how it calculates fees.

In the case of `Signet`, because of the low volume of transactions there might not be real fee market dynamics. All transactions in the mempool might fit in the next block, for which the fee estimation will give the same low fee rate for all targets. This is why testing of fee estimations should be done on the Bitcoin `Mainnet`. If you would like to test this out for yourself, you can just change the Esplora server to a `Mainnet` esplora server in the `BitcoinWalletService` class and change the network to `Network.Bitcoin` everywhere in the class.

### Coin selection or Coin control

Coin selection is the process of selecting which utxo's to spend in a transaction. How you select the utxo's can be based on different strategies and can be done manually or automatically.

For privacy reasons it is considered a good practice to consciously select the utxo's to spend in a transaction. This is because the utxo's you spend in a transaction can be linked to each other and to you. If you spend utxo's that are not linked to each other and to you, it is harder for an observer to link them to you. You could for example not use a certain utxo in a transaction because it is linked to a certain other utxo that you don't want the receiver to know is yours. Or you may not want to use a big utxo in a small transaction because you don't want the receiver to know you have such a big utxo.

There are many things to take into consideration. If your users are not privacy conscious, you could use the [default coin selection strategy of the BDK library](https://docs.rs/bdk/latest/bdk/wallet/coin_selection/struct.BranchAndBoundCoinSelection.html), which is the Branch and Bound algorithm. This algorithm selects the utxo's that minimize the amount of change and the number of utxo's used by looking for a combination of utxo's that gives the exact amount needed in the transaction. This is a good strategy for most users, but is focused more on reducing fees and “dust” (or, worthless coins), not on optimizing privacy.

For users that do care about privacy, BDK does offer us the flexibility to implement our own coin selection strategy or implement a way to let the user select the utxo's manually. This is a bit more advanced and we will not implement it in this workshop, but it is good to know that it is possible. There are different methods available for this in the `TxBuilder` and `Wallet` classes of the BDK library:

```dart
TxBuilder().addUtxo(outpoint); // Add a specific utxo to spend in the transaction
TxBuilder().addUtxos(outpoints); // Add a list of specific utxo's to spend in the transaction
TxBuilder().doNotSpendChange(); // Makes sure no change utxo's are spent in the transaction
TxBuilder().addUnSpendable(unSpendable); // Add a specific utxo to not spend in the transaction
TxBuilder().manuallySelectedOnly(); // Makes sure only manually selected utxo's are spent in the transaction
TxBuilder().onlySpendChange(); // Makes sure only change utxo's are spent in the transaction
_wallet.listUnspent(); // List all utxo's of the wallet (_wallet is a `Wallet` instance)
```

Manual coin selection generally goes hand in hand with coin labeling. Coin labeling is the process of labeling utxo's with metadata to be able to select them manually. This metadata can be anything you want, for example a label to know the provenance of a utxo, like for example "payment dinner from Alice", "withdraw from exchange X" etc. This can help people to remember which utxo's are linked to each other and to them and to select them manually in a transaction. Some Bitcoiners use this to maintain a KYC-free utxo set, which is a set of utxo's that are not linked to their identity. Labeling utxo's is something not supported by the BDK library, but it is possible to implement it yourself by using the `Wallet` instance to list the utxo's and store the metadata in a database or file.

To get an idea of how the UX coin selection could be implemented, you can get inspired by the [Bitcoin Design Guide's chapter on Coin Selection](https://bitcoin.design/guide/how-it-works/coin-selection).

### Drain wallet

Another interesting thing to mention is the `drain` method of the `Wallet` class. This method is used to spend all utxo's of the wallet (minus the ones added to the unspendable list) in a single transaction. This can be useful for example when you want to move all funds to a new wallet or to a new address. It can also be useful to consolidate utxo's to reduce the number of utxo's and to reduce the amount of change utxo's. This can be useful to reduce fees and to reduce the amount of dust in the wallet.

```dart
TxBuilder().draiWallet();
```

The method `drainTo` is a variant that will send the change utxo's of the transaction, in case you add utxo's that make the total amount exceed the amount to send to the recipient address, to a specific address instead of back to the wallet:

```dart
TxBuilder().drainTo(<script>);
```
