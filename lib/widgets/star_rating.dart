import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const StarRating({super.key, required this.rating, this.size = 16, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.amber;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (rating >= i + 1) return Icon(Icons.star, size: size, color: c);
        if (rating >= i + 0.5) return Icon(Icons.star_half, size: size, color: c);
        return Icon(Icons.star_border, size: size, color: c);
      }),
    );
  }
}
