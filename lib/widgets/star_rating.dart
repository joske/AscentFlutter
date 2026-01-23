import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final int maxStars;
  final double size;

  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          size: size,
          color: index < stars ? Colors.amber : Colors.grey[400],
        );
      }),
    );
  }
}
