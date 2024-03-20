import 'package:flutter/material.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.isIncoming,
    this.timestamp,
    required this.amountBtc,
  });

  final bool isIncoming;
  final String? timestamp;
  final double amountBtc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
        ),
      ),
      title: Text(
        isIncoming ? 'Received funds' : 'Sent funds',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        timestamp ?? 'Pending',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text('${isIncoming ? '+' : ''}$amountBtc BTC',
          style: theme.textTheme.bodyMedium),
    );
  }
}
