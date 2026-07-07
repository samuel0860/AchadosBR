import 'package:flutter/material.dart';

/// Posição do selo de desconto na imagem do produto
enum BadgePosition {
  topLeft,
  topRight,
  center,
  bottomLeft,
  bottomRight;

  String get label {
    switch (this) {
      case BadgePosition.topLeft: return 'Superior Esq.';
      case BadgePosition.topRight: return 'Superior Dir.';
      case BadgePosition.center: return 'Centro';
      case BadgePosition.bottomLeft: return 'Inferior Esq.';
      case BadgePosition.bottomRight: return 'Inferior Dir.';
    }
  }

  Alignment get alignment {
    switch (this) {
      case BadgePosition.topLeft: return Alignment.topLeft;
      case BadgePosition.topRight: return Alignment.topRight;
      case BadgePosition.center: return Alignment.center;
      case BadgePosition.bottomLeft: return Alignment.bottomLeft;
      case BadgePosition.bottomRight: return Alignment.bottomRight;
    }
  }
}

class AffiliateProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final double originalPrice;
  final double discountPercent;
  final BadgePosition badgePosition;
  final String imageUrl;
  final String highlightColor; // hex
  final bool isActive;
  final String affiliateId;
  final DateTime createdAt;
  final String? couponCode;
  final String store;
  final String storeId;   // ID da loja (ex: 'amazon', 'mercadolivre')
  final String category;
  final bool hasFreeShipping;

  const AffiliateProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    this.badgePosition = BadgePosition.topLeft,
    required this.imageUrl,
    this.highlightColor = '#7C3AED',
    this.isActive = true,
    required this.affiliateId,
    required this.createdAt,
    this.couponCode,
    this.store = '',
    this.storeId = '',
    this.category = 'outros',
    this.hasFreeShipping = false,
  });

  double get savings => originalPrice - price;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'discountPercent': discountPercent,
        'badgePosition': badgePosition.name,
        'imageUrl': imageUrl,
        'highlightColor': highlightColor,
        'isActive': isActive,
        'affiliateId': affiliateId,
        'createdAt': createdAt.toIso8601String(),
        'couponCode': couponCode,
        'store': store,
        'storeId': storeId,
        'category': category,
        'hasFreeShipping': hasFreeShipping,
      };

  factory AffiliateProduct.fromJson(Map<String, dynamic> map) =>
      AffiliateProduct(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        originalPrice: (map['originalPrice'] as num?)?.toDouble() ?? 0,
        discountPercent: (map['discountPercent'] as num?)?.toDouble() ?? 0,
        badgePosition: BadgePosition.values.firstWhere(
          (b) => b.name == map['badgePosition'],
          orElse: () => BadgePosition.topLeft,
        ),
        imageUrl: map['imageUrl']?.toString() ?? '',
        highlightColor: map['highlightColor']?.toString() ?? '#7C3AED',
        isActive: map['isActive'] == true,
        affiliateId: map['affiliateId']?.toString() ?? '',
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        couponCode: map['couponCode']?.toString(),
        store: map['store']?.toString() ?? '',
        storeId: map['storeId']?.toString() ?? '',
        category: map['category']?.toString() ?? 'outros',
        hasFreeShipping: map['hasFreeShipping'] == true,
      );

  AffiliateProduct copyWith({
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    double? discountPercent,
    BadgePosition? badgePosition,
    String? imageUrl,
    String? highlightColor,
    bool? isActive,
    String? couponCode,
    String? store,
    String? storeId,
    String? category,
    bool? hasFreeShipping,
  }) =>
      AffiliateProduct(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        originalPrice: originalPrice ?? this.originalPrice,
        discountPercent: discountPercent ?? this.discountPercent,
        badgePosition: badgePosition ?? this.badgePosition,
        imageUrl: imageUrl ?? this.imageUrl,
        highlightColor: highlightColor ?? this.highlightColor,
        isActive: isActive ?? this.isActive,
        affiliateId: affiliateId,
        createdAt: createdAt,
        couponCode: couponCode ?? this.couponCode,
        store: store ?? this.store,
        storeId: storeId ?? this.storeId,
        category: category ?? this.category,
        hasFreeShipping: hasFreeShipping ?? this.hasFreeShipping,
      );
}
