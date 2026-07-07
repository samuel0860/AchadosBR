import 'package:flutter/material.dart';

/// Representa uma loja/marketplace com identidade visual própria
class StoreBrand {
  final String id;
  final String name;
  final String emoji;         // fallback se a imagem não carregar
  final Color primaryColor;   // cor principal da marca
  final Color textColor;      // cor do texto sobre o fundo
  final String? logoAsset;    // caminho do asset PNG da logo

  const StoreBrand({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primaryColor,
    required this.textColor,
    this.logoAsset,
  });
}

/// Catálogo de lojas disponíveis
const List<StoreBrand> kStoreBrands = [
  StoreBrand(
    id: 'amazon',
    name: 'Amazon',
    emoji: 'A',
    primaryColor: Color(0xFFFF9900),
    textColor: Colors.black,
    logoAsset: 'assets/icons/stores/amazon.png',
  ),
  StoreBrand(
    id: 'mercadolivre',
    name: 'Mercado Livre',
    emoji: 'ML',
    primaryColor: Color(0xFFFFE600),
    textColor: Colors.black,
    logoAsset: 'assets/icons/stores/mercadolivre.png',
  ),
  StoreBrand(
    id: 'magalu',
    name: 'Magalu',
    emoji: 'M',
    primaryColor: Color(0xFF0086FF),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/magalu.png',
  ),
  StoreBrand(
    id: 'shopee',
    name: 'Shopee',
    emoji: '🛍',
    primaryColor: Color(0xFFEE4D2D),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/shopee.png',
  ),
  StoreBrand(
    id: 'shein',
    name: 'Shein',
    emoji: 'S',
    primaryColor: Color(0xFF000000),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/shein.png',
  ),
  StoreBrand(
    id: 'submarino',
    name: 'Submarino',
    emoji: 'Sub',
    primaryColor: Color(0xFF003087),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/submarino.png',
  ),
  StoreBrand(
    id: 'pontofrio',
    name: 'Ponto Frio',
    emoji: 'PF',
    primaryColor: Color(0xFF0066CC),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/pontofrio.png',
  ),
  StoreBrand(
    id: 'madeiramadeira',
    name: 'MadeiraMadeira',
    emoji: 'MM',
    primaryColor: Color(0xFF8B4513),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/madeiramadeira.png',
  ),
  StoreBrand(
    id: 'leroymerlin',
    name: 'Leroy Merlin',
    emoji: 'LM',
    primaryColor: Color(0xFF007A33),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/leroymerlin.png',
  ),
  StoreBrand(
    id: 'nike',
    name: 'Nike',
    emoji: '✓',
    primaryColor: Color(0xFF111111),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/nike.png',
  ),
  StoreBrand(
    id: 'adidas',
    name: 'Adidas',
    emoji: '▲',
    primaryColor: Color(0xFF000000),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/adidas.png',
  ),
  StoreBrand(
    id: 'americanas',
    name: 'Americanas',
    emoji: 'Am',
    primaryColor: Color(0xFFCC0000),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/americanas.png',
  ),
  StoreBrand(
    id: 'casasbahia',
    name: 'Casas Bahia',
    emoji: 'CB',
    primaryColor: Color(0xFFFFD700),
    textColor: Colors.black,
    logoAsset: 'assets/icons/stores/casasbahia.png',
  ),
  StoreBrand(
    id: 'aliexpress',
    name: 'AliExpress',
    emoji: 'Ali',
    primaryColor: Color(0xFFE43225),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/aliexpress.png',
  ),
  StoreBrand(
    id: 'outros',
    name: 'Outros',
    emoji: '🏪',
    primaryColor: Color(0xFF6B7280),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/outros.png',
  ),
  StoreBrand(
    id: 'kabum',
    name: 'Kabum',
    emoji: 'K',
    primaryColor: Color(0xFFFC6B0F),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/kabum.png',
  ),
  StoreBrand(
    id: 'epocacosmeticos',
    name: 'Época Cosméticos',
    emoji: 'EC',
    primaryColor: Color(0xFFEE1166),
    textColor: Colors.white,
    logoAsset: 'assets/icons/stores/epocacosmeticos.png',
  ),
];

/// Busca uma loja pelo ID
StoreBrand? findStoreBrand(String? id) {
  if (id == null || id.isEmpty) return null;
  try {
    return kStoreBrands.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}

/// Busca uma loja pelo nome
StoreBrand? findStoreBrandByName(String? name) {
  if (name == null || name.isEmpty) return null;
  try {
    return kStoreBrands.firstWhere(
      (s) => s.name.toLowerCase() == name.toLowerCase() || 
             s.name.toLowerCase().contains(name.toLowerCase()) ||
             name.toLowerCase().contains(s.name.toLowerCase()),
    );
  } catch (_) {
    return null;
  }
}

/// Widget reutilizável que exibe a logo da loja (imagem com fallback em emoji)
class StoreLogo extends StatelessWidget {
  final StoreBrand store;
  final double size;
  final BorderRadius? borderRadius;

  const StoreLogo({
    super.key,
    required this.store,
    this.size = 32,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(size * 0.25);

    if (store.logoAsset != null) {
      return ClipRRect(
        borderRadius: br,
        child: Image.asset(
          store.logoAsset!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(br),
        ),
      );
    }
    return _fallback(br);
  }

  Widget _fallback(BorderRadius br) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: store.primaryColor,
        borderRadius: br,
      ),
      child: Center(
        child: Text(
          store.emoji,
          style: TextStyle(
            fontSize: size * (store.emoji.length > 2 ? 0.28 : 0.38),
            fontWeight: FontWeight.w900,
            color: store.textColor,
          ),
        ),
      ),
    );
  }
}
