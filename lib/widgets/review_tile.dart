import 'package:flutter/material.dart';
import '../models/review_model.dart';
import 'star_rating.dart';

class ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const ReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            StarRating(rating: review.rating.toDouble()),
            const SizedBox(width: 8),
            Text(review.buyerDisplayName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          Text(review.feedback),
          const Divider(),
        ],
      ),
    );
  }
}
