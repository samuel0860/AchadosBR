class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarColor;
  final String dealId;
  final int rating; // 1-5
  final String comment;
  final List<String> emojiReactions; // pre-defined product emojis
  final DateTime createdAt;
  final bool isVerifiedPurchase;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarColor,
    required this.dealId,
    required this.rating,
    required this.comment,
    this.emojiReactions = const [],
    required this.createdAt,
    this.isVerifiedPurchase = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userAvatarColor': userAvatarColor,
        'dealId': dealId,
        'rating': rating,
        'comment': comment,
        'emojiReactions': emojiReactions,
        'createdAt': createdAt.toIso8601String(),
        'isVerifiedPurchase': isVerifiedPurchase,
      };

  factory Review.fromJson(Map<String, dynamic> map) => Review(
        id: map['id']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        userName: map['userName']?.toString() ?? '',
        userAvatarColor: map['userAvatarColor']?.toString() ?? '#7C3AED',
        dealId: map['dealId']?.toString() ?? '',
        rating: (map['rating'] as num?)?.toInt() ?? 5,
        comment: map['comment']?.toString() ?? '',
        emojiReactions: List<String>.from(map['emojiReactions'] ?? []),
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        isVerifiedPurchase: map['isVerifiedPurchase'] == true,
      );
}
