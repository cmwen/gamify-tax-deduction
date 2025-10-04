import 'package:flutter/material.dart';
import '../../core/models/educational_tip.dart';

/// Widget that displays an educational tip in a card format
class EducationalTipCard extends StatelessWidget {
  final EducationalTip tip;
  final VoidCallback? onDismiss;

  const EducationalTipCard({
    super.key,
    required this.tip,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (tip.icon != null) ...[
                  Text(
                    tip.icon!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tip.content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog that shows an educational tip
class EducationalTipDialog extends StatelessWidget {
  final EducationalTip tip;

  const EducationalTipDialog({
    super.key,
    required this.tip,
  });

  static Future<void> show(BuildContext context, EducationalTip tip) {
    return showDialog(
      context: context,
      builder: (context) => EducationalTipDialog(tip: tip),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          if (tip.icon != null) ...[
            Text(tip.icon!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(tip.title),
          ),
        ],
      ),
      content: Text(tip.content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it!'),
        ),
      ],
    );
  }
}

/// Bottom sheet that displays multiple educational tips
class EducationalTipsSheet extends StatelessWidget {
  const EducationalTipsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const EducationalTipsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Tax Deduction Tips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: EducationalTips.all.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final tip = EducationalTips.all[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EducationalTipCard(tip: tip),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
