import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class RequestState extends Equatable {
  const RequestState({
    this.amountSat,
    this.isInvalidAmount = false,
    this.label,
    this.message,
    this.bitcoinInvoice,
    this.isGeneratingInvoice = false,
  });

  final int? amountSat;
  final bool isInvalidAmount;
  final String? label;
  final String? message;
  final String? bitcoinInvoice;
  final bool isGeneratingInvoice;

  double? get amountBtc {
    if (amountSat == null) {
      return null;
    }

    return amountSat! / 100000000;
  }

  String? get bip21Uri {
    if (bitcoinInvoice == null) {
      return null;
    }

    if (amountSat == null && label == null && message == null) {
      return bitcoinInvoice;
    }

    return 'bitcoin:$bitcoinInvoice?'
        '${amountBtc != null ? 'amount=$amountBtc' : ''}'
        '${label != null ? '&label=$label' : ''}'
        '${message != null ? '&message=$message' : ''}';
  }

  RequestState copyWith({
    int? amountSat,
    bool? isInvalidAmount,
    String? label,
    String? message,
    String? bitcoinInvoice,
    bool? isGeneratingInvoice,
  }) {
    return RequestState(
      amountSat: amountSat ?? this.amountSat,
      isInvalidAmount: isInvalidAmount ?? this.isInvalidAmount,
      label: label ?? this.label,
      message: message ?? this.message,
      bitcoinInvoice: bitcoinInvoice ?? this.bitcoinInvoice,
      isGeneratingInvoice: isGeneratingInvoice ?? this.isGeneratingInvoice,
    );
  }

  @override
  List<Object?> get props => [
        amountSat,
        isInvalidAmount,
        label,
        message,
        bitcoinInvoice,
        isGeneratingInvoice,
      ];
}
