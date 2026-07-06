enum DealCategory {
  eletronicos,
  moda,
  casa,
  beleza,
  alimentacao,
  jogos,
  esporte,
  livros,
  viagem,
  outros;

  String get label {
    switch (this) {
      case DealCategory.eletronicos:
        return 'Eletrônicos';
      case DealCategory.moda:
        return 'Moda';
      case DealCategory.casa:
        return 'Casa';
      case DealCategory.beleza:
        return 'Beleza';
      case DealCategory.alimentacao:
        return 'Alimentação';
      case DealCategory.jogos:
        return 'Jogos';
      case DealCategory.esporte:
        return 'Esporte';
      case DealCategory.livros:
        return 'Livros';
      case DealCategory.viagem:
        return 'Viagem';
      case DealCategory.outros:
        return 'Outros';
    }
  }

  String get emoji {
    switch (this) {
      case DealCategory.eletronicos:
        return '📱';
      case DealCategory.moda:
        return '👗';
      case DealCategory.casa:
        return '🏠';
      case DealCategory.beleza:
        return '💄';
      case DealCategory.alimentacao:
        return '🍔';
      case DealCategory.jogos:
        return '🎮';
      case DealCategory.esporte:
        return '⚽';
      case DealCategory.livros:
        return '📚';
      case DealCategory.viagem:
        return '✈️';
      case DealCategory.outros:
        return '🛍️';
    }
  }
}

class Deal {
  final String id;
  final String title;
  final String description;
  final double originalPrice;
  final double dealPrice;
  final String? couponCode;
  final String imageUrl;
  final String store;
  final String storeLogoUrl;
  final String dealUrl;
  final DealCategory category;
  final int upvotes;
  final int downvotes;
  final int comments;
  final DateTime postedAt;
  final String postedBy;
  final String postedByAvatar;
  final bool isVerified;
  final bool isHot;
  final bool hasFreeShipping;
  final DateTime? expiresAt;

  const Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.dealPrice,
    this.couponCode,
    required this.imageUrl,
    required this.store,
    required this.storeLogoUrl,
    required this.dealUrl,
    required this.category,
    required this.upvotes,
    required this.downvotes,
    required this.comments,
    required this.postedAt,
    required this.postedBy,
    required this.postedByAvatar,
    this.isVerified = false,
    this.isHot = false,
    this.hasFreeShipping = false,
    this.expiresAt,
  });

  double get discountPercent {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - dealPrice) / originalPrice * 100);
  }

  double get savings => originalPrice - dealPrice;

  int get temperature => upvotes - downvotes;
}
