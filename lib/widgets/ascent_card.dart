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
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isDark ? Colors.grey[850] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(context, isDark),
            const SizedBox(height: 8),
            _buildLocationRow(context, isDark),
            const SizedBox(height: 6),
            _buildMetadataRow(context, isDark),
            if (ascent.comment != null && ascent.comment!.isNotEmpty)
              _buildCommentRow(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        GradeBadge(grade: ascent.route?.grade ?? '?'),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ascent.route?.name ?? 'Unknown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
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

  Widget _buildLocationRow(BuildContext context, bool isDark) {
    final cragName = ascent.route?.crag?.name ?? 'Unknown';
    final sector = ascent.route?.sector;
    final hasValidSector = sector != null && sector.isNotEmpty;

    return Row(
      children: [
        Icon(Icons.location_on, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hasValidSector ? '$cragName / $sector' : cragName,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 12, color: isDark ? Colors.grey[500] : Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          ascent.date != null ? _formatter.format(ascent.date!) : '-',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(width: 16),
        StarRating(stars: ascent.stars ?? 0),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue[900] : Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${ascent.score ?? 0}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.blue[200] : Colors.blue[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentRow(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        ascent.comment!,
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
