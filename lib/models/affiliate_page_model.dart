import 'package:flutter/material.dart';

/// Configurações da página pública do afiliado
class AffiliatePageModel {
  final String affiliateId;
  final String displayName;
  final String bio;
  final String themeColorHex;  // cor temática personalizada
  final List<String> bannerUrls;  // banners/imagens em destaque
  final String? profileImageAsset; // asset de avatar (se houver)

  const AffiliatePageModel({
    required this.affiliateId,
    required this.displayName,
    this.bio = '',
    this.themeColorHex = '#7C3AED',
    this.bannerUrls = const [],
    this.profileImageAsset,
  });

  Color get themeColor {
    try {
      return Color(int.parse('FF${themeColorHex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFF7C3AED);
    }
  }

  Map<String, dynamic> toJson() => {
        'affiliateId': affiliateId,
        'displayName': displayName,
        'bio': bio,
        'themeColorHex': themeColorHex,
        'bannerUrls': bannerUrls,
        'profileImageAsset': profileImageAsset,
      };

  factory AffiliatePageModel.fromJson(Map<String, dynamic> map) =>
      AffiliatePageModel(
        affiliateId: map['affiliateId']?.toString() ?? '',
        displayName: map['displayName']?.toString() ?? '',
        bio: map['bio']?.toString() ?? '',
        themeColorHex: map['themeColorHex']?.toString() ?? '#7C3AED',
        bannerUrls: List<String>.from(map['bannerUrls'] as List? ?? []),
        profileImageAsset: map['profileImageAsset']?.toString(),
      );

  AffiliatePageModel copyWith({
    String? displayName,
    String? bio,
    String? themeColorHex,
    List<String>? bannerUrls,
    String? profileImageAsset,
  }) =>
      AffiliatePageModel(
        affiliateId: affiliateId,
        displayName: displayName ?? this.displayName,
        bio: bio ?? this.bio,
        themeColorHex: themeColorHex ?? this.themeColorHex,
        bannerUrls: bannerUrls ?? this.bannerUrls,
        profileImageAsset: profileImageAsset ?? this.profileImageAsset,
      );
}
