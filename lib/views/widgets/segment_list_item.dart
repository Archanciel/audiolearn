// lib/views/widgets/segment_list_item.dart
import 'package:flutter/material.dart';
import '../../models/audio_segment.dart';
import '../../utils/time_format_util.dart';

class SegmentListItem extends StatelessWidget {
  final int index;
  final AudioSegment segment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SegmentListItem({
    super.key,
    required this.index,
    required this.segment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final duration = segment.duration;
    final totalDuration = duration + segment.silenceDuration;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Index circle
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Segment details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    segment.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Time range
                  Text(
                    '${TimeFormatUtil.formatSeconds(segment.startPosition)} → '
                    '${TimeFormatUtil.formatSeconds(segment.endPosition)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),

                  // Fade-in info
                  if (segment.fadeInDuration > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.volume_up,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Fade-In: ${TimeFormatUtil.formatSeconds(segment.fadeInDuration)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Fade-out info
                  if (segment.soundReductionDuration > 0 &&
                      segment.soundReductionPosition > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.volume_off,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Fade-Out at ${TimeFormatUtil.formatSeconds(segment.soundReductionPosition)}, '
                          'Duration: ${TimeFormatUtil.formatSeconds(segment.soundReductionDuration)}',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Duration info
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${TimeFormatUtil.formatSeconds(totalDuration)}'
                    '${segment.silenceDuration > 0 ? ' + ${TimeFormatUtil.formatSeconds(segment.silenceDuration)} silence' : ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  tooltip: 'Edit segment',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: onDelete,
                  tooltip: 'Delete segment',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
