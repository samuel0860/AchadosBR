import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/widgets/affiliate_scaffold.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

enum LoginType { cliente, afiliado }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMsg;
  LoginType _selectedType = LoginType.cliente;

  late AnimationController _bgAnimController;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _bgAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final auth = AuthService();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Validate that the user logged into the correct tab
      final isLoginAffiliate = _selectedType == LoginType.afiliado;
      if (isLoginAffiliate && !auth.isAffiliate) {
        await auth.logout();
        setState(() => _errorMsg = 'Esta é uma conta de cliente. Use a aba "Sou Cliente" para entrar.');
        return;
      }
      if (!isLoginAffiliate && auth.isAffiliate) {
        await auth.logout();
        setState(() => _errorMsg = 'Esta é uma conta de afiliado. Use a aba "Sou Afiliado" para entrar.');
        return;
      }

      // Rota correta baseada no tipo de usuário
      final destination = auth.isAffiliate
          ? const AffiliateScaffold()
          : const MainScaffold();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      setState(() => _errorMsg = auth.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A0A14),
                  Color.lerp(
                    _selectedType == LoginType.afiliado 
                        ? const Color(0xFF1F1A05) // Gold tint
                        : const Color(0xFF0D0525), // Purple tint
                    const Color(0xFF140A0A),
                    _bgAnimation.value,
                  )!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildLoginToggle(),
                  const SizedBox(height: 32),
                  _buildWelcomeText(),
                  const SizedBox(height: 32),
                  _buildForm(),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorBanner(),
                  ],
                  const SizedBox(height: 24),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildSocialButtons(),
                  const SizedBox(height: 28),
                  _buildRegisterLink(),
                  const SizedBox(height: 16),
                  _buildTestCredentialsBanner(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final isAffiliate = _selectedType == LoginType.afiliado;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            isAffiliate ? 'assets/images/app_icon_gold.png' : 'assets/images/app_icon.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        )
            .animate(key: ValueKey('logo_$_selectedType'))
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut)
            .shimmer(duration: 1200.ms, color: Colors.white24),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isAffiliate
                ? [const Color(0xFFD4AF37), const Color(0xFFF5D77E), const Color(0xFFC8922A)]
                : [const Color(0xFF7C3AED), const Color(0xFFEF4444)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'AchouAchado',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginToggle() {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              type: LoginType.cliente,
              label: 'Sou Cliente',
              icon: Icons.person_rounded,
            ),
          ),
          Expanded(
            child: _buildToggleItem(
              type: LoginType.afiliado,
              label: 'Sou Afiliado',
              icon: Icons.storefront_rounded,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildToggleItem({
    required LoginType type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    final isAffiliate = type == LoginType.afiliado;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isAffiliate 
                      ? [const Color(0xFFD4AF37), const Color(0xFFF59E0B)]
                      : [const Color(0xFF7C3AED), const Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isAffiliate ? const Color(0xFFD4AF37) : AppColors.primary).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    final isAffiliate = _selectedType == LoginType.afiliado;
    return Column(
      children: [
        Text(
          isAffiliate ? 'Painel de Afiliado' : 'Bem-vindo de volta!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate(key: ValueKey('welcome_$_selectedType')).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          isAffiliate 
              ? 'Gerencie seus achados e fature com vendas' 
              : 'Entre para descobrir as melhores promoções',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ).animate(key: ValueKey('subtitle_$_selectedType')).fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'E-mail',
            hint: 'seu@email.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe seu e-mail';
              if (!v.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Senha',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe sua senha';
              if (v.length < 6) return 'Senha muito curta';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _rememberMe 
                            ? (_selectedType == LoginType.afiliado ? const Color(0xFFD4AF37) : AppColors.primary)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: _rememberMe 
                              ? (_selectedType == LoginType.afiliado ? const Color(0xFFD4AF37) : AppColors.primary)
                              : AppColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: _rememberMe
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Lembrar de mim',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
                child: Text(
                  'Esqueci minha senha',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _selectedType == LoginType.afiliado ? const Color(0xFFD4AF37) : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.hot.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hot.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.hot, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMsg ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.hot),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).shake();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final accentColor = _selectedType == LoginType.afiliado ? const Color(0xFFD4AF37) : AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(prefixIcon, color: accentColor, size: 18),
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.hot, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.hot, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final isAffiliate = _selectedType == LoginType.afiliado;
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAffiliate 
                ? [const Color(0xFFD4AF37), const Color(0xFFF59E0B)]
                : [const Color(0xFF7C3AED), const Color(0xFFEF4444)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isAffiliate ? const Color(0xFFD4AF37) : AppColors.primary).withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isAffiliate ? Icons.rocket_launch_rounded : Icons.login_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isAffiliate ? 'Acessar Painel' : 'Entrar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, AppColors.border]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou continue com',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted.withValues(alpha: 0.8)),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.border, Colors.transparent]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
            color: const Color(0xFFEA4335),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.facebook_rounded,
            label: 'Facebook',
            color: const Color(0xFF1877F2),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Não tem uma conta? ',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: Text(
            'Cadastre-se grátis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _selectedType == LoginType.afiliado ? const Color(0xFFD4AF37) : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestCredentialsBanner() {
    final isAffiliate = _selectedType == LoginType.afiliado;
    final color = isAffiliate ? const Color(0xFFD4AF37) : AppColors.savings;

    return GestureDetector(
      onTap: () {
        _emailController.text = isAffiliate ? 'afiliado@AchouAchado.com' : 'teste@AchouAchado.com';
        _passwordController.text = '123456';
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAffiliate ? const Color(0xFF1F1A05) : const Color(0xFF0D1F0D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAffiliate ? Icons.workspace_premium_rounded : Icons.bug_report_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAffiliate ? 'Login Afiliado (Toque para preencher)' : 'Login Cliente (Toque para preencher)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAffiliate 
                        ? 'Email: afiliado@AchouAchado.com  |  Senha: 123456'
                        : 'Email: teste@AchouAchado.com  |  Senha: 123456',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.touch_app_rounded, color: color, size: 18),
          ],
        ),
      ),
    ).animate(key: ValueKey('test_banner_$_selectedType')).fadeIn(duration: 400.ms);
  }
}
