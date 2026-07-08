import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/review.dart';
import 'theme_service.dart' show getStorageFile;

class ReviewService extends ChangeNotifier {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final List<Review> _reviews = [];
  bool _loaded = false;

  List<Review> get allReviews => List.unmodifiable(_reviews);

  List<Review> getReviewsByDeal(String dealId) =>
      _reviews.where((r) => r.dealId == dealId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  double getAverageRating(String dealId) {
    final dealReviews = getReviewsByDeal(dealId);
    if (dealReviews.isEmpty) return 0;
    return dealReviews.map((r) => r.rating).reduce((a, b) => a + b) /
        dealReviews.length;
  }

  List<Review> getUserReviews(String userId) =>
      _reviews.where((r) => r.userId == userId).toList();

  bool hasUserReviewed(String userId, String dealId) =>
      _reviews.any((r) => r.userId == userId && r.dealId == dealId);

  Future<void> init() async {
    if (_loaded) return;
    await _loadFromDisk();
    _loaded = true;
    // Seed some mock reviews
    if (_reviews.isEmpty) {
      _seedMockReviews();
    }
  }

  void _seedMockReviews() {
    final mockReviews = [
      Review(
        id: 'r1',
        userId: 'user1',
        userName: 'Carlos M.',
        userAvatarColor: '#10B981',
        dealId: '1',
        rating: 5,
        comment: 'Produto incrível! Chegou antes do prazo e embalagem perfeita. Valeu cada centavo!',
        emojiReactions: ['📦', '⚡', '👍'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerifiedPurchase: true,
      ),
      Review(
        id: 'r2',
        userId: 'user2',
        userName: 'Ana Paula S.',
        userAvatarColor: '#7C3AED',
        dealId: '1',
        rating: 4,
        comment: 'Ótimo custo-benefício. A câmera é excepcional. Tirei ponto por causa do cabo que veio sem adaptador.',
        emojiReactions: ['📸', '❤️'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerifiedPurchase: true,
      ),
      Review(
        id: 'r3',
        userId: 'user3',
        userName: 'Roberto L.',
        userAvatarColor: '#F59E0B',
        dealId: '1',
        rating: 5,
        comment: 'Melhor compra do ano! Performance absurda, bateria dura o dia todo.',
        emojiReactions: ['🔋', '🚀', '⭐'],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        isVerifiedPurchase: false,
      ),
      Review(
        id: 'r4',
        userId: 'user4',
        userName: 'Fernanda O.',
        userAvatarColor: '#EF4444',
        dealId: '2',
        rating: 5,
        comment: 'Console chegou lacrado, jogabilidade excepcional. Os gráficos são de tirar o fôlego!',
        emojiReactions: ['🎮', '🔥', '👑'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isVerifiedPurchase: true,
      ),
      Review(
        id: 'r5',
        userId: 'user5',
        userName: 'Diego P.',
        userAvatarColor: '#06B6D4',
        dealId: '3',
        rating: 4,
        comment: 'Tablet muito bom para trabalho e entretenimento. Tela bonita e processador rápido.',
        emojiReactions: ['💼', '🎵'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isVerifiedPurchase: true,
      ),
    ];
    _reviews.addAll(mockReviews);
    _saveToDisk();
  }

  Future<bool> addReview(Review review) async {
    if (hasUserReviewed(review.userId, review.dealId)) return false;
    _reviews.insert(0, review);
    await _saveToDisk();
    notifyListeners();
    return true;
  }

  Future<void> deleteReview(String reviewId) async {
    _reviews.removeWhere((r) => r.id == reviewId);
    await _saveToDisk();
    notifyListeners();
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  Future<File> _getFile() async => getStorageFile('achados_reviews.json');

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final data = jsonDecode(content) as List<dynamic>;
      _reviews.clear();
      _reviews.addAll(data.map((e) => Review.fromJson(e as Map<String, dynamic>)));
    } catch (_) {}
  }

  Future<void> _saveToDisk() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(_reviews.map((r) => r.toJson()).toList()));
    } catch (_) {}
  }
}
