/// Planos de impulsionamento disponíveis
enum BoostPlan { basico, pro, premium }

class BoostModel {
  final String productId;
  final String affiliateId;
  final BoostPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const BoostModel({
    required this.productId,
    required this.affiliateId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  bool get isValid => isActive && DateTime.now().isBefore(endDate);

  int get priority {
    switch (plan) {
      case BoostPlan.premium:
        return 100; // TOP da lista
      case BoostPlan.pro:
        return 50;  // Destaque na lista
      case BoostPlan.basico:
        return 10;  // Leve impulso
    }
  }

  String get planName {
    switch (plan) {
      case BoostPlan.premium:
        return 'Premium TOP';
      case BoostPlan.pro:
        return 'Pro Destaque';
      case BoostPlan.basico:
        return 'Básico';
    }
  }

  String get planPrice {
    switch (plan) {
      case BoostPlan.premium:
        return 'R\$ 199,90';
      case BoostPlan.pro:
        return 'R\$ 79,90';
      case BoostPlan.basico:
        return 'R\$ 29,90';
    }
  }

  int get durationDays {
    switch (plan) {
      case BoostPlan.premium:
        return 30;
      case BoostPlan.pro:
        return 30;
      case BoostPlan.basico:
        return 7;
    }
  }
}
