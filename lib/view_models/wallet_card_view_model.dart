import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class WalletCardViewModel extends Equatable {
  const WalletCardViewModel({
    this.label =
        'Savings', // For a real app, the name should be dynamic and be set by the user when adding the wallet and be stored in some local storage.
    required this.balanceSat,
  });

  //final WalletType walletType;
  final String label;
  final int balanceSat;

  double get balanceBtc => balanceSat / 100000000;

  @override
  List<Object> get props => [
        label,
        balanceSat,
      ];
}
