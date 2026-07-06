import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SocialProofBanner extends StatefulWidget {
  const SocialProofBanner({super.key});

  @override
  State<SocialProofBanner> createState() => _SocialProofBannerState();
}

class _SocialProofBannerState extends State<SocialProofBanner>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    _SocialMessage('Samuel', 'acabou de receber uma comissão de', 'R\$ 400,00', Icons.emoji_events_rounded),
    _SocialMessage('Juliana', 'realizou uma venda e ganhou', 'R\$ 275,00', Icons.storefront_rounded),
    _SocialMessage('Carlos', 'recebeu em comissões hoje', 'R\$ 890,00', Icons.trending_up_rounded),
    _SocialMessage('Amanda', 'acabou de faturar com o app', 'R\$ 1.200,00', Icons.workspace_premium_rounded),
    _SocialMessage('Rafael', 'ganhou em comissões essa semana', 'R\$ 3.450,00', Icons.stars_rounded),
    _SocialMessage('Fernanda', 'acabou de confirmar seu pagamento de', 'R\$ 560,00', Icons.payments_rounded),
    _SocialMessage('Bruno', 'bateu sua meta e recebeu', 'R\$ 2.100,00', Icons.military_tech_rounded),
    _SocialMessage('Camila', 'fechou mais uma venda hoje de', 'R\$ 320,00', Icons.local_fire_department_rounded),
    _SocialMessage('Pedro', 'recebeu sua comissão de ontem de', 'R\$ 740,00', Icons.monetization_on_rounded),
    _SocialMessage('Larissa', 'está faturando agora mesmo', 'R\$ 480,00', Icons.bolt_rounded),
    _SocialMessage('Thiago', 'novos pagamentos chegando, total de', 'R\$ 1.875,00', Icons.account_balance_wallet_rounded),
    _SocialMessage('Beatriz', 'acabou de retirar suas comissões de', 'R\$ 950,00', Icons.savings_rounded),
  ];

  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _nextMessage();
    });
  }

  Future<void> _nextMessage() async {
    await _fadeController.reverse();
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _messages.length;
    });
    _fadeController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = _messages[_currentIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1508), Color(0xFF2A2010)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Pulsing dot indicator
              _buildPulsingDot(),
              const SizedBox(width: 10),
              // Avatar circle
              _buildAvatar(msg.name),
              const SizedBox(width: 10),
              // Message
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, height: 1.3),
                    children: [
                      TextSpan(
                        text: msg.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      TextSpan(
                        text: ' ${msg.action} ',
                        style: const TextStyle(color: Color(0xFFB8A88A)),
                      ),
                      TextSpan(
                        text: msg.amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD700),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(msg.icon, color: const Color(0xFFD4AF37), size: 18),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPulsingDot() {
    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(begin: 1, end: 1.8, duration: 1000.ms, curve: Curves.easeOut)
              .fadeOut(duration: 1000.ms),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1000),
          ),
        ),
      ),
    );
  }
}

class _SocialMessage {
  final String name;
  final String action;
  final String amount;
  final IconData icon;

  const _SocialMessage(this.name, this.action, this.amount, this.icon);
}
