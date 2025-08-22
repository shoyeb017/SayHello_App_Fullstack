import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final Color? color;

  const LoadingWidget({Key? key, this.message = 'Loading...', this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
