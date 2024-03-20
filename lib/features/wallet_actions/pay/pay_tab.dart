import 'package:bdk_flutter_workshop/constants/sizes.dart';
import 'package:bdk_flutter_workshop/features/wallet_actions/pay/pay_controller.dart';
import 'package:bdk_flutter_workshop/features/wallet_actions/pay/pay_state.dart';
import 'package:bdk_flutter_workshop/services/wallets/wallet_service.dart';
import 'package:flutter/material.dart';

class PayTab extends StatefulWidget {
  const PayTab({required this.bitcoinWalletService, super.key});

  final WalletService bitcoinWalletService;

  @override
  PayTabState createState() => PayTabState();
}

class PayTabState extends State<PayTab> {
  PayState _state = const PayState();
  late PayController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PayController(
      getState: () => _state,
      updateState: (PayState state) => setState(() => _state = state),
      bitcoinWalletService: widget.bitcoinWalletService,
    );

    _controller.fetchRecommendedFeeRates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: Sizes.p16),
        // Amount Field
        SizedBox(
          width: 250,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Amount',
              hintText: '0',
              helperText: 'The amount you want to send in BTC.',
            ),
            onChanged: _controller.amountChangeHandler,
          ),
        ),
        const SizedBox(height: Sizes.p16),
        // Invoice Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Invoice',
              hintText: '1bc1q2c3...',
              helperText: 'The invoice to pay.',
            ),
            onChanged: _controller.invoiceChangeHandler,
          ),
        ),
        const SizedBox(height: Sizes.p16),
        // Fee rate slider
        _state.recommendedFeeRates == null
            ? const CircularProgressIndicator()
            : SizedBox(
                width: 250,
                child: Column(
                  children: [
                    Slider(
                      value: _state.satPerVbyte ?? 0,
                      onChanged: _controller.feeRateChangeHandler,
                      divisions: _state.recommendedFeeRates!.length - 1 > 0
                          ? _state.recommendedFeeRates!.length - 1
                          : 1,
                      min: _state.recommendedFeeRates!.last,
                      max: _state.recommendedFeeRates!.first,
                      label: _state.satPerVbyte! <=
                              _state.recommendedFeeRates!.last
                          ? 'low priority'
                          : _state.satPerVbyte! >=
                                  _state.recommendedFeeRates!.first
                              ? 'high priority'
                              : 'medium priority',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.p12,
                      ),
                      child: Text(
                        'The fee rate to pay for this transaction: ${_state.satPerVbyte == null ? 0 : _state.satPerVbyte!.toStringAsFixed(0)} sat/vB.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
        const SizedBox(height: Sizes.p16),
        // Error message
        SizedBox(
          height: Sizes.p16,
          child: Text(
            widget.bitcoinWalletService.hasWallet
                ? _state.error is InvalidAmountException
                    ? 'Please enter a valid amount.'
                    : _state.error is NotEnoughFundsException
                        ? 'Not enough funds available.'
                        : _state.error is PaymentException
                            ? 'Failed to make payment. Please try again.'
                            : ''
                : 'You need to create a wallet first.',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: Sizes.p16),
        // Send funds Button
        ElevatedButton.icon(
          onPressed: !widget.bitcoinWalletService.hasWallet ||
                  _state.amountSat == null ||
                  _state.amountSat == 0 ||
                  _state.invoice == null ||
                  _state.invoice!.isEmpty ||
                  _state.error is InvalidAmountException ||
                  _state.error is NotEnoughFundsException ||
                  _state.isMakingPayment
              ? null
              : () => _controller.makePayment().then(
                    (_) {
                      if (_state.txId != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Payment successful. Tx ID: ${_state.partialTxId}'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
          label: const Text('Send funds'),
          icon: _state.isMakingPayment
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        ),
      ],
    );
  }
}
