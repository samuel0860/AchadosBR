import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';

// Estrutura de mensagem do carrossel
class _ProofMsg {
  final String name;
  final String action;
  final String? highlight;
  final IconData icon;

  const _ProofMsg(this.name, this.action, this.highlight, this.icon);
}

class SocialProofBanner extends StatefulWidget {
  const SocialProofBanner({super.key});

  @override
  State<SocialProofBanner> createState() => _SocialProofBannerState();
}

class _SocialProofBannerState extends State<SocialProofBanner>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  static const _clientMessages = [
    _ProofMsg('Samuel', 'acabou de comprar um iPhone 15 Pro', 'cupom IPHONE15BR', Icons.smartphone_rounded),
    _ProofMsg('Maria', 'economizou R\$ 350 com um cupom exclusivo', null, Icons.savings_rounded),
    _ProofMsg('João', 'comprou um PS5 com 25% de desconto', 'cupom PS5BRASIL', Icons.sports_esports_rounded),
    _ProofMsg('Camila', 'encontrou frete grátis em 3 produtos', null, Icons.local_shipping_rounded),
    _ProofMsg('Pedro', 'economizou R\$ 1.200 com alerta de promoção', null, Icons.notifications_active_rounded),
    _ProofMsg('Fernanda', 'comprou Air Fryer por R\$ 90 a menos', null, Icons.kitchen_rounded),
  ];

  static const _affiliateMessages = [
    _ProofMsg('Samuel', 'acabou de ganhar', 'R\$ 400 em comissão', Icons.emoji_events_rounded),
    _ProofMsg('Maria', 'realizou mais uma venda e faturou', 'R\$ 120', Icons.shopping_cart_checkout_rounded),
    _ProofMsg('João', 'faturou', 'R\$ 1.200 hoje', Icons.trending_up_rounded),
    _ProofMsg('Ana', 'atingiu 50 vendas este mês', null, Icons.workspace_premium_rounded),
    _ProofMsg('Ricardo', 'ganhou comissão de', 'R\$ 680 esta semana', Icons.account_balance_wallet_rounded),
    _ProofMsg('Larissa', 'publicou 3 novos produtos e já tem 12 cliques', null, Icons.bar_chart_rounded),
  ];

  List<_ProofMsg> get _messages {
    final isAffiliate = AuthService().isAffiliate;
    return isAffiliate ? _affiliateMessages : _clientMessages;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // Auto-advance every 3.5s
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) return false;
      _controller.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % _messages.length;
        });
        _controller.forward();
      });
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAffiliate = AuthService().isAffiliate;
    final msgs = _messages;
    final msg = msgs[_currentIndex];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAffiliate
              ? [const Color(0xFF1A1200), const Color(0xFF2A1F00)]
              : [AppColors.surfaceElevated, AppColors.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAffiliate
              ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isAffiliate
                    ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                msg.icon,
                color: isAffiliate ? const Color(0xFFD4AF37) : AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: isAffiliate
                  ? _buildAffiliateText(msg)
                  : _buildClientText(msg),
            ),
            // Dots indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(msgs.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 3),
                  width: i == _currentIndex ? 12 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i == _currentIndex
                        ? (isAffiliate ? const Color(0xFFD4AF37) : AppColors.primary)
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAffiliateText(_ProofMsg msg) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(fontSize: 12),
        children: [
          TextSpan(
            text: '${msg.name} ',
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Color(0xFFD4AF37)),
          ),
          TextSpan(
            text: '${msg.action} ',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (msg.highlight != null)
            TextSpan(
              text: msg.highlight,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: Color(0xFFD4AF37)),
            ),
        ],
      ),
    );
  }

  Widget _buildClientText(_ProofMsg msg) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(fontSize: 12),
        children: [
          TextSpan(
            text: '${msg.name} ',
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
          TextSpan(
            text: '${msg.action} ',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (msg.highlight != null)
            TextSpan(
              text: 'usando ${msg.highlight}',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.savings),
            ),
        ],
      ),
    );
  }
}
