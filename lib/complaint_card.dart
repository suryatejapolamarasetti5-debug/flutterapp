import 'package:flutter/material.dart';

import 'animations.dart';
import 'complaint_api_service.dart';
import 'theme.dart';

/// A single complaint rendered as a card, with an "add to cart" action.
class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.isInCart,
    required this.onAddToCart,
    this.onTap,
  });

  final Complaint complaint;
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap;

  Color _statusColor() {
    switch (complaint.status) {
      case 'Resolved':
        return AppThemes.statusResolved;
      case 'In Progress':
        return AppThemes.statusInProgress;
      case 'Rejected':
        return AppThemes.statusRejected;
      default:
        return AppThemes.statusPending;
    }
  }

  String _formatDate() {
    final parsed = DateTime.tryParse(complaint.createdAt);
    if (parsed == null) return complaint.createdAt;

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          complaint.type,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '${complaint.reference} • ${complaint.location}',
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _formatDate(),
                          style: TextStyle(
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  StatusIndicator(
                    status: complaint.status,
                    color: statusColor,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                complaint.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),

              if (complaint.photo != null || complaint.imageUrl != null) ...[
                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: complaint.photo != null
                      ? Image.memory(
                          complaint.photo!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          complaint.imageUrl!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _photoPlaceholder(colorScheme);
                          },
                          loadingBuilder:
                              (context, child, progress) {
                            if (progress == null) return child;
                            return SizedBox(
                              height: 160,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes == null
                                      ? null
                                      : progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],

              const SizedBox(height: 16),

              Row(
                children: <Widget>[
                  _priorityChip(colorScheme),
                  const SizedBox(width: 10),
                  Text(
                    complaint.priority,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  PressScale(
                    child: isInCart
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.check),
                            label: const Text('In Cart'),
                          )
                        : FilledButton.icon(
                            onPressed: onAddToCart,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to Cart'),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(ColorScheme colorScheme) {
    final color = switch (complaint.priority) {
      'High' => AppThemes.statusRejected,
      'Low' => AppThemes.statusResolved,
      _ => AppThemes.statusPending,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.priority_high, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Priority',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 160,
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}