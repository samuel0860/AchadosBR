/// Dados de afiliados mockados para demonstração
class MockAffiliate {
  final String id;
  final String name;
  final String bio;
  final String themeColorHex;
  final int totalDeals;
  final double rating;

  const MockAffiliate({
    required this.id,
    required this.name,
    required this.bio,
    required this.themeColorHex,
    required this.totalDeals,
    required this.rating,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'A';
}

final List<MockAffiliate> mockAffiliates = [
  const MockAffiliate(
    id: 'affiliate_tech',
    name: 'TechHunter',
    bio: 'Caçador de ofertas tech. Eletrônicos com até 70% de desconto todo dia! 📱💻',
    themeColorHex: '#3B82F6',
    totalDeals: 128,
    rating: 4.9,
  ),
  const MockAffiliate(
    id: 'affiliate_game',
    name: 'GameDeals',
    bio: 'Os melhores deals de games, consoles e acessórios. Gamer economizando gamer! 🎮',
    themeColorHex: '#7C3AED',
    totalDeals: 95,
    rating: 4.8,
  ),
  const MockAffiliate(
    id: 'affiliate_beauty',
    name: 'BeautyHunter',
    bio: 'Beleza e bem-estar com preço justo. Perfumes, cosméticos e skincare importados 💄',
    themeColorHex: '#EC4899',
    totalDeals: 73,
    rating: 4.7,
  ),
  const MockAffiliate(
    id: 'affiliate_sport',
    name: 'SportFinder',
    bio: 'Equipamentos esportivos, roupas e tênis com os melhores preços do mercado ⚽👟',
    themeColorHex: '#10B981',
    totalDeals: 61,
    rating: 4.6,
  ),
  const MockAffiliate(
    id: 'affiliate_casa',
    name: 'CasaPromo',
    bio: 'Sua casa mais bonita e organizada gastando pouco. Móveis, decoração e eletrodomésticos 🏠',
    themeColorHex: '#D4AF37',
    totalDeals: 84,
    rating: 4.8,
  ),
  const MockAffiliate(
    id: 'affiliate_gadget',
    name: 'GadgetMaster',
    bio: 'Tablets, smartwatches e gadgets importados com frete grátis. Tecnologia acessível! 📟',
    themeColorHex: '#F97316',
    totalDeals: 110,
    rating: 4.9,
  ),
];

MockAffiliate? findAffiliateById(String id) {
  try {
    return mockAffiliates.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}

MockAffiliate? findAffiliateByName(String name) {
  try {
    return mockAffiliates.firstWhere(
      (a) => a.name.toLowerCase() == name.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
}
