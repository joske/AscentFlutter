import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ascent.dart';
import 'grade_badge.dart';
import 'style_chip.dart';
import 'star_rating.dart';

class AscentCard extends StatelessWidget {
  final Ascent ascent;
  final Widget trailing;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  AscentCard({
    super.key,
    required this.ascent,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(context),
            const SizedBox(height: 8),
            _buildLocationRow(context),
            const SizedBox(height: 6),
            _buildMetadataRow(context),
            if (ascent.comment != null && ascent.comment!.isNotEmpty)
              _buildCommentRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        GradeBadge(grade: ascent.route?.grade ?? '?'),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ascent.route?.name ?? 'Unknown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (ascent.style != null) StyleChip(style: ascent.style!),
        trailing,
      ],
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    final cragName = ascent.route?.crag?.name ?? 'Unknown';
    final sector = ascent.route?.sector;
    final hasValidSector = sector != null && sector.isNotEmpty;

    return Row(
      children: [
        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hasValidSector ? '$cragName / $sector' : cragName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          ascent.date != null ? _formatter.format(ascent.date!) : '-',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        StarRating(stars: ascent.stars ?? 0),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${ascent.score ?? 0}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        ascent.comment!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
