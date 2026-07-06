import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../models/deal.dart';
import '../../models/review.dart';
import '../../services/auth_service.dart';
import '../../services/review_service.dart';

class ReviewsSection extends StatefulWidget {
  final Deal deal;
  const ReviewsSection({super.key, required this.deal});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final _reviewService = ReviewService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final reviews = _reviewService.getReviewsByDeal(widget.deal.id);
    final avg = _reviewService.getAverageRating(widget.deal.id);
    final user = _authService.currentUser;
    final hasReviewed = user != null &&
        _reviewService.hasUserReviewed(user.id, widget.deal.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: [
              const Text('Avaliações',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const Spacer(),
              if (!hasReviewed && user != null)
                GestureDetector(
                  onTap: () => _showAddReviewSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFEF4444)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rate_review_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Avaliar',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Average rating card
        if (reviews.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary),
                    ),
                    _buildStars(avg),
                    Text('${reviews.length} avaliações',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count =
                          reviews.where((r) => r.rating == star).length;
                      final pct =
                          reviews.isEmpty ? 0 : count / reviews.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$star',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded,
                                size: 12, color: Color(0xFFD4AF37)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct.toDouble(),
                                  minHeight: 6,
                                  backgroundColor: AppColors.border,
                                  valueColor:
                                      const AlwaysStoppedAnimation(
                                          Color(0xFFD4AF37)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('$count',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        // Review list
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.rate_review_outlined,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  const Text('Seja o primeiro a avaliar!',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
        else
          ...reviews.take(5).mapIndexed((index, review) =>
              _buildReviewCard(review, index)),
      ],
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded,
              size: 16, color: Color(0xFFD4AF37));
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded,
              size: 16, color: Color(0xFFD4AF37));
        } else {
          return const Icon(Icons.star_outline_rounded,
              size: 16, color: AppColors.textMuted);
        }
      }),
    );
  }

  Widget _buildReviewCard(Review review, int index) {
    final avatarColor = _hexColor(review.userAvatarColor);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: avatarColor,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(review.userName,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        if (review.isVerifiedPurchase) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.savings.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Compra verificada',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.savings,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    _buildStars(review.rating.toDouble()),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5)),
          ],
          if (review.emojiReactions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: review.emojiReactions
                  .map((e) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80));
  }

  void _showAddReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _AddReviewSheet(
        deal: widget.deal,
        onSubmit: (_) => setState(() {}),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 30) return 'Há ${diff.inDays} dias';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

// Extension helper
extension _Indexed<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) f) sync* {
    var i = 0;
    for (final item in this) {
      yield f(i++, item);
    }
  }
}

// ─── Add Review Bottom Sheet ──────────────────────────────────────────────────

class _AddReviewSheet extends StatefulWidget {
  final Deal deal;
  final void Function(Review) onSubmit;

  const _AddReviewSheet({required this.deal, required this.onSubmit});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  final Set<String> _selectedEmojis = {};
  bool _isLoading = false;

  static const _emojis = ['📦', '⚡', '👍', '❤️', '🔥', '🚀', '⭐', '💯', '📸', '🎮', '👑', '💪'];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final user = AuthService().currentUser;
    if (user == null) return;

    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      userName: user.name,
      userAvatarColor: user.avatarColor ?? '#7C3AED',
      dealId: widget.deal.id,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
      emojiReactions: _selectedEmojis.toList(),
      createdAt: DateTime.now(),
      isVerifiedPurchase: false,
    );

    await ReviewService().addReview(review);
    widget.onSubmit(review);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('Avaliar produto',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            // Star rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 40,
                        color: i < _rating
                            ? const Color(0xFFD4AF37)
                            : AppColors.textMuted,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            // Emoji reactions
            const Text('Reações rápidas',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                final selected = _selectedEmojis.contains(emoji);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedEmojis.remove(emoji);
                    } else {
                      _selectedEmojis.add(emoji);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Comment
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Compartilhe sua experiência com este produto...',
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Enviar Avaliação',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
