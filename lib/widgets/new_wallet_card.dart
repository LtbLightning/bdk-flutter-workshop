import 'package:bdk_flutter_workshop/constants/sizes.dart';
import 'package:flutter/material.dart';

class NewWalletCard extends StatelessWidget {
  const NewWalletCard({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(Sizes.p8),
        onTap: onPressed,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
            ),
            Text('Add a new wallet'),
          ],
        ),
      ),
    );
  }
}
