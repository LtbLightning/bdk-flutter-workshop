import 'package:bdk_flutter_workshop/features/wallet_actions/request/request_state.dart';
import 'package:bdk_flutter_workshop/services/wallets/wallet_service.dart';

class RequestController {
  final RequestState Function() _getState;
  final Function(RequestState state) _updateState;
  final WalletService _bitcoinWalletService;

  RequestController({
    required getState,
    required updateState,
    required bitcoinWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _bitcoinWalletService = bitcoinWalletService;

  void amountChangeHandler(String? amount) async {
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(
          _getState().copyWith(amountSat: 0, isInvalidAmount: false),
        );
      } else {
        final amountBtc = double.parse(amount);
        final int amountSat = (amountBtc * 100000000).round();
        _updateState(
          _getState().copyWith(amountSat: amountSat, isInvalidAmount: false),
        );
      }
    } catch (e) {
      print(e);
      _updateState(_getState().copyWith(isInvalidAmount: true));
    }
  }

  void labelChangeHandler(String? label) async {
    if (label == null || label.isEmpty) {
      _updateState(_getState().copyWith(label: ''));
    } else {
      _updateState(_getState().copyWith(label: label));
    }
  }

  void messageChangeHandler(String? message) async {
    if (message == null || message.isEmpty) {
      _updateState(_getState().copyWith(message: ''));
    } else {
      _updateState(_getState().copyWith(message: message));
    }
  }

  Future<void> generateInvoice() async {
    try {
      _updateState(_getState().copyWith(isGeneratingInvoice: true));

      final invoice = await _bitcoinWalletService.generateInvoice();
      _updateState(_getState().copyWith(bitcoinInvoice: invoice));
    } catch (e) {
      print(e);
    } finally {
      _updateState(_getState().copyWith(isGeneratingInvoice: false));
    }
  }

  void editInvoice() {
    _updateState(const RequestState());
  }
}
