import 'package:bdk_flutter_workshop/features/home/home_state.dart';
import 'package:bdk_flutter_workshop/services/wallets/wallet_service.dart';
import 'package:bdk_flutter_workshop/view_models/transaction_list_item_view_model.dart';
import 'package:bdk_flutter_workshop/view_models/wallet_card_view_model.dart';

class HomeController {
  final HomeState Function() _getState;
  final Function(HomeState state) _updateState;
  final WalletService _bitcoinWalletService;

  HomeController({
    required getState,
    required updateState,
    required bitcoinWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _bitcoinWalletService = bitcoinWalletService;

  Future<void> init() async {
    if (_bitcoinWalletService.hasWallet) {
      _updateState(
        _getState().copyWith(
          walletCard: WalletCardViewModel(
            balanceSat: await _bitcoinWalletService.getSpendableBalanceSat(),
          ),
          transactions: await _getTransactions(),
        ),
      );
    } else {
      _updateState(_getState().copyWith(
        clearWalletCard: true,
        transactions: [],
      ));
    }
  }

  Future<void> addNewWallet() async {
    try {
      await _bitcoinWalletService.addWallet();
      _updateState(
        _getState().copyWith(
          walletCard: WalletCardViewModel(
            balanceSat: await _bitcoinWalletService.getSpendableBalanceSat(),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWallet() async {
    try {
      await _bitcoinWalletService.deleteWallet();
      _updateState(_getState().copyWith(clearWalletCard: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> refresh() async {
    try {
      final state = _getState();
      if (state.walletCard == null) {
        // No wallet to refresh
        return;
      }

      await _bitcoinWalletService.sync();
      final balance = await _bitcoinWalletService.getSpendableBalanceSat();
      _updateState(
        state.copyWith(
          walletCard: WalletCardViewModel(
            balanceSat: balance,
          ),
          transactions: await _getTransactions(),
        ),
      );
    } catch (e) {
      print(e);
      // ToDo: handle and set error state
    }
  }

  Future<List<TransactionListItemViewModel>> _getTransactions() async {
    // Get transaction entities from the wallet
    final transactionEntities = await _bitcoinWalletService.getTransactions();
    // Map transaction entities to view models
    final transactions = transactionEntities
        .map((entity) =>
            TransactionListItemViewModel.fromTransactionEntity(entity))
        .toList();
    // Sort transactions by timestamp in descending order
    transactions.sort((t1, t2) {
      if (t1.timestamp == null && t2.timestamp == null) {
        return 0;
      }
      if (t1.timestamp == null) {
        return -1;
      }
      if (t2.timestamp == null) {
        return 1;
      }
      return t2.timestamp!.compareTo(t1.timestamp!);
    });
    return transactions;
  }
}
